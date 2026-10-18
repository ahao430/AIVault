import 'package:aivault/adapters/provider_adapter.dart';
import 'package:aivault/core/secure_store.dart';
import 'package:aivault/data/db/database.dart';
import 'package:aivault/data/db/tables.dart';
import 'package:aivault/data/repositories/provider_repository.dart';
import 'package:aivault/services/provider_actions.dart';
import 'package:aivault/services/task_center.dart';
import 'package:aivault/state/app_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemorySecureStore implements SecureStore {
  final Map<String, String> _map = {};

  @override
  Future<String?> read(String ref) async => _map[ref];

  @override
  Future<void> write(String ref, String value) async => _map[ref] = value;

  @override
  Future<void> delete(String ref) async => _map.remove(ref);
}

/// 假 actions：checkIn 按 provider 名决定成败，prewarm 一律 executed
class _FakeActions extends ProviderActions {
  _FakeActions(super.repo);

  @override
  Future<CheckinResult> checkIn(ProviderWithState state) async {
    if (state.provider.name.contains('坏')) {
      throw Exception('网络错误');
    }
    return CheckinResult(success: true, message: '签到成功');
  }

  @override
  Future<PrewarmResult> prewarm(ProviderWithState state,
      {bool force = false}) async {
    return const PrewarmResult(status: 'executed', message: '预热完成');
  }
}

void main() {
  late AppDatabase db;
  late _MemorySecureStore secure;
  late ProviderRepository repo;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    secure = _MemorySecureStore();
    repo = ProviderRepository(db, secure);
    container = ProviderContainer(overrides: [
      repositoryProvider.overrideWithValue(repo),
      actionsProvider.overrideWithValue(_FakeActions(repo)),
    ]);
    addTearDown(container.dispose);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> add(String name) async {
    await repo.upsertProvider(
      id: null,
      name: name,
      type: ProviderType.relay,
      adapterKind: AdapterKind.newapi,
      baseUrl: 'https://$name.example.com',
      accountLabel: '',
    );
  }

  test('批量签到：成功 / 失败推进，任务状态与明细正确', () async {
    await add('好站1');
    await add('坏站');
    await add('好站2');

    final list = await repo.watchHomeList().first;
    final controller = container.read(taskCenterProvider.notifier);
    await controller.startCheckInAll(list);

    final tasks = container.read(taskCenterProvider);
    expect(tasks, hasLength(1));
    final task = tasks.first;
    expect(task.status, TaskStatus.failed); // 有一个失败
    expect(task.current, 3);
    expect(task.outcome.success, 2);
    expect(task.outcome.failed, 1);
    expect(task.outcome.failedProviderIds, hasLength(1));
    final joined = task.outcome.details.join('\n');
    expect(joined, contains('好站1：签到成功'));
    expect(joined, contains('好站2：签到成功'));
    expect(
        joined, contains('坏站'));
    expect(joined, contains('网络错误'));
  });

  test('重试失败项：生成新任务只含失败供应商', () async {
    await add('坏站');
    await add('好站');

    final list = await repo.watchHomeList().first;
    final controller = container.read(taskCenterProvider.notifier);
    await controller.startCheckInAll(list);

    final first = container.read(taskCenterProvider).first;
    final failedId = first.outcome.failedProviderIds.single;
    final before = (await repo.loadOne(failedId))!.provider.name;
    expect(before, '坏站');

    // 重试（仍然会失败：FakeActions 恒失败，但任务应只含 1 个目标）
    await controller.retryFailed(first.id);
    final retryTask = container.read(taskCenterProvider).first;
    expect(retryTask.title, contains('重试'));
    expect(retryTask.total, 1);
    expect(retryTask.status, TaskStatus.failed);
  });

  test('批量预热跳过额度未满的供应商', () async {
    await add('官方站'); // newapi 类型无预热能力，先改成 official 语义上不匹配
    // 用 zhipu（支持预热）创建
    await repo.upsertProvider(
      id: null,
      name: '智谱A',
      type: ProviderType.official,
      adapterKind: AdapterKind.zhipu,
      baseUrl: 'https://open.bigmodel.cn',
      accountLabel: '',
    );

    final list = await repo.watchHomeList().first;
    final controller = container.read(taskCenterProvider.notifier);
    await controller.startPrewarmAll(list);

    final task = container.read(taskCenterProvider).first;
    // 智谱A 无额度快照（状态未知）→ 跳过
    expect(task.outcome.skipped, 1);
    expect(task.status, TaskStatus.success);
  });
}
