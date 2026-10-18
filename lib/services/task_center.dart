import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/repositories/notification_repository.dart';
import '../data/repositories/provider_repository.dart';
import '../services/local_notifier.dart';
import '../services/notification_engine.dart';
import '../state/app_providers.dart';
import 'provider_actions.dart';

/// 任务状态（Plan #48）
enum TaskStatus { pending, running, success, failed, cancelled }

/// 任务中心条目：批量签到 / 批量预热 / 批量刷新额度。
/// 内存态，保留最近 20 条；App 重启后清空（任务不持久化）。
class TaskItem {
  const TaskItem({
    required this.id,
    required this.type,
    required this.title,
    required this.status,
    required this.total,
    required this.current,
    required this.outcome,
    required this.createdAt,
    this.finishedAt,
  });

  final String id;

  /// batchCheckin / batchPrewarm / batchRefresh
  final String type;
  final String title;
  final TaskStatus status;
  final int total;
  final int current;
  final BatchOutcome outcome;
  final DateTime createdAt;
  final DateTime? finishedAt;

  double get progress => total == 0 ? 0 : current / total;

  bool get running => status == TaskStatus.running;

  TaskItem copyWith({
    TaskStatus? status,
    int? current,
    BatchOutcome? outcome,
    DateTime? finishedAt,
  }) =>
      TaskItem(
        id: id,
        type: type,
        title: title,
        status: status ?? this.status,
        total: total,
        current: current ?? this.current,
        outcome: outcome ?? this.outcome,
        createdAt: createdAt,
        finishedAt: finishedAt ?? this.finishedAt,
      );
}

typedef TaskRunner = Future<(bool ok, String? message)> Function(
    ProviderWithState state);

/// 任务中心控制器：发起批量任务，逐条推进进度，支持取消与重试失败项。
class TaskCenterController extends Notifier<List<TaskItem>> {
  static const _uuid = Uuid();
  final _cancelled = <String>{};

  @override
  List<TaskItem> build() => [];

  ProviderActions get _actions => ref.read(actionsProvider);
  ProviderRepository get _repo => ref.read(repositoryProvider);

  void _update(String id, TaskItem Function(TaskItem t) f) {
    state = [
      for (final t in state)
        if (t.id == id) f(t) else t,
    ];
  }

  TaskItem _create(String type, String title, int total) {
    final task = TaskItem(
      id: _uuid.v4(),
      type: type,
      title: title,
      status: TaskStatus.pending,
      total: total,
      current: 0,
      outcome: const BatchOutcome(),
      createdAt: DateTime.now(),
    );
    state = [task, ...state].take(20).toList();
    return task;
  }

  void cancel(String id) => _cancelled.add(id);

  /// 批量签到：只处理「支持签到 + 今日未签到」的供应商
  Future<void> startCheckInAll(List<ProviderWithState> list) async {
    final targets =
        list.where((s) => s.canCheckIn && !s.checkedInToday).toList();
    if (targets.isEmpty) return;
    await _run('batchCheckin', '批量签到', targets,
        run: (s) => _actions
            .checkIn(s)
            .then((r) => (r.success || r.alreadyCheckedIn, r.message)));
  }

  /// 批量预热：额度满 100% 才执行，状态未知跳过（force=false）
  Future<void> startPrewarmAll(List<ProviderWithState> list) async {
    final targets = list.where((s) => s.canPrewarm).toList();
    if (targets.isEmpty) return;
    await _run('batchPrewarm', '批量预热', targets,
        skip: (s) => s.prewarmReady ? null : '额度未满或状态未知',
        run: (s) => _actions
            .prewarm(s, force: false)
            .then((r) => (r.status == 'executed', r.message ?? r.status)));
  }

  /// 批量刷新额度 / 余额（完成后检测通知事件，Plan #49）
  Future<void> startRefreshAll(List<ProviderWithState> list) async {
    if (list.isEmpty) return;
    final before = {for (final s in list) s.provider.id: s};
    await _run('batchRefresh', '批量刷新额度', list,
        skip: (s) => (s.canQueryQuota || s.canQueryBalance)
            ? null
            : '不支持额度 / 余额查询',
        run: (s) async {
      await _actions.refresh(s);
      return (true, null);
    });
    await _detectNotifications(before, list.map((s) => s.provider.id));
  }

