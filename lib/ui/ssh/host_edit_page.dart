import '../../core/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/ssh_providers.dart';

/// SSH 主机添加 / 编辑（Plan #39）。
/// 优先 SSH Key；首次连接校验 host key（TOFU），不默认无条件信任。
class HostEditPage extends ConsumerStatefulWidget {
  const HostEditPage({super.key, this.hostId});

  final String? hostId;

  @override
  ConsumerState<HostEditPage> createState() => _HostEditPageState();
}

class _HostEditPageState extends ConsumerState<HostEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _hostCtrl = TextEditingController();
  final _portCtrl = TextEditingController(text: '22');
  final _userCtrl = TextEditingController();
  final _secretCtrl = TextEditingController();
  final _passphraseCtrl = TextEditingController();

  String _authType = 'key';
  bool _obscure = true;
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _hostCtrl.dispose();
    _portCtrl.dispose();
    _userCtrl.dispose();
    _secretCtrl.dispose();
    _passphraseCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.hostId == null || _loaded) return;
    _loaded = true;
    final host = await ref.read(sshHostRepoProvider).getHost(widget.hostId!);
    if (host == null || !mounted) return;
    _nameCtrl.text = host.name;
    _hostCtrl.text = host.host;
    _portCtrl.text = '${host.port}';
    _userCtrl.text = host.username;
    setState(() => _authType = host.authType);
  }

  Future<void> _save({bool test = false}) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(sshHostRepoProvider);
      await repo.upsertHost(
        id: widget.hostId,
        name: _nameCtrl.text.trim(),
        host: _hostCtrl.text.trim(),
        port: int.tryParse(_portCtrl.text.trim()) ?? 22,
        username: _userCtrl.text.trim(),
        authType: _authType,
        secret: _secretCtrl.text.trim().isEmpty ? null : _secretCtrl.text.trim(),
        passphrase:
            _passphraseCtrl.text.isEmpty ? null : _passphraseCtrl.text,
      );
      if (test) {
        final host = await repo.getHost(widget.hostId ??
            (await repo.allHosts()).last.id);
        if (host == null) return;
        final result =
            await ref.read(sshServiceProvider).testConnection(host);
        if (!mounted) return;
        Toast.show(context, result.success
                ? '连接成功'
                : '连接失败：${result.error ?? '未知错误'}');
        return;
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _load();
    final isEdit = widget.hostId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '编辑主机' : '添加主机'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _saving ? null : () => _save(),
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('保存'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: '名称', hintText: '例如 Mac Studio / Home Server'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '请输入名称' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _hostCtrl,
              decoration: const InputDecoration(
                labelText: '主机地址',
                hintText: 'Tailscale IP 或 MagicDNS 名称（如 mac-studio.tailnet-xxx.ts.net）',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '请输入主机地址' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _portCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '端口'),
                    validator: (v) {
                      final port = int.tryParse(v ?? '');
                      if (port == null || port < 1 || port > 65535) {
                        return '1-65535';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _userCtrl,
                    decoration: const InputDecoration(labelText: '用户名'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? '请输入用户名' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'key', icon: Icon(Icons.key), label: Text('SSH Key')),
                ButtonSegment(
                    value: 'password',
                    icon: Icon(Icons.password),
                    label: Text('密码')),
              ],
              selected: {_authType},
              onSelectionChanged: (s) => setState(() => _authType = s.first),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _secretCtrl,
              maxLines: _authType == 'key' ? 5 : 1,
              obscureText: _authType == 'password' && _obscure,
              decoration: InputDecoration(
                labelText: _authType == 'key'
                    ? (isEdit ? '私钥（留空保持不变）' : '私钥（PEM）')
                    : (isEdit ? '密码（留空保持不变）' : '密码'),
                helperText: _authType == 'key'
                    ? 'OpenSSH / PEM 格式私钥，加密保存在系统安全存储'
                    : '加密保存在系统安全存储',
                suffixIcon: _authType == 'password'
                    ? IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      )
                    : null,
              ),
              validator: (v) {
                if (!isEdit && (v == null || v.trim().isEmpty)) {
                  return _authType == 'key' ? '请粘贴私钥' : '请输入密码';
                }
                return null;
              },
            ),
            if (_authType == 'key') ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _passphraseCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '私钥口令（可选）',
                  helperText: '私钥没有口令时留空；留空表示不修改',
                ),
              ),
            ],
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: const Icon(Icons.power, size: 18),
              label: const Text('保存并测试连接'),
              onPressed: _saving ? null : () => _save(test: true),
            ),
            const SizedBox(height: 12),
            Text(
              '首次连接将记录服务器指纹（TOFU），之后指纹变化会拒绝连接，'
              '防止中间人攻击。',
              style: TextStyle(
                  fontSize: 11, color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
