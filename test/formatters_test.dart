import 'package:aivault/core/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatBytes', () {
    test('基础量级', () {
      expect(formatBytes(512), '512 B');
      expect(formatBytes(2048), '2 KB');
      expect(formatBytes(1_250_000), '1.19 MB'); // 1.19 MiB
    });

    test('1000 GB 进位为 TB，与相邻量级观感一致', () {
      expect(formatBytes(1_073_741_824_000), '0.98 TB');
      expect(formatBytes(1_129_000_000_000), '1.03 TB');
    });

    test('速率后缀', () {
      expect(formatBytes(923, perSecond: true), '923 B/s');
      expect(formatBytes(902_000, perSecond: true), '881 KB/s');
    });
  });

  group('formatUptime', () {
    test('天 / 小时 / 分钟', () {
      expect(formatUptime(45), '45 秒');
      expect(formatUptime(3600 * 5 + 720), '5 小时 12 分');
      expect(formatUptime(86400 * 15), '15 天');
      expect(formatUptime(86400 * 15 + 3600 * 5), '15 天 5 小时');
    });
  });
}
