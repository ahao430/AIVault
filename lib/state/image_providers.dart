
import 'package:drift/drift.dart' hide Column;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart' hide Provider;
import '../data/repositories/image_repository.dart';
import '../services/image_service.dart';
import 'app_providers.dart';
import 'chat_providers.dart' show ChatModelOption, chatModelOptionsProvider;

final imageRepoProvider = Provider<ImageRepository>(
    (ref) => ImageRepository(ref.watch(dbProvider)));

final imageServiceProvider = Provider<ImageService>((ref) => ImageService());

/// 画图任务历史
final imageTasksProvider = StreamProvider<List<ImageTask>>(
    (ref) => ref.watch(imageRepoProvider).watchTasks());

/// 画图模型选项：复用全部模型列表，画图类关键词优先
final imageModelOptionsProvider =
    FutureProvider<List<ChatModelOption>>((ref) async {
  final options = await ref.watch(chatModelOptionsProvider.future);
  const keywords = [
    'image', 'dall', 'flux', 'sd3', 'stable', 'cogview', 'diffusion',
    'seedream', 'kolors', 'wanx', 'mj', 'midjourney', 'irag',
  ];
  bool isImageModel(String id) {
    final lower = id.toLowerCase();
    return keywords.any(lower.contains);
  }

  final image = options.where((o) => isImageModel(o.model)).toList();
  final rest = options.where((o) => !isImageModel(o.model)).toList();
  return [...image, ...rest];
});

/// 生成中的状态
class ImageGenerating {
  const ImageGenerating({this.taskId, this.error});

  final String? taskId;
  final String? error;

  bool get generating => taskId != null && error == null;
}

class ImageGenController extends Notifier<ImageGenerating> {
  @override
  ImageGenerating build() => const ImageGenerating();

  /// 执行生成（Plan #26：单次生成任务）。
  Future<void> generate({
    required ChatModelOption option,
    required String prompt,
    required String size,
    required List<(String name, Uint8List bytes)> references,
  }) async {
    if (state.generating) return;
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) {
      state = const ImageGenerating(error: '请输入提示词');
      return;
    }

    final repo = ref.read(imageRepoProvider);
    final db = ref.read(dbProvider);
    final provider = await (db.providers.select()
          ..where((p) => p.id.equals(option.providerId)))
        .getSingle();
    final apiKey =
        await ref.read(repositoryProvider).readApiKey(option.tokenId);
    if (apiKey == null) {
      state = const ImageGenerating(error: '令牌不可用，请重新保存 API Key');
      return;
    }

    final task = await repo.createTask(
      providerId: option.providerId,
      tokenId: option.tokenId,
      model: option.model,
      prompt: trimmed,
      size: size,
      referencePaths: await repo.writeReferences(taskTempId(), references),
    );
    state = ImageGenerating(taskId: task.id);

    final result = await ref.read(imageServiceProvider).generate(
          baseUrl: provider.baseUrl,
          apiKey: apiKey,
          model: option.model,
          prompt: trimmed,
          size: size,
          referenceImages: references,
        );

    if (result.success && result.bytes != null) {
      final file = await repo.writeResult(task.id, result.bytes!);
      await repo.completeTask(task.id, file.uri.pathSegments.last);
      state = const ImageGenerating();
    } else {
      await repo.failTask(task.id, result.error ?? '生成失败');
      state = ImageGenerating(taskId: task.id, error: result.error);
    }
  }

  static String taskTempId() =>
      'tmp-${DateTime.now().microsecondsSinceEpoch}';

  void dismissError() => state = const ImageGenerating();
}

final imageGenProvider =
    NotifierProvider<ImageGenController, ImageGenerating>(
        ImageGenController.new);
