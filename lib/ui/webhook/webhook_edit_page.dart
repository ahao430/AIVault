import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/db/database.dart' hide Provider;
import '../../services/webhook_client.dart';
import '../../state/webhook_providers.dart';

/// 新建 / 编辑 Webhook 请求模板。
/// 方法 / URL / 路径变量 / Query / Headers（含常用预设）/ Body（类型化）。
class WebhookEditPage extends ConsumerStatefulWidget {
  const WebhookEditPage({super.key, this.requestId});

  final String? requestId;

  @override
  ConsumerState<WebhookEditPage> createState() => _WebhookEditPageState();
}

class _WebhookEditPageState extends ConsumerState<WebhookEditPage> {
  static const _methods = [
    'GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS', 'HEAD'
  ];

  // Header 常用预设：一键填入
  static const _headerPresets = [
    ('Content-Type', 'application/json'),
    ('Content-Type', 'application/x-www-form-urlencoded'),
    ('Content-Type', 'text/plain'),
    ('Authorization', 'Bearer '),
    ('Accept', 'application/json'),
    ('Accept', 'text/plain'),
  ];

  final _nameCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _rawBodyCtrl = TextEditingController();

  String _method = 'GET';
  List<WebhookVariable> _variables = [];
  List<WebhookKeyValue> _query = [];
  List<WebhookKeyValue> _headers = [];
  WebhookBody _body = const WebhookBody();

  @override
  void initState() {
    super.initState();
    if (widget.requestId != null) _load();
  }

