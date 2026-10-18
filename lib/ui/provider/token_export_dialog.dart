import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/export_links.dart';

/// Token 导出：生成 CC Switch / Magpie 导入链接（Plan #20）。
///
/// 链接包含 API Key，必须明确提示勿发送给他人或公开发布（Plan #20.3）。
Future<void> showTokenExportDialog(
  BuildContext context, {
  required String providerName,
  required String baseUrl,
  required Future<String?> Function() readApiKey,
  required List<String> models,
}) async {
  final apiKey = await readApiKey();
  if (apiKey == null || apiKey.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('没有可用的 API Key')));
    }
    return;
  }
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (_) => _TokenExportDialog(
      providerName: providerName,
      baseUrl: baseUrl,
      apiKey: apiKey,
      models: models,
    ),
  );
}

class _TokenExportDialog extends StatefulWidget {
  const _TokenExportDialog({
    required this.providerName,
    required this.baseUrl,
    required this.apiKey,
    required this.models,
  });

  final String providerName;
  final String baseUrl;
  final String apiKey;
  final List<String> models;

  @override
  State<_TokenExportDialog> createState() => _TokenExportDialogState();
}

class _TokenExportDialogState extends State<_TokenExportDialog> {
  int _target = 0;

  String get _link {
    switch (_target) {
      case 0:
        return ExportLinks.ccSwitch(
          app: CcSwitchApp.claude,
          name: widget.providerName,
          baseUrl: widget.baseUrl,
          apiKey: widget.apiKey,
        );
      case 1:
        return ExportLinks.ccSwitch(
          app: CcSwitchApp.codex,
          name: widget.providerName,
          baseUrl: widget.baseUrl,
          apiKey: widget.apiKey,
        );
      default:
        return ExportLinks.magpie(
          name: widget.providerName,
          baseUrl: widget.baseUrl,
          apiKey: widget.apiKey,
          models: widget.models,
        );
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _link));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('导入链接已复制到剪贴板')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('导出到外部工具'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              children: [
                for (final (i, label) in [
                  'CC Switch · Claude Code',
                  'CC Switch · Codex',
                  'Magpie',
                ].indexed)
                  ChoiceChip(
                    label: Text(label, style: const TextStyle(fontSize: 12)),
                    selected: _target == i,
                    onSelected: (_) => setState(() => _target = i),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 110),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _link,
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 16, color: Colors.orange.shade700),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '此链接包含 API Key，请勿发送给他人或公开发布。',
                    style: TextStyle(
                        fontSize: 12, color: Colors.orange.shade700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭')),
        FilledButton.icon(
          icon: const Icon(Icons.copy, size: 16),
          label: const Text('复制链接'),
          onPressed: _copy,
        ),
      ],
    );
  }
}
