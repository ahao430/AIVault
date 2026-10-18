import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../state/app_providers.dart';

/// 添加 / 编辑 Token 的底部弹层。API Key 只写入系统安全存储。
Future<void> showTokenEditSheet(
  BuildContext context, {
  required String providerId,
  Token? token,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _TokenEditSheet(providerId: providerId, token: token),
  );
}

class _TokenEditSheet extends ConsumerStatefulWidget {
  const _TokenEditSheet({required this.providerId, this.token});

  final String providerId;
  final Token? token;

  @override
  ConsumerState<_TokenEditSheet> createState() => _TokenEditSheetState();
}

class _TokenEditSheetState extends ConsumerState<_TokenEditSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _saving = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.token?.name ?? '';
    _noteCtrl.text = widget.token?.note ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _keyCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(repositoryProvider).upsertToken(
            id: widget.token?.id,
            providerId: widget.providerId,
            name: _nameCtrl.text.trim(),
            apiKey: _keyCtrl.text.trim(),
            note: _noteCtrl.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.token != null;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            Text(isEdit ? '编辑令牌' : '添加令牌',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: '名称', hintText: '例如：主力 Key / 备用 Key'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _keyCtrl,
              decoration: InputDecoration(
                labelText: isEdit ? 'API Key（留空保持不变）' : 'API Key',
                hintText: 'sk-...',
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                helperText: '加密保存在系统安全存储（Keychain / Keystore）',
              ),
              obscureText: _obscure,
              validator: (v) {
                if (!isEdit && (v == null || v.trim().isEmpty)) {
                  return '请输入 API Key';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: '备注（可选）'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isEdit ? '保存' : '添加'),
            ),
          ],
        ),
      ),
    );
  }
}
