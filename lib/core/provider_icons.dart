import 'package:flutter/material.dart';

import '../data/db/tables.dart' show AdapterKind;

/// 供应商官方图标（assets/logos/）。按适配器种类映射：
/// 官方订阅 / 中转站软件有各自 logo，自定义条目回退通用图标。
/// 图标来自各官方站点 / 品牌资产，仅作识别用途。
class ProviderIcons {
  ProviderIcons._();

  static const _byAdapter = <AdapterKind, String>{
    AdapterKind.claude: 'assets/logos/claude.png',
    AdapterKind.openai: 'assets/logos/openai.png',
    AdapterKind.zhipu: 'assets/logos/zhipu.png',
    AdapterKind.zhipuAnthropic: 'assets/logos/zhipu.png',
    AdapterKind.deepseek: 'assets/logos/deepseek.png',
    AdapterKind.deepseekAnthropic: 'assets/logos/deepseek.png',
    AdapterKind.newapi: 'assets/logos/newapi.png',
    AdapterKind.sub2api: 'assets/logos/newapi.png',
    AdapterKind.kimi: 'assets/logos/kimi.png',
    AdapterKind.opencode: 'assets/logos/opencode.png',
    AdapterKind.moonshot: 'assets/logos/moonshot.png',
  };

  /// 有官方图标返回资源路径；自定义条目返回 null（调用方不画图标）
  static String? assetFor(AdapterKind kind) => _byAdapter[kind];

  /// 看板标题行的小图标：官方条目显示 logo，自定义返回 null
  static Widget? badge(AdapterKind kind, {double size = 22}) {
    final asset = assetFor(kind);
    if (asset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.24),
        child: Image.asset(asset, width: size, height: size),
      );
    }
    return null;
  }
}
