import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 发版元数据（CI 随 Release 附带的 update-info.json）
class UpdateInfo {
  const UpdateInfo({
    required this.version,
    required this.buildNumber,
    required this.notes,
    required this.apkUrls,
  });

  final String version;
  final int buildNumber;
  final String notes;

  /// ABI → APK 下载地址
  final Map<String, String> apkUrls;

  static UpdateInfo? fromJson(Map<String, dynamic> json) {
    final version = json['version']?.toString();
    final build = int.tryParse(json['buildNumber']?.toString() ?? '');
    if (version == null || version.isEmpty || build == null) return null;
    final urls = <String, String>{};
    final raw = json['apkUrls'];
    if (raw is Map) {
      for (final e in raw.entries) {
        if (e.value is String) urls[e.key.toString()] = e.value as String;
      }
    }
    return UpdateInfo(
      version: version,
      buildNumber: build,
      notes: json['notes']?.toString() ?? '',
      apkUrls: urls,
    );
  }
}

/// 检查结果
enum UpdateStatus {
  upToDate,
  available,
  failed,
}

class UpdateCheckResult {
  const UpdateCheckResult({
    required this.status,
    this.info,
    this.currentVersion,
    this.currentBuild,
    this.error,
  });

  final UpdateStatus status;
  final UpdateInfo? info;
  final String? currentVersion;
  final int? currentBuild;
  final String? error;
}

/// 版本比较（纯函数）：优先比较 buildNumber（等价 versionCode，
/// Android 覆盖安装要求单调递增），build 相同时按语义化版本比较。
bool isNewer(String remoteVersion, int remoteBuild, String localVersion,
    int localBuild) {
  if (remoteBuild != localBuild) return remoteBuild > localBuild;
  final r = _semver(remoteVersion);
  final l = _semver(localVersion);
  for (var i = 0; i < 3; i++) {
    if (r[i] != l[i]) return r[i] > l[i];
  }
  return false;
}

List<int> _semver(String v) {
  final parts = v
      .replaceAll(RegExp(r'[^0-9.]'), '')
      .split('.')
      .map((p) => int.tryParse(p) ?? 0)
      .toList();
  while (parts.length < 3) {
    parts.add(0);
  }
  return parts.take(3).toList();
}

/// 从 build.prop 内容解析首选 ABI（纯函数，可测）。
/// 64 位设备 ro.product.cpu.abi 返回 arm64-v8a；老设备 armeabi-v7a。
String detectAbiFromBuildProp(String content) {
  String? abi;
  String? abiList;
  for (final line in content.split('\n')) {
    final t = line.trim();
    if (t.startsWith('ro.product.cpu.abi=')) {
      abi = t.substring('ro.product.cpu.abi='.length).trim();
    } else if (t.startsWith('ro.product.cpu.abilist=')) {
      abiList = t.substring('ro.product.cpu.abilist='.length).trim();
    }
  }
  final primary = abi ?? abiList?.split(',').first.trim();
  if (primary != null && primary.isNotEmpty) return primary;
  return 'arm64-v8a';
}

/// 应用内更新（仅 Android）：检查 GitHub Release 元数据 →
/// 按 ABI 下载 APK → 交给系统安装器。
/// 固定 keystore 签名保证覆盖安装不丢数据（本地 SQLite / 安全存储保留）。
class UpdateService {
  UpdateService({Dio? dio, this.repo})
      : _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(minutes: 10),
        ));

  final Dio _dio;

  /// GitHub 仓库（owner/repo），从构造或调用处注入
  final String? repo;

  /// update-info.json 固定走 latest release 的下载地址（一次请求拿全）
  Uri infoUri(String repo) => Uri.parse(
      'https://github.com/$repo/releases/latest/download/update-info.json');

  Future<UpdateCheckResult> check({String? repoOverride}) async {
    final r = repoOverride ?? repo;
    if (r == null || r.isEmpty) {
      return const UpdateCheckResult(
          status: UpdateStatus.failed, error: '未配置更新源仓库');
    }
    try {
      final infoRes = await _dio.getUri<Map<String, dynamic>>(infoUri(r),
          options: Options(validateStatus: (_) => true));
      if (infoRes.statusCode != 200 || infoRes.data == null) {
        return const UpdateCheckResult(
            status: UpdateStatus.failed, error: '暂无发布版本');
      }
      final info = UpdateInfo.fromJson(infoRes.data!);
      if (info == null) {
        return const UpdateCheckResult(
            status: UpdateStatus.failed, error: '更新信息格式错误');
      }

      final pkg = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(pkg.buildNumber) ?? 0;
      final hasUpdate =
          isNewer(info.version, info.buildNumber, pkg.version, currentBuild);
      return UpdateCheckResult(
        status:
            hasUpdate ? UpdateStatus.available : UpdateStatus.upToDate,
        info: info,
        currentVersion: pkg.version,
        currentBuild: currentBuild,
      );
    } catch (e) {
      return UpdateCheckResult(
          status: UpdateStatus.failed, error: e.toString());
    }
  }

  /// 当前设备应下载的 APK 地址。
  Future<String?> apkUrlForDevice(UpdateInfo info) async {
    final abi = await deviceAbi();
    // 精确匹配 → abilist 中任一匹配 → 默认 arm64
    if (info.apkUrls.containsKey(abi)) return info.apkUrls[abi];
    for (final url in info.apkUrls.values) {
      return url;
    }
    return null;
  }

  /// 当前设备 ABI（读 /system/build.prop；失败回 arm64-v8a）。
  Future<String> deviceAbi() async {
    if (!Platform.isAndroid) return 'arm64-v8a';
    try {
      final content = await File('/system/build.prop').readAsString();
      return detectAbiFromBuildProp(content);
    } catch (_) {
      return 'arm64-v8a';
    }
  }

  /// 下载 APK 到缓存目录，返回文件。
  Future<File> downloadApk(
    String url,
    String fileName, {
    void Function(int received, int total)? onProgress,
  }) async {
    final dir = Directory.systemTemp;
    final file = File('${dir.path}/$fileName');
    await _dio.download(
      url,
      file.path,
      options: Options(
        // GitHub release 下载会 302 到对象存储
        followRedirects: true,
        maxRedirects: 5,
        receiveTimeout: const Duration(minutes: 30),
      ),
      onReceiveProgress: onProgress,
    );
    return file;
  }

  /// 触发系统安装器（Android 8+ 需用户允许「安装未知应用」）。
  Future<bool> installApk(File file) async {
    final result = await OpenFilex.open(file.path, type: 'application/vnd.android.package-archive');
    return result.type == ResultType.done;
  }
}