  /// 刷新后对比前后状态产生通知（额度恢复 / 签到可用 / 数据过期）。
  /// 按用户偏好分类过滤；App 内通知中心入库 + 系统通知并行转发。
  Future<void> _detectNotifications(
      Map<String, ProviderWithState> before,
      Iterable<String> providerIds) async {
    try {
      final after = <ProviderWithState>[];
      for (final id in providerIds) {
        final s = await _repo.loadOne(id);
        if (s != null) after.add(s);
      }
      final repo = NotificationRepository(ref.read(dbProvider));
      final prefs =
          await NotificationPrefsStore(ref.read(secureStoreProvider)).load();
      final events = detectEvents(
        before: before,
        after: after,
        sentTodayKinds: await repo.sentTodayKinds(),
      ).where((e) => prefs.allows(e.kind)).toList();
      if (events.isEmpty) return;
      await repo.insertEvents(events);
      if (prefs.systemNotifications) {
        for (final e in events) {
          unawaited(ref
              .read(localNotifierProvider)
              .notify(kind: e.kind, title: e.title, body: e.body));
        }
      }
    } catch (_) {
      // 通知检测失败不影响刷新任务本身
    }
  }

  /// 重试一个任务中失败的供应商。
  Future<void> retryFailed(String taskId) async {
    final task = state.where((t) => t.id == taskId).firstOrNull;
    if (task == null || task.running) return;

    final targets = <ProviderWithState>[];
    for (final id in task.outcome.failedProviderIds) {
      final s = await _repo.loadOne(id);
      if (s != null) targets.add(s);
    }
    if (targets.isEmpty) return;

    _cancelled.remove(taskId);
    await _run(task.type, '${task.title}（重试）', targets,
        run: _runnerFor(task.type));
  }

  TaskRunner _runnerFor(String type) {
    switch (type) {
      case 'batchCheckin':
        return (s) => _actions
            .checkIn(s)
            .then((r) => (r.success || r.alreadyCheckedIn, r.message));
      case 'batchPrewarm':
        return (s) => _actions
            .prewarm(s, force: false)
            .then((r) => (r.status == 'executed', r.message ?? r.status));
      default:
        return (s) async {
          await _actions.refresh(s);
          return (true, null);
        };
    }
  }

  Future<void> _run(
    String type,
    String title,
    List<ProviderWithState> targets, {
    String? Function(ProviderWithState)? skip,
    required TaskRunner run,
  }) async {
    final task = _create(type, title, targets.length);
    _update(task.id, (t) => t.copyWith(status: TaskStatus.running));

    var outcome = const BatchOutcome();
    for (var i = 0; i < targets.length; i++) {
      if (_cancelled.contains(task.id)) {
        _update(task.id, (t) => t.copyWith(
            status: TaskStatus.cancelled, finishedAt: DateTime.now()));
        _cancelled.remove(task.id);
        return;
      }
      final s = targets[i];
      final skipReason = skip?.call(s);
      if (skipReason != null) {
        outcome =
            outcome.add(skipped: true, detail: '${s.provider.name}：$skipReason');
      } else {
        try {
          final (ok, msg) = await run(s);
          outcome = ok
              ? outcome.add(
                  success: true, detail: '${s.provider.name}：${msg ?? '完成'}')
              : outcome.add(
                  failed: true,
                  providerId: s.provider.id,
                  detail: '${s.provider.name}：${msg ?? '失败'}');
        } catch (e) {
          outcome = outcome.add(
              failed: true,
              providerId: s.provider.id,
              detail: '${s.provider.name}：$e');
        }
      }
      _update(task.id, (t) => t.copyWith(current: i + 1, outcome: outcome));
    }

    _update(task.id, (t) => t.copyWith(
          status:
              outcome.failed > 0 ? TaskStatus.failed : TaskStatus.success,
          finishedAt: DateTime.now(),
        ));
  }
}

final taskCenterProvider =
    NotifierProvider<TaskCenterController, List<TaskItem>>(
        TaskCenterController.new);
