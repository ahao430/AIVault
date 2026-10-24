import 'package:aivault/data/db/database.dart';
import 'package:aivault/data/repositories/settings_repository.dart';
import 'package:aivault/data/repositories/webhook_repository.dart';
import 'package:aivault/services/webhook_client.dart';
import 'package:drift/drift.dart' hide Column, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('URL 组装（变量替换 + query 拼接）', () {
    test('路径变量替换 + query 编码', () {
      final url = buildUrl(
        'https://api.example.com/users/{id}/orders',
        const [WebhookVariable(key: 'id', value: '42')],
        const [WebhookKeyValue(key: 'page', value: '1')],
      );
      expect(url, 'https://api.example.com/users/42/orders?page=1');
    });

    test('中文与特殊字符 query 编码；已有 ? 用 & 拼接', () {
      final url = buildUrl(
        'https://a.io/list?q=1',
        const [],
        const [WebhookKeyValue(key: '名字', value: '张三 & 李四')],
      );
      expect(url,
          'https://a.io/list?q=1&%E5%90%8D%E5%AD%97=%E5%BC%A0%E4%B8%89+%26+%E6%9D%8E%E5%9B%9B');
    });

    test('空 key 的 query 跳过；未定义的占位符保留原样', () {
      final url = buildUrl(
        'https://a.io/{miss}',
        const [],
        const [WebhookKeyValue(key: ' ', value: 'x')],
      );
      expect(url, 'https://a.io/{miss}');
    });

    test('变量同时替换 body 文本', () {
      expect(applyVariables('hi {name}, {name}!', const [WebhookVariable(key: 'name', value: '王')]),
          'hi 王, 王!');
    });
  });

  group('Body 序列化', () {
    test('form 字段类型：数字不带引号 / 布尔小写 / 文本字符串', () {
      final s = serializeBody(
        const WebhookBody(
          type: WebhookBodyType.form,
          fields: [
            WebhookFormField(key: 'age', value: '18', fieldType: WebhookFieldType.number),
            WebhookFormField(key: 'ok', value: 'True', fieldType: WebhookFieldType.boolean),
            WebhookFormField(key: 'name', value: 'tom'),
          ],
        ),
        const [],
      )!;
      final j = s;
      expect(j, contains('"age":18'));
      expect(j, contains('"ok":true'));
      expect(j, contains('"name":"tom"'));
    });

    test('json/text 原文透传（含变量替换）；none 返回 null', () {
      expect(
          serializeBody(
              const WebhookBody(type: WebhookBodyType.json, raw: '{"a":"{v}"}'),
              const [WebhookVariable(key: 'v', value: '1')]),
          '{"a":"1"}');
      expect(serializeBody(const WebhookBody(), const []), isNull);
      expect(serializeBody(const WebhookBody(type: WebhookBodyType.text, raw: ''), const []),
          isNull);
    });

    test('Body JSON 往返', () {
      const b = WebhookBody(
        type: WebhookBodyType.form,
        raw: '',
        fields: [WebhookFormField(key: 'k', value: 'v', fieldType: WebhookFieldType.number)],
      );
      final restored = WebhookBody.fromJsonString(b.toJson());
      expect(restored.type, WebhookBodyType.form);
      expect(restored.fields.single.fieldType, WebhookFieldType.number);
      expect(WebhookBody.fromJsonString('not json').type, WebhookBodyType.none);
    });
  });

  group('Headers 组装', () {
    test('按 body 类型补默认 Content-Type；用户设置优先', () {
      final auto = buildHeaders(
          const [],
          const WebhookBody(type: WebhookBodyType.json, raw: '{}'));
      expect(auto['Content-Type'], 'application/json');

      final custom = buildHeaders(
          const [WebhookKeyValue(key: 'content-type', value: 'text/csv')],
          const WebhookBody(type: WebhookBodyType.json, raw: '{}'));
      expect(custom['content-type'], 'text/csv');
      expect(custom.containsKey('Content-Type'), isFalse);
    });
  });

  group('响应解析', () {
    const resp = WebhookResponseView(
        statusCode: 200, durationMs: 12, body: '{"code":0,"message":"ok","data":[1,2]}');

    test('业务 code 与 message', () {
      expect(resp.businessCode, '0');
      expect(resp.businessMessage, 'ok');
      expect(resp.isJson, isTrue);
    });

    test('预览缩进', () {
      expect(resp.prettyBody, contains('\n  "code": 0,'));
    });

    test('非 JSON / 无 code', () {
      const plain = WebhookResponseView(
          statusCode: 404, durationMs: 3, body: 'Not Found');
      expect(plain.isJson, isFalse);
      expect(plain.businessCode, isNull);
      expect(plain.prettyBody, 'Not Found');
    });
  });

  group('历史裁剪（仓库）', () {
    late AppDatabase db;
    late WebhookRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = WebhookRepository(db, SettingsRepository(db));
    });

    tearDown(() async {
      await db.close();
    });

    test('超过上限自动裁剪 + 修改上限生效', () async {
      for (var i = 0; i < 7; i++) {
        await repo.addHistory(
            name: 'r$i',
            method: 'GET',
            url: 'https://a.io/$i',
            statusCode: 200,
            ok: true,
            responsePreview: 'body$i',
            durationMs: i);
      }
      // 默认上限 50 → 7 条都在
      expect((await repo.watchHistory().first).length, 7);

      await repo.setHistoryLimit(3);
      await repo.pruneHistory();
      final after = await repo.watchHistory().first;
      expect(after.length, 3);
      expect(after.map((h) => h.name).toSet(), {'r6', 'r5', 'r4'});

      // addHistory 后也会自动裁剪
      await repo.addHistory(
          name: 'r7',
          method: 'GET',
          url: 'https://a.io/7',
          statusCode: 500,
          ok: false,
          responsePreview: 'err',
          durationMs: 1);
      final finalList = await repo.watchHistory().first;
      expect(finalList.length, 3);
      expect(finalList.first.name, 'r7');
    });

    test('响应预览超 8KB 截断', () async {
      await repo.addHistory(
          name: 'big',
          method: 'GET',
          url: 'https://a.io/big',
          statusCode: 200,
          ok: true,
          responsePreview: 'x' * 10000,
          durationMs: 1);
      final h = (await repo.watchHistory().first).single;
      expect(h.responsePreview!.length, lessThan(9 * 1024));
      expect(h.responsePreview!.contains('已截断'), isTrue);
    });

    test('请求 CRUD', () async {
      final c = WebhookRequestsCompanion.insert(
        id: 'w1',
        name: '测试',
        method: 'POST',
        url: 'https://a.io/{id}',
        variables: Value('[{"key":"id","value":"1"}]'),
        body: Value('{"type":"json","raw":"{\\"a\\":1}"}'),
        createdAt: DateTime(2026, 10, 24),
        updatedAt: DateTime(2026, 10, 24),
      );
      await repo.upsertRequest(c);
      final got = await repo.getRequest('w1');
      expect(got!.name, '测试');
      expect(parseVariables(got.variables).single.key, 'id');
      expect(WebhookBody.fromJsonString(got.body).type, WebhookBodyType.json);

      await repo.deleteRequest('w1');
      expect(await repo.getRequest('w1'), isNull);
    });
  });
}
