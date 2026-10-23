import 'package:aivault/data/db/database.dart';
import 'package:aivault/data/db/tables.dart';
import 'package:aivault/data/repositories/bookmark_repository.dart';
import 'package:aivault/data/repositories/provider_repository.dart';
import 'package:aivault/services/widget_sync.dart';
import 'package:aivault/state/monitor_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeHomeSections', () {
    test('默认顺序：远程主机 → 探针 → 订阅', () {
      expect(normalizeHomeSections(null), ['remote', 'probes', 'subs']);
    });

    test('合法自定义顺序保留', () {
      expect(normalizeHomeSections(['subs', 'remote', 'probes']),
          ['subs', 'remote', 'probes']);
      expect(normalizeHomeSections(['probes', 'subs']),
          ['probes', 'subs', 'remote']);
    });

    test('未知项剔除、缺失项按默认顺序补尾', () {
      expect(normalizeHomeSections(['subs', 'hack', 'remote']),
          ['subs', 'remote', 'probes']);
      expect(normalizeHomeSections(['probes']), ['probes', 'remote', 'subs']);
    });

    test('重复项去重', () {
      expect(normalizeHomeSections(['subs', 'subs', 'probes']),
          ['subs', 'probes', 'remote']);
      expect(normalizeHomeSections('not-a-list'),
          ['remote', 'probes', 'subs']);
    });
  });

  group('BookmarkRepository.normalizeUrl', () {
    test('缺 scheme 补 https://', () {
      expect(BookmarkRepository.normalizeUrl('example.com'),
          'https://example.com');
      expect(BookmarkRepository.normalizeUrl('example.com/path?q=1'),
          'https://example.com/path?q=1');
    });

    test('http / https 保留原样', () {
      expect(BookmarkRepository.normalizeUrl('http://192.168.1.1:5000'),
          'http://192.168.1.1:5000');
      expect(BookmarkRepository.normalizeUrl('https://a.b.cn/'),
          'https://a.b.cn/');
    });

    test('非法输入返回 null', () {
      expect(BookmarkRepository.normalizeUrl(''), isNull);
      expect(BookmarkRepository.normalizeUrl('   '), isNull);
      expect(BookmarkRepository.normalizeUrl('://x'), isNull);
    });
  });

  group('WidgetSyncService.pick（组件显示开关）', () {
    test('关闭组件显示的供应商不参与挑选', () {
      final states = [
        for (var i = 0; i < 5; i++)
          _fakeState('p$i', showOnWidget: i != 4),
      ];
      final picked = WidgetSyncService.pick(states, 4);
      expect(picked.map((s) => s.provider.id), everyElement(isNot('p4')));
    });

    test('全关时返回空', () {
      final states = [
        for (var i = 0; i < 3; i++) _fakeState('p$i', showOnWidget: false),
      ];
      expect(WidgetSyncService.pick(states, 4), isEmpty);
    });
  });
}

ProviderWithState _fakeState(String id, {required bool showOnWidget}) {
  return ProviderWithState(
    provider: Provider(
      id: id,
      name: id,
      type: ProviderType.relay,
      adapterKind: AdapterKind.newapi,
      baseUrl: '',
      accountLabel: '',
      checkinDisabled: false,
      pinned: false,
      sortOrder: 0,
      hidden: false,
      showOnWidget: showOnWidget,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
    tokenCount: 0,
    modelCount: 0,
  );
}
