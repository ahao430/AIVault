import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drift/drift.dart' hide Column;

import '../data/db/database.dart' hide Provider;
import '../data/repositories/chat_repository.dart';
import '../services/chat_service.dart';
import 'app_providers.dart';

final chatRepoProvider = Provider<ChatRepository>(
    (ref) => ChatRepository(ref.watch(dbProvider)));

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

/// 会话列表
final conversationsProvider = StreamProvider<List<Conversation>>(
    (ref) => ref.watch(chatRepoProvider).watchConversations());

/// 单个会话
final conversationProvider = StreamProvider.autoDispose
    .family<Conversation?, String>(
        (ref, id) => ref.watch(chatRepoProvider).watchConversation(id));

/// 会话消息
final conversationMessagesProvider = StreamProvider.autoDispose
    .family<List<Message>, String>(
        (ref, id) => ref.watch(chatRepoProvider).watchMessages(id));

/// 可选模型：所有供应商令牌下的模型（供新会话 / 切换模型）
class ChatModelOption {
  const ChatModelOption({
    required this.providerId,
    required this.tokenId,
    required this.model,
    required this.label,
  });

  final String providerId;
  final String tokenId;
  final String model;
  final String label;

  @override
  bool operator ==(Object other) =>
      other is ChatModelOption &&
      other.providerId == providerId &&
      other.tokenId == tokenId &&
      other.model == model;

  @override
  int get hashCode => Object.hash(providerId, tokenId, model);
}

Future<List<ChatModelOption>> _loadModelOptions(AppDatabase db) async {
  // 个人订阅数据量小，三次简单查询在内存组装，避免 join API 兼容问题
  final providers = await db.providers.select().get();
  final tokens = await db.tokens.select().get();
  final models = await db.providerModels.select().get();
  final providerById = {for (final p in providers) p.id: p};
  final tokenById = {for (final t in tokens) t.id: t};
  final options = <ChatModelOption>[];
  for (final m in models) {
    final token = tokenById[m.tokenId];
    final provider = token == null ? null : providerById[token.providerId];
    if (token == null || provider == null) continue;
    options.add(ChatModelOption(
      providerId: provider.id,
      tokenId: token.id,
      model: m.modelId,
      label: '${provider.name} · ${m.modelId}',
    ));
  }
  options.sort((a, b) => a.label.compareTo(b.label));
  return options;
}

final chatModelOptionsProvider =
    FutureProvider<List<ChatModelOption>>((ref) async {
  final db = ref.watch(dbProvider);
  return _loadModelOptions(db);
});

/// 生成中的会话状态（每会话一个）
class ChatGenerating {
  const ChatGenerating({
    this.conversationId,
    this.content = '',
    this.reasoning = '',
    this.error,
    this.stopped = false,
  });

  final String? conversationId;
  final String content;
  final String reasoning;
  final String? error;
  final bool stopped;

  bool get generating => conversationId != null && error == null && !stopped;

  ChatGenerating copyWith({
    String? conversationId,
    String? content,
    String? reasoning,
    String? error,
    bool? stopped,
    bool clearConversation = false,
    bool clearError = false,
  }) =>
      ChatGenerating(
        conversationId:
            clearConversation ? null : (conversationId ?? this.conversationId),
        content: content ?? this.content,
        reasoning: reasoning ?? this.reasoning,
        error: clearError ? null : (error ?? this.error),
        stopped: stopped ?? this.stopped,
      );
}

/// 单一生成槽：同一时间只有一个流式生成（简单可靠）。
class ChatSessionController extends Notifier<ChatGenerating> {
  CancelToken? _cancelToken;

  @override
  ChatGenerating build() {
    ref.onDispose(() => _cancelToken?.cancel());
    return const ChatGenerating();
  }

  bool isGenerating(String conversationId) =>
      state.conversationId == conversationId && state.generating;

  Future<void> send(String conversationId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.generating) return;

    final repo = ref.read(chatRepoProvider);
    final db = ref.read(dbProvider);

    await repo.appendMessage(
        conversationId: conversationId, role: 'user', content: trimmed);
    await repo.autoTitle(conversationId, trimmed);

    final conv = await repo.getConversation(conversationId);
    if (conv == null) return;
    final provider = await (db.providers.select()
          ..where((p) => p.id.equals(conv.providerId)))
        .getSingle();
    final apiKey = await ref.read(repositoryProvider).readApiKey(conv.tokenId);
    if (apiKey == null) {
      state = const ChatGenerating(
          conversationId: '', error: '令牌不可用，请重新保存 API Key');
      return;
    }

    // 历史上下文（最近 20 条）
    final history = await repo.messages(conversationId);
    final chatMessages = [
      for (final m in history.take(20))
        ChatMessage(role: m.role, content: m.content),
    ];

    state = ChatGenerating(conversationId: conversationId);
    _cancelToken = CancelToken();

    final result = await ref.read(chatServiceProvider).streamChat(
          baseUrl: provider.baseUrl,
          apiKey: apiKey,
          model: conv.model,
          messages: chatMessages,
          cancelToken: _cancelToken,
          onDelta: (delta) {
            if (state.conversationId != conversationId) return;
            state = state.copyWith(
              content:
                  '${state.content}${delta.content ?? ''}',
              reasoning:
                  '${state.reasoning}${delta.reasoning ?? ''}',
            );
          },
        );

    if (result.error != null) {
      state = ChatGenerating(
          conversationId: conversationId, error: result.error);
    } else {
      final content = result.content.trim();
      if (content.isNotEmpty) {
        await repo.appendMessage(
          conversationId: conversationId,
          role: 'assistant',
          content: content,
          metadata: {
            'model': conv.model,
            if (result.cancelled) 'cancelled': 'true',
          },
        );
      }
      state = const ChatGenerating();
    }
  }

  /// 停止生成：保留已生成部分。
  void stop() {
    _cancelToken?.cancel();
    state = state.copyWith(stopped: true);
  }

  void dismissError() {
    state = const ChatGenerating();
  }
}

final chatSessionProvider =
    NotifierProvider<ChatSessionController, ChatGenerating>(
        ChatSessionController.new);
