import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/secure_store.dart';

/// 更新源仓库（owner/repo）解析优先级：
/// 1. 构建时注入：--dart-define=GITHUB_REPO=owner/repo（发版 workflow 自动传）
/// 2. 用户在检查更新页手动配置（存安全存储）
/// 3. 未配置：提示无法检查
const kGithubRepoDefine = String.fromEnvironment('GITHUB_REPO');

String? normalizeRepo(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return null;
  // 容错：完整 URL / 缺 owner 的输入
  var s = t;
  final m = RegExp(r'github\.com/([^/]+/[^/]+)').firstMatch(s);
  if (m != null) s = m.group(1)!;
  s = s.replaceAll('.git', '');
  if (!RegExp(r'^[\w.-]+/[\w.-]+$').hasMatch(s)) return null;
  return s;
}

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
    this.via,
  });

  final UpdateStatus status;
  final UpdateInfo? info;
  final String? currentVersion;
  final int? currentBuild;
  final String? error;

  /// 信息来源：直连 / 镜像域名（排查镜像缓存问题时用）
  final String? via;
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
  UpdateService({Dio? dio, this.repo, SecureStore? secureStore})
      : _secureStore = secureStore,
        _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(minutes: 10),
        ));

  final Dio _dio;
  final SecureStore? _secureStore;
  static const _kRepoPref = 'update:repo';

  /// GitHub 仓库（owner/repo），测试 / 显式注入用
  final String? repo;

  /// 生效的更新源：dart-define > 用户配置 > 构造注入。
  Future<String?> effectiveRepo() async {
    if (kGithubRepoDefine.isNotEmpty) return kGithubRepoDefine;
    final saved = await _secureStore?.read(_kRepoPref);
    final normalized = saved == null ? null : normalizeRepo(saved);
    if (normalized != null) return normalized;
    return repo;
  }

  Future<void> saveUserRepo(String raw) async {
    final normalized = normalizeRepo(raw);
    if (normalized == null) {
      throw ArgumentError('仓库地址格式应为 owner/repo');
    }
    await _secureStore?.write(_kRepoPref, normalized);
  }

  /// update-info.json 固定走 latest release 的下载地址（一次请求拿全）
  Uri infoUri(String repo) => Uri.parse(
      'https://github.com/$repo/releases/latest/download/update-info.json');

  /// GitHub 直连在国内移动网络常不可达（开 VPN 才通）。依次尝试直连与
  /// 公共加速镜像前缀；镜像风格为「前缀 + 完整原始 URL」。
  static const _dlMirrors = [
    '', // 直连
    'https://ghfast.top/',
    'https://gh-proxy.com/',
  ];

  Future<UpdateCheckResult> check({String? repoOverride}) async {
    final r = repoOverride ?? await effectiveRepo();
    if (r == null || r.isEmpty) {
      return const UpdateCheckResult(
          status: UpdateStatus.failed, error: '未配置更新源仓库');
    }
    dynamic raw;
    String? via;
    try {
      var gotResponse = false;
      // latest/download 是可变地址，公共镜像会缓存旧内容（刚发版后
      // 常见）：带时间戳查询参数穿透缓存，保证拿到最新发布信息。
      final bust = DateTime.now().millisecondsSinceEpoch;
      for (final mirror in _dlMirrors) {
        try {
          // update-info.json 由 Release 资产 CDN 下发，Content-Type 是
          // octet-stream，dio 不会自动解码 → 拿到的是 String，手动 decode。
          final infoRes = await _dio.getUri<dynamic>(
              Uri.parse('$mirror${infoUri(r)}?t=$bust'),
              options: Options(validateStatus: (_) => true));
          gotResponse = true;
          if (infoRes.statusCode == 404) break; // 有发布但无 info，重试无意义
          if (infoRes.statusCode != 200 || infoRes.data == null) continue;
          raw = infoRes.data;
          if (raw is String) raw = jsonDecode(raw);
          if (raw is Map) {
            via = mirror.isEmpty ? '直连' : mirror;
            break;
          }
        } catch (_) {
          // 网络不通 → 试下一个镜像
        }
      }
      if (raw is! Map) {
        return UpdateCheckResult(
            status: UpdateStatus.failed,
            error: gotResponse ? '更新信息格式错误' : '无法连接更新源（GitHub 与镜像均不通）');
      }
      final info = UpdateInfo.fromJson(Map<String, dynamic>.from(raw));
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
        via: via,
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

  /// 下载 APK 到缓存目录，返回文件。直连失败时依次走镜像。
  Future<File> downloadApk(
    String url,
    String fileName, {
    void Function(int received, int total)? onProgress,
  }) async {
    final dir = Directory.systemTemp;
    final file = File('${dir.path}/$fileName');
    Object? lastError;
    for (final mirror in _dlMirrors) {
      try {
        await _dio.download(
          '$mirror$url',
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
      } catch (e) {
        lastError = e;
        // 换镜像前清掉半截文件
        if (await file.exists()) await file.delete().catchError((_) => file);
      }
    }
    throw Exception('下载失败（GitHub 与镜像均不通）：$lastError');
  }

  /// 触发系统安装器（Android 8+ 需用户允许「安装未知应用」）。
  Future<bool> installApk(File file) async {
    final result = await OpenFilex.open(file.path, type: 'application/vnd.android.package-archive');
    return result.type == ResultType.done;
  }
}
