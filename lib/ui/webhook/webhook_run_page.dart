import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/toast.dart';
import '../../data/db/database.dart' hide Provider;
import '../../services/webhook_client.dart';
import '../../state/webhook_providers.dart';
import 'webhook_edit_page.dart';
import 'webhooks_page.dart';

/// 执行页：顶部可改路径变量（默认取保存值）→ 发送 →
/// 响应面板（HTTP 状态徽章 + 业务 code + 预览/Raw 双 Tab）。
class WebhookRunPage extends ConsumerStatefulWidget {
  const WebhookRunPage({super.key, required this.request});

  final WebhookRequest request;

  @override
  ConsumerState<WebhookRunPage> createState() => _WebhookRunPageState();
}

class _WebhookRunPageState extends ConsumerState<WebhookRunPage> {
  late List<WebhookVariable> _variables;
  WebhookResponseView? _result;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _variables = parseVariables(widget.request.variables);
    // 无变量时自动执行一次（列表点进来直接看结果）
    if (_variables.where((v) => v.key.isNotEmpty).isEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _send());
    }
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    final req = widget.request;
    final vars = _variables;
    final url =
        buildUrl(req.url, vars, parseKeyValueList(req.query));
    final body = WebhookBody.fromJsonString(req.body);
    final bodyStr = serializeBody(body, vars);
    final headers = buildHeaders(parseKeyValueList(req.headers), body);

    final result = await sendWebhookRequest(
      method: req.method,
      url: url,
      headers: headers,
      body: bodyStr,
    );

    // 写入历史（成功 / 失败都记）
    await ref.read(webhookRepoProvider).addHistory(
          requestId: req.id,
          name: req.name,
          method: req.method,
          url: url,
          requestBody: bodyStr,
          statusCode: result.statusCode,
          ok: (result.statusCode ?? 0) >= 200 &&
              (result.statusCode ?? 0) < 300,
          responsePreview: result.errorMessage ?? result.body,
          durationMs: result.durationMs,
        );

    if (!mounted) return;
    setState(() {
      _result = result;
      _sending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final req = widget.request;
    final hasVars = _variables.any((v) => v.key.isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        title: Text(req.name, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            tooltip: '复制 URL',
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () async {
              final url = buildUrl(req.url, _variables,
                  parseKeyValueList(req.query));
              await Clipboard.setData(ClipboardData(text: url));
              if (!context.mounted) return;
              Toast.show(context, 'URL 已复制');
            },
          ),
          IconButton(
            tooltip: '编辑',
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => WebhookEditPage(requestId: req.id),
            )),
          ),
        ],
      ),
      body: Column(
        children: [
          // 请求概要
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            color: cs.surfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MethodBadge(method: req.method),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        buildUrl(
                            req.url, _variables, parseKeyValueList(req.query)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11.5, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
                if (hasVars) ...[
                  const SizedBox(height: 8),
                  for (var i = 0; i < _variables.length; i++)
                    if (_variables[i].key.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text('{${_variables[i].key}}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                      color: cs.primary)),
                            ),
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(
                                    text: _variables[i].value)
                                  ..selection =
                                      TextSelection.fromPosition(TextPosition(
                                          offset:
                                              _variables[i].value.length)),
                                style: const TextStyle(fontSize: 13),
                                decoration: const InputDecoration(
                                    isDense: true,
                                    hintText: '值'),
                                onChanged: (v) => _variables[i] =
                                    WebhookVariable(
                                        key: _variables[i].key, value: v),
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ],
            ),
          ),
          // 发送按钮
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _sending ? null : _send,
                icon: _sending
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_outlined, size: 16),
                label: Text(_sending ? '请求中…' : '发送'),
              ),
            ),
          ),
          // 响应
          Expanded(child: _buildResponse(cs)),
        ],
      ),
    );
  }

  Widget _buildResponse(ColorScheme cs) {
    final r = _result;
    if (r == null && !_sending) {
      return Center(
          child: Text('点「发送」查看响应',
              style: TextStyle(color: cs.outline)));
    }
    if (r == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final ok = (r.statusCode ?? 0) >= 200 && (r.statusCode ?? 0) < 300;
    final biz = r.businessCode;
    final bizOk = int.tryParse(biz ?? '') == null
        ? null
        : (int.parse(biz!) == 0 || int.parse(biz) == 200);
    return Column(
      children: [
        // 状态行：HTTP 状态 + 业务 code + 耗时
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: (ok ? Colors.green : Colors.red).withValues(alpha: 0.06),
          child: Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusBadge(statusCode: r.statusCode),
              if (biz != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (bizOk ?? false ? Colors.green : Colors.orange)
                        .withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('业务 code: $biz',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: bizOk ?? false
                              ? Colors.green
                              : Colors.orange)),
                ),
              Text('${r.durationMs} ms',
                  style: TextStyle(fontSize: 11, color: cs.outline)),
              if (r.errorMessage != null)
                Text(r.errorMessage!,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.red)),
              if (r.businessMessage != null)
                Text(r.businessMessage!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: cs.outline)),
            ],
          ),
        ),
        // 预览 / Raw 双面板
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [Tab(text: '预览'), Tab(text: 'Raw')],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // 预览：JSON 缩进；非 JSON 原文
                      _ResponsePanel(
                          text: r.body.isEmpty
                              ? '（空响应体）'
                              : r.prettyBody,
                          monospace: true),
                      _ResponsePanel(
                          text: r.body.isEmpty ? '（空响应体）' : r.body,
                          monospace: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ResponsePanel extends StatelessWidget {
  const _ResponsePanel({required this.text, this.monospace = false});

  final String text;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 10, 44, 16),
          child: SelectableText(
            text,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              fontFamily: monospace ? 'monospace' : null,
              color: cs.onSurface,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            tooltip: '复制',
            iconSize: 16,
            icon: Icon(Icons.copy, size: 15, color: cs.outline),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) Toast.show(context, '已复制');
            },
          ),
        ),
      ],
    );
  }
}
