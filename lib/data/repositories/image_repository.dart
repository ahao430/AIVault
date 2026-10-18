import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';

/// 画图任务仓库：任务 CRUD + 图片文件管理（app 图片目录内，DB 存相对路径）。
class ImageRepository {
  ImageRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// app 图片根目录（懒创建）
  Future<Directory> imageRoot() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'ai_images'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> absolutePath(String relative) async =>
      p.join((await imageRoot()).path, relative);

  Future<File> writeResult(String taskId, Uint8List bytes) async {
    final root = await imageRoot();
    final file = File(p.join(root.path, '$taskId.png'));
    await file.writeAsBytes(bytes);
    return file;
  }

  /// 保存参考图，返回相对路径列表
  Future<List<String>> writeReferences(
      String taskId, List<(String name, Uint8List bytes)> refs) async {
    final root = await imageRoot();
    final dir = Directory(p.join(root.path, 'refs', taskId));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final paths = <String>[];
    for (final ref in refs) {
      final ext = p.extension(ref.$1).isEmpty ? '.png' : p.extension(ref.$1);
      final file = File(p.join(dir.path, '${_uuid.v4()}$ext'));
      await file.writeAsBytes(ref.$2);
      paths.add(p.relative(file.path, from: root.path));
    }
    return paths;
  }

  Stream<List<ImageTask>> watchTasks() {
    return (_db.imageTasks.select()
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<ImageTask?> getTask(String id) =>
      (_db.imageTasks.select()..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<ImageTask> createTask({
    required String providerId,
    required String tokenId,
    required String model,
    required String prompt,
    required String size,
    List<String> referencePaths = const [],
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.imageTasks.insertOne(ImageTasksCompanion.insert(
      id: id,
      providerId: providerId,
      tokenId: tokenId,
      model: model,
      prompt: prompt,
      status: 'running',
      referencePaths: Value(referencePaths.join('\n')),
      params: Value('size:$size'),
      createdAt: now,
      updatedAt: now,
    ));
    return getTask(id).then((t) => t!);
  }

  Future<void> completeTask(String id, String resultPath) async {
    await (_db.imageTasks.update()..where((t) => t.id.equals(id))).write(
        ImageTasksCompanion(
            status: const Value('success'),
            resultPath: Value(resultPath),
            updatedAt: Value(DateTime.now())));
  }

  Future<void> failTask(String id, String error) async {
    await (_db.imageTasks.update()..where((t) => t.id.equals(id))).write(
        ImageTasksCompanion(
            status: const Value('failed'),
            errorMessage: Value(error),
            updatedAt: Value(DateTime.now())));
  }

  Future<void> deleteTask(String id) async {
    final task = await getTask(id);
    if (task == null) return;
    // 删除结果与参考图文件
    if (task.resultPath != null) {
      final f = File(await absolutePath(task.resultPath!));
      if (await f.exists()) await f.delete();
    }
    if (task.referencePaths.isNotEmpty) {
      for (final rel in task.referencePaths.split('\n')) {
        if (rel.isEmpty) continue;
        final f = File(await absolutePath(rel));
        if (await f.exists()) await f.delete();
      }
    }
    await (_db.imageTasks.delete()..where((t) => t.id.equals(id))).go();
  }

  /// 任务尺寸参数
  static String sizeOf(ImageTask task) {
    final params = task.params ?? '';
    for (final line in params.split('\n')) {
      if (line.startsWith('size:')) return line.substring(5);
    }
    return '1024x1024';
  }
}
