import 'package:dio/dio.dart';

import 'openai_compatible.dart';
import 'provider_adapter.dart';

/// NewAPI 中转站适配器：在 OpenAI 兼容能力之上增加余额查询与签到。
///
/// - 余额：GET  {origin}/api/user/self（系统访问令牌）
/// - 签到：POST {origin}/api/user/check_in
///
/// 系统访问令牌是 Web 控制台里的「系统访问令牌」，与普通 sk- API Key 不同，
/// 保存在 Secure Storage 的 systemTokenRef 引用下。
class NewApiAdapter extends OpenAICompatibleAdapter {
  NewApiAdapter({super.dio});

  @override
  String get kind => 'newapi';

  @override
  AdapterCapabilities get capabilities => const AdapterCapabilities(
        models: true,
        testModel: true,
        balance: true,
        checkIn: true,
      );

  /// NewAPI user/self 里的 used_quota 为本月累计已用（内部配额单位），
  /// 换算为美元（Plan #43：API 用量 = 已用量 + 周期）。
  Future<double?> getUsedThisMonth(ProviderContext ctx) async {
    try {
      final res = await dio.get('${_origin(ctx)}/api/user/self',
          options: _options(ctx));
      final body = res.data;
      if (res.statusCode == 200 &&
          body is Map &&
          body['success'] == true &&
          body['data'] is Map) {
        final used = (body['data']['used_quota'] as num?)?.toDouble();
        if (used == null) return null;
        return used / quotaPerDollar;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// NewAPI 内部 quota 换算：1 美元 = 500000 配额。
  static const quotaPerDollar = 500000.0;

  /// NewAPI 控制台 API 位于站点根（/api/user/*），而用户填的 Base URL
  /// 常带版本段（/v1，即聊天端点）：拼接前先去掉末尾版本段。
  static String consoleOrigin(String raw) {
    var base = OpenAICompatibleAdapter.normalizeBaseUrl(raw);
    base = base.replaceAll(RegExp(r'/v\d+[a-z0-9]*$'), '');
    return base;
  }

  String _origin(ProviderContext ctx) => consoleOrigin(ctx.baseUrl);

  Map<String, String> _userHeaders(ProviderContext ctx) => {
        'Authorization': 'Bearer ${ctx.systemToken ?? ''}',
        'Content-Type': 'application/json',
        if (ctx.systemUserId != null && ctx.systemUserId!.isNotEmpty)
          'New-Api-User': ctx.systemUserId!,
      };

  Options _options(ProviderContext ctx) => Options(
        headers: _userHeaders(ctx),
        sendTimeout: const Duration(milliseconds: 20000),
        receiveTimeout: const Duration(milliseconds: 20000),
        validateStatus: (_) => true,
      );

  @override
  Future<BalanceResult> getBalance(ProviderContext ctx) async {
    try {
      final res = await dio.get('${_origin(ctx)}/api/user/self',
          options: _options(ctx));
      final body = res.data;
      if (res.statusCode == 200 &&
          body is Map &&
          body['success'] == true &&
          body['data'] is Map) {
        final data = body['data'] as Map;
        final quota = (data['quota'] as num?)?.toDouble() ?? 0;
        return BalanceResult(
          amount: quota / quotaPerDollar,
          currency: 'USD',
          success: true,
        );
      }
      final msg = body is Map ? (body['message']?.toString() ?? '') : '';
      return BalanceResult(
        amount: 0,
        success: false,
        message: _friendlyAuthError(msg.isNotEmpty ? msg : 'HTTP ${res.statusCode}'),
      );
    } catch (e) {
      return BalanceResult(amount: 0, success: false, message: e.toString());
    }
  }

  /// 「invalid access token」= 站点 access_token 表无此令牌，绝大多数是
  /// 把 sk- 开头的 API 密钥当成了系统访问令牌。给出可操作的指引。
  static String _friendlyAuthError(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('access token') || msg.contains('访问令牌')) {
      return '$msg（请确认保存的是控制台「个人设置 → 系统访问令牌」，'
          '而不是 sk- 开头的 API 密钥；修改后重新保存并刷新）';
    }
    return msg;
  }

  /// 签到端点：新版开源为 /api/user/checkin，老二开为 /api/user/check_in，
  /// 依次尝试。
  Future<({dynamic body, int? status})?> _postCheckin(
      ProviderContext ctx) async {
    for (final path in const ['/api/user/checkin', '/api/user/check_in']) {
      final res = await dio.post('$_origin(ctx)$path', options: _options(ctx));
      if (res.statusCode != 404) {
        return (body: res.data, status: res.statusCode);
      }
    }
    return null;
  }

  @override
  Future<CheckinResult> checkIn(ProviderContext ctx) async {
    try {
      final hit = await _postCheckin(ctx);
      if (hit == null) {
        return const CheckinResult(
            success: false, message: '站点不支持签到接口（404）');
      }
      final body = hit.body;
      if (body is Map) {
        final success = body['success'] == true;
        final message = body['message']?.toString() ?? '';
        // NewAPI 对重复签到返回 success=false 且 message 提示已签到
        final already = message.contains('已签到') ||
            message.toLowerCase().contains('already');
        if (success) {
          return CheckinResult(success: true, message: message.isEmpty ? '签到成功' : message);
        }
        if (already) {
          return CheckinResult(
              success: false, message: '今日已签到', alreadyCheckedIn: true);
        }
        return CheckinResult(
            success: false,
            message: _friendlyAuthError(message.isEmpty ? '签到失败' : message));
      }
      return CheckinResult(success: false, message: 'HTTP ${hit.status}');
    } catch (e) {
      return CheckinResult(success: false, message: e.toString());
    }
  }
}

/// Sub2API 结构与 NewAPI 接近，先复用同一实现。
class Sub2ApiAdapter extends NewApiAdapter {
  Sub2ApiAdapter({super.dio});

  @override
  String get kind => 'sub2api';
}