  Future<void> _load() async {
    final r = await ref.read(webhookRepoProvider).getRequest(widget.requestId!);
    if (!mounted || r == null) return;
    setState(() {
      _nameCtrl.text = r.name;
      _urlCtrl.text = r.url;
      _method = r.method;
      _variables = parseVariables(r.variables);
      _query = parseKeyValueList(r.query);
      _headers = parseKeyValueList(r.headers);
      _body = WebhookBody.fromJsonString(r.body);
      _rawBodyCtrl.text = _body.raw;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    _rawBodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    var url = _urlCtrl.text.trim();
    if (name.isEmpty) {
      _toast('请填写名称');
      return;
    }
    if (url.isEmpty) {
      _toast('请填写 URL');
      return;
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    // json body 语法校验（宽松：空内容跳过）
    if (_body.type == WebhookBodyType.json && _rawBodyCtrl.text.trim().isNotEmpty) {
      // 由调用方自行保证；这里只做占位符提示，不阻塞保存
    }
    final body = WebhookBody(
      type: _body.type,
      raw: _rawBodyCtrl.text,
      fields: _body.fields,
    );
    final repo = ref.read(webhookRepoProvider);
    final now = DateTime.now();
    final existing = widget.requestId == null
        ? null
        : await repo.getRequest(widget.requestId!);
    await repo.upsertRequest(WebhookRequestsCompanion.insert(
      id: existing?.id ?? const Uuid().v4(),
      name: name,
      method: _method,
      url: url,
      variables: Value(encodeVariables(_variables)),
      query: Value(encodeKeyValueList(_query)),
      headers: Value(encodeKeyValueList(_headers)),
      body: Value(body.toJson()),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    ));
    if (mounted) Navigator.pop(context);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.requestId == null ? '新建请求' : '编辑请求'),
        actions: [
          TextButton(
              onPressed: _save, child: const Text('保存')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // 名称 + 方法 + URL
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
                labelText: '名称', hintText: '如：创建用户 / 触发部署'),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownMenu<String>(
                initialSelection: _method,
                width: 118,
                label: const Text('方法'),
                dropdownMenuEntries: [
                  for (final m in _methods)
                    DropdownMenuEntry(value: m, label: m),
                ],
                onSelected: (v) => setState(() => _method = v ?? _method),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    hintText: 'https://api.example.com/users/{id}',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 路径变量
          _SectionCard(
            title: '路径变量（替换 URL / Body 中的 {key}）',
            child: _kvVariableEditor(),
          ),
          const SizedBox(height: 12),

          // Query
          _SectionCard(
            title: 'Query 参数',
            child: _kvEditor(
              entries: _query,
              onChanged: (l) => setState(() => _query = l),
              keyHint: '参数名',
              valueHint: '值（字符串）',
            ),
          ),
          const SizedBox(height: 12),

          // Headers
          _SectionCard(
            title: 'Headers',
            trailing: PopupMenuButton<String>(
              tooltip: '常用 Header 预设',
              icon: const Icon(Icons.bolt_outlined, size: 18),
              onSelected: (v) {
                final i = v.indexOf('\u0000');
                setState(() => _headers = [
                      ..._headers,
                      WebhookKeyValue(
                          key: v.substring(0, i), value: v.substring(i + 1)),
                    ]);
              },
              itemBuilder: (_) => [
                for (final (k, val) in _headerPresets)
                  PopupMenuItem(
                      value: '$k\u0000$val',
                      child: Text('$k: $val',
                          style: const TextStyle(
                              fontSize: 13, fontFamily: 'monospace'))),
              ],
            ),
            child: _kvEditor(
              entries: _headers,
              onChanged: (l) => setState(() => _headers = l),
              keyHint: 'Header 名',
              valueHint: '值（字符串）',
            ),
          ),
          const SizedBox(height: 12),

          // Body
          _SectionCard(
            title: 'Body',
            child: _bodyEditor(cs),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _kvVariableEditor() {
    return Column(
      children: [
        for (var i = 0; i < _variables.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller:
                        TextEditingController(text: _variables[i].key)
                          ..selection = TextSelection.fromPosition(
                              TextPosition(
                                  offset: _variables[i].key.length)),
                    decoration:
                        const InputDecoration(hintText: '变量名，如 id'),
                    onChanged: (v) => _variables[i] =
                        WebhookVariable(key: v, value: _variables[i].value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller:
                        TextEditingController(text: _variables[i].value)
                          ..selection = TextSelection.fromPosition(
                              TextPosition(
                                  offset: _variables[i].value.length)),
                    decoration: const InputDecoration(hintText: '默认值'),
                    onChanged: (v) => _variables[i] =
                        WebhookVariable(key: _variables[i].key, value: v),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                  onPressed: () => setState(
                      () => _variables.removeAt(i)),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add, size: 16),
            label: const Text('加变量', style: TextStyle(fontSize: 13)),
            onPressed: () => setState(
                () => _variables.add(const WebhookVariable(key: '', value: ''))),
          ),
        ),
      ],
    );
  }

  Widget _kvEditor({
    required List<WebhookKeyValue> entries,
    required void Function(List<WebhookKeyValue>) onChanged,
    required String keyHint,
    required String valueHint,
  }) {
    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: TextEditingController(text: entries[i].key)
                      ..selection = TextSelection.fromPosition(
                          TextPosition(offset: entries[i].key.length)),
                    decoration: InputDecoration(hintText: keyHint),
                    onChanged: (v) {
                      entries[i] =
                          WebhookKeyValue(key: v, value: entries[i].value);
                      onChanged(entries);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: TextEditingController(text: entries[i].value)
                      ..selection = TextSelection.fromPosition(
                          TextPosition(offset: entries[i].value.length)),
                    decoration: InputDecoration(hintText: valueHint),
                    onChanged: (v) {
                      entries[i] =
                          WebhookKeyValue(key: entries[i].key, value: v);
                      onChanged(entries);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                  onPressed: () {
                    entries.removeAt(i);
                    onChanged(List.of(entries));
                  },
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add, size: 16),
            label: const Text('添加一行', style: TextStyle(fontSize: 13)),
            onPressed: () =>
                onChanged([...entries, const WebhookKeyValue(key: '', value: '')]),
          ),
        ),
      ],
    );
  }

  Widget _bodyEditor(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<WebhookBodyType>(
          segments: const [
            ButtonSegment(value: WebhookBodyType.none, label: Text('无')),
            ButtonSegment(value: WebhookBodyType.json, label: Text('JSON')),
            ButtonSegment(value: WebhookBodyType.form, label: Text('表单')),
            ButtonSegment(value: WebhookBodyType.text, label: Text('文本')),
          ],
          selected: {_body.type},
          showSelectedIcon: false,
          onSelectionChanged: (v) =>
              setState(() => _body = WebhookBody(type: v.first)),
        ),
        const SizedBox(height: 10),
        switch (_body.type) {
          WebhookBodyType.none => Text('该请求不携带 body（GET / DELETE 常用）',
              style: TextStyle(fontSize: 12, color: cs.outline)),
          WebhookBodyType.json ||
          WebhookBodyType.text =>
            TextField(
              controller: _rawBodyCtrl,
              maxLines: 6,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5),
              decoration: InputDecoration(
                hintText: _body.type == WebhookBodyType.json
                    ? '{"name": "{user}", "age": 18}'
                    : '原始文本，支持 {变量} 占位',
                filled: true,
                fillColor: cs.surfaceContainerLow,
              ),
            ),
          WebhookBodyType.form => _formFieldsEditor(),
        },
      ],
    );
  }

  Widget _formFieldsEditor() {
    return Column(
      children: [
        for (var i = 0; i < _body.fields.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller:
                        TextEditingController(text: _body.fields[i].key)
                          ..selection = TextSelection.fromPosition(
                              TextPosition(offset: _body.fields[i].key.length)),
                    decoration: const InputDecoration(hintText: '字段名'),
                    onChanged: (v) => _updateField(
                        i,
                        WebhookFormField(
                            key: v,
                            value: _body.fields[i].value,
                            fieldType: _body.fields[i].fieldType)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller:
                        TextEditingController(text: _body.fields[i].value)
                          ..selection = TextSelection.fromPosition(
                              TextPosition(
                                  offset: _body.fields[i].value.length)),
                    decoration: const InputDecoration(hintText: '值'),
                    onChanged: (v) => _updateField(
                        i,
                        WebhookFormField(
                            key: _body.fields[i].key,
                            value: v,
                            fieldType: _body.fields[i].fieldType)),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownMenu<WebhookFieldType>(
                  initialSelection: _body.fields[i].fieldType,
                  width: 86,
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(
                        value: WebhookFieldType.string, label: '文本'),
                    DropdownMenuEntry(
                        value: WebhookFieldType.number, label: '数字'),
                    DropdownMenuEntry(
                        value: WebhookFieldType.boolean, label: '布尔'),
                  ],
                  onSelected: (v) => _updateField(
                      i,
                      WebhookFormField(
                          key: _body.fields[i].key,
                          value: _body.fields[i].value,
                          fieldType: v ?? WebhookFieldType.string)),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                  onPressed: () => setState(() {
                    final f = [..._body.fields]..removeAt(i);
                    _body = WebhookBody(
                        type: _body.type, raw: _body.raw, fields: f);
                  }),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add, size: 16),
            label: const Text('加字段', style: TextStyle(fontSize: 13)),
            onPressed: () => setState(() => _body = WebhookBody(
                type: _body.type,
                raw: _body.raw,
                fields: [
                  ..._body.fields,
                  const WebhookFormField(key: '', value: ''),
                ])),
          ),
        ),
      ],
    );
  }

  void _updateField(int i, WebhookFormField f) {
    final list = [..._body.fields];
    list[i] = f;
    setState(() =>
        _body = WebhookBody(type: _body.type, raw: _body.raw, fields: list));
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard(
      {required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.outline)),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
