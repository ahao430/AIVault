import 'package:drift/drift.dart' hide Column;
import 'package:uuid/uuid.dart';

import '../db/database.dart';

/// 聊天会话仓库：会话 CRUD + 消息追加与监听（只保存本地，Plan #22）。
class ChatRepository {
  ChatRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<Conversation>> watchConversations() {
    return (_db.conversations.select()
          ..orderBy([(c) => OrderingTerm.desc(c.updatedAt)]))
        .watch();
  }

  Future<List<Conversation>> allConversations() =>
      (_db.conversations.select()
            ..orderBy([(c) => OrderingTerm.desc(c.updatedAt)]))
          .get();

  Future<Conversation?> getConversation(String id) =>
      (_db.conversations.select()..where((c) => c.id.equals(id)))
          .getSingleOrNull();

  Stream<Conversation?> watchConversation(String id) {
    return (_db.conversations.select()..where((c) => c.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<Conversation> createConversation({
    required String providerId,
    required String tokenId,
    required String model,
    String title = '新会话',
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    await _db.conversations.insertOne(ConversationsCompanion.insert(
      id: id,
      providerId: providerId,
      tokenId: tokenId,
      model: model,
      title: Value(title),
      createdAt: now,
      updatedAt: now,
    ));
    return getConversation(id).then((c) => c!);
  }

  Future<void> renameConversation(String id, String title) async {
    await (_db.conversations.update()..where((c) => c.id.equals(id)))
        .write(ConversationsCompanion(
            title: Value(title), updatedAt: Value(DateTime.now())));
  }

  Future<void> setModel(String id, String model) async {
    await (_db.conversations.update()..where((c) => c.id.equals(id)))
        .write(ConversationsCompanion(
            model: Value(model), updatedAt: Value(DateTime.now())));
  }

  Future<void> touch(String id) async {
    await (_db.conversations.update()..where((c) => c.id.equals(id)))
        .write(ConversationsCompanion(updatedAt: Value(DateTime.now())));
  }

  Future<void> deleteConversation(String id) async {
    await (_db.conversations.delete()..where((c) => c.id.equals(id))).go();
  }

  Stream<List<Message>> watchMessages(String conversationId) {
    return (_db.messages.select()
          ..where((m) => m.conversationId.equals(conversationId))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .watch();
  }

  Future<List<Message>> messages(String conversationId) {
    return (_db.messages.select()
          ..where((m) => m.conversationId.equals(conversationId))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .get();
  }

  Future<Message> appendMessage({
    required String conversationId,
    required String role,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.messages.insertOne(MessagesCompanion.insert(
      id: id,
      conversationId: conversationId,
      role: role,
      content: content,
      createdAt: now,
      metadata: Value(
          metadata == null ? null : _encodeMetadata(metadata)),
    ));
    await touch(conversationId);
    return Message(
      id: id,
      conversationId: conversationId,
      role: role,
      content: content,
      createdAt: now,
      metadata: metadata == null ? null : _encodeMetadata(metadata),
    );
  }

  /// 首条用户消息自动生成会话标题（前 20 字）。
  Future<void> autoTitle(String conversationId, String firstUserMessage) async {
    final conv = await getConversation(conversationId);
    if (conv == null || conv.title != '新会话') return;
    final title = firstUserMessage.trim();
    await renameConversation(
        conversationId, title.length > 20 ? '${title.substring(0, 20)}…' : title);
  }

  static String _encodeMetadata(Map<String, dynamic> metadata) {
    // 简单 JSON 编码（避免额外依赖）
    return metadata.entries
        .map((e) => '${_esc(e.key)}:${_esc(e.value.toString())}')
        .join('\n');
  }

  static String _esc(String s) =>
      s.replaceAll('\\', '\\\\').replaceAll('\n', '\\n').replaceAll(':', '\\:');
}
