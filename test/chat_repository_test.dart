import 'package:aivault/data/db/database.dart';
import 'package:aivault/data/db/tables.dart';
import 'package:aivault/data/repositories/chat_repository.dart';
import 'package:aivault/data/repositories/provider_repository.dart';
import 'package:aivault/core/secure_store.dart';
import 'package:drift/native.dart';
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

void main() {
  late AppDatabase db;
  late ChatRepository repo;
  late ProviderRepository providerRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ChatRepository(db);
    providerRepo = ProviderRepository(db, _MemorySecureStore());
  });

  tearDown(() async {
    await db.close();
  });

  Future<Conversation> newConv() async {
    await providerRepo.upsertProvider(
      id: null,
      name: '测试站',
      type: ProviderType.relay,
      adapterKind: AdapterKind.generic,
      baseUrl: 'https://x.example.com',
      accountLabel: '',
    );
    final providerId = (await providerRepo.watchHomeList().first)
        .first
        .provider
        .id;
    await providerRepo.upsertToken(
        id: null, providerId: providerId, name: 'K', apiKey: 'sk-1');
    final token = (await providerRepo.tokensWithModels(providerId))
        .first
        .token;
    return repo.createConversation(
        providerId: providerId, tokenId: token.id, model: 'glm-4');
  }

  test('会话 CRUD + 排序按 updatedAt 倒序', () async {
    final c1 = await newConv();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final c2 = await newConv();

    final list = await repo.allConversations();
    expect(list.first.id, c2.id);
    expect(list.last.id, c1.id);

    await repo.renameConversation(c1.id, '改名');
    expect((await repo.getConversation(c1.id))!.title, '改名');

    await repo.deleteConversation(c1.id);
    expect(await repo.getConversation(c1.id), isNull);
    // 级联删除消息
    expect(await repo.messages(c1.id), isEmpty);
  });

  test('消息按时间升序，autoTitle 截断 20 字', () async {
    final conv = await newConv();
    await repo.appendMessage(
        conversationId: conv.id, role: 'user', content: '第一条');
    await repo.appendMessage(
        conversationId: conv.id, role: 'assistant', content: '回答',
        metadata: {'model': 'glm-4'});

    final msgs = await repo.messages(conv.id);
    expect(msgs.map((m) => m.role).toList(), ['user', 'assistant']);
    expect(msgs[1].metadata, contains('model'));

    await repo.autoTitle(conv.id, '第一条');
    expect((await repo.getConversation(conv.id))!.title, '第一条');

    // 长标题截断
    final conv2 = await newConv();
    final long = 'L' * 40;
    await repo.autoTitle(conv2.id, long);
    final title = (await repo.getConversation(conv2.id))!.title;
    expect(title.length, 21); // 20 字 + 省略号
    expect(title.endsWith('…'), isTrue);

    // 已改名的会话不覆盖
    await repo.autoTitle(conv2.id, '另一个');
    expect((await repo.getConversation(conv2.id))!.title, title);
  });

  test('切换模型并 touch 更新时间', () async {
    final conv = await newConv();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await repo.setModel(conv.id, 'glm-5');
    final after = await repo.getConversation(conv.id);
    expect(after!.model, 'glm-5');
    expect(after.updatedAt.isAfter(conv.updatedAt), isTrue);
  });
}
