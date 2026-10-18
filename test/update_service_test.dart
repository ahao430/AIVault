import 'package:aivault/services/update_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('版本比较（覆盖安装要求单调递增）', () {
    test('build number 优先', () {
      expect(isNewer('0.3.0', 5, '0.3.1', 3), isTrue,
          reason: 'build 更高即可覆盖安装');
      expect(isNewer('0.9.0', 3, '0.3.1', 5), isFalse);
    });

    test('build 相同时按语义化版本', () {
      expect(isNewer('0.4.0', 5, '0.3.9', 5), isTrue);
      expect(isNewer('0.3.9', 5, '0.3.9', 5), isFalse,
          reason: '完全相同不算新版本');
      expect(isNewer('1.0.0', 10, '0.99.99', 10), isTrue);
    });

    test('宽容解析（补齐缺段）', () {
      expect(isNewer('0.4', 5, '0.3.9', 5), isTrue,
          reason: '0.4 视为 0.4.0');
    });

    test('真实场景回归：0.4.4+5 检测 0.4.5+6 必须提示升级', () {
      // 回归保护：手机 0.4.4 (build 5)，远端 0.4.5 (build 6)
      expect(isNewer('0.4.5', 6, '0.4.4', 5), isTrue);
      expect(isNewer('0.4.5', 6, '0.4.5', 6), isFalse);
    });

    test('split-per-abi 的 versionCode 需剥离 ABI 偏移', () {
      // arm64 的 build 6 → versionCode 2006；此前因此误判「已是最新」
      expect(normalizeBuild(2006), 6);
      expect(normalizeBuild(2008), 8);
      expect(normalizeBuild(1006), 6);
      expect(normalizeBuild(3008), 8);
      expect(normalizeBuild(8), 8);
      expect(normalizeBuild(999), 999);
      // 修复后的真实链路：本机 0.4.5 (2006)，远端 0.4.7 (8)
      expect(isNewer('0.4.7', 8, '0.4.5', normalizeBuild(2006)), isTrue);
    });
  });

  group('update-info.json 解析', () {
    test('标准格式', () {
      final info = UpdateInfo.fromJson({
        'version': '0.4.0',
        'buildNumber': 5,
        'notes': '修复若干问题',
        'apkUrls': {
          'arm64-v8a': 'https://github.com/x/releases/download/v1/aivault-arm64-v8a.apk',
          'armeabi-v7a': 'https://github.com/x/releases/download/v1/aivault-armeabi-v7a.apk',
        },
      });
      expect(info, isNotNull);
      expect(info!.version, '0.4.0');
      expect(info.buildNumber, 5);
      expect(info.apkUrls['arm64-v8a'], contains('arm64'));
    });

    test('缺关键字段返回 null', () {
      expect(UpdateInfo.fromJson({'version': '0.4'}), isNull);
      expect(
          UpdateInfo.fromJson(
              {'version': '0.4', 'buildNumber': 'abc'}),
          isNull);
      expect(UpdateInfo.fromJson({}), isNull);
    });

    test('buildNumber 数字字符串也接受', () {
      final info = UpdateInfo.fromJson(
          {'version': '1.0', 'buildNumber': '7', 'apkUrls': {}});
      expect(info!.buildNumber, 7);
    });
  });

  group('更新源仓库地址解析', () {
    test('标准 owner/repo', () {
      expect(normalizeRepo('wanghao/AIVault'), 'wanghao/AIVault');
    });

    test('完整 GitHub URL 提取', () {
      expect(normalizeRepo('https://github.com/wanghao/AIVault'),
          'wanghao/AIVault');
      expect(normalizeRepo('https://github.com/wanghao/AIVault/releases'),
          'wanghao/AIVault');
    });

    test('去掉 .git 后缀与首尾空白', () {
      expect(normalizeRepo('  wanghao/AIVault.git '), 'wanghao/AIVault');
    });

    test('非法格式返回 null', () {
      expect(normalizeRepo(''), isNull);
      expect(normalizeRepo('just-a-name'), isNull);
      expect(normalizeRepo('a/b/c'), isNull);
    });
  });

  group('ABI 检测（build.prop 解析）', () {
    test('64 位设备', () {
      const prop = '''
# comment
ro.product.cpu.abi=arm64-v8a
ro.product.cpu.abilist=arm64-v8a,armeabi-v7a,armeabi
''';
      expect(detectAbiFromBuildProp(prop), 'arm64-v8a');
    });

    test('老 32 位设备', () {
      const prop = '''
ro.product.cpu.abi=armeabi-v7a
ro.product.cpu.abilist=armeabi-v7a,armeabi
''';
      expect(detectAbiFromBuildProp(prop), 'armeabi-v7a');
    });

    test('只有 abilist 时取第一项', () {
      const prop = 'ro.product.cpu.abilist=arm64-v8a,armeabi-v7a\n';
      expect(detectAbiFromBuildProp(prop), 'arm64-v8a');
    });

    test('缺失时回退 arm64（主流设备）', () {
      expect(detectAbiFromBuildProp(''), 'arm64-v8a');
      expect(detectAbiFromBuildProp('ro.build.id=XYZ\n'),
          'arm64-v8a');
    });
  });
}
