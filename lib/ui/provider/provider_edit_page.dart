import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../adapters/registry.dart';
import '../../data/db/tables.dart';
import '../../state/app_providers.dart';

/// 添加 / 编辑供应商。
///
/// 同一供应商的不同账户视为不同供应商实例，通过「账户标识」区分，
/// 例如 Claude - 个人账号 / Claude - 公司账号。
class ProviderEditPage extends ConsumerStatefulWidget {
  const ProviderEditPage({super.key, this.providerId});

  final String? providerId;

  @override
  ConsumerState<ProviderEditPage> createState() => _ProviderEditPageState();
}

class _ProviderEditPageState extends ConsumerState<ProviderEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _baseUrlCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _sysTokenCtrl = TextEditingController();
  final _sysUserCtrl = TextEditingController();

  ProviderType _type = ProviderType.relay;
  AdapterKind _adapter = AdapterKind.newapi;
  bool _checkinDisabled = false;
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _baseUrlCtrl.dispose();
    _accountCtrl.dispose();
    _sysTokenCtrl.dispose();
    _sysUserCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.providerId == null || _initialized) return;
    _initialized = true;
    final db = ref.read(dbProvider);
    final p = await (db.providers.select()
          ..where((t) => t.id.equals(widget.providerId!)))
        .getSingleOrNull();
    if (p == null || !mounted) return;
    _nameCtrl.text = p.name;
    _baseUrlCtrl.text = p.baseUrl;
    _accountCtrl.text = p.accountLabel;
    _sysUserCtrl.text = p.systemUserId ?? '';
    if (p.systemTokenRef != null) {
      final secret = await ref.read(secureStoreProvider).read(p.systemTokenRef!);
      if (mounted) _sysTokenCtrl.text = secret ?? '';
    }
    setState(() {
      _type = p.type;
      _adapter = p.adapterKind;
      _checkinDisabled = p.checkinDisabled;
    });
  }

  void _onTypeChanged(ProviderType type) {
    setState(() {
      _type = type;
      if (type == ProviderType.official) {
        switch (_adapter) {
          case AdapterKind.zhipu:
          case AdapterKind.zhipuAnthropic:
          case AdapterKind.deepseek:
          case AdapterKind.deepseekAnthropic:
          case AdapterKind.claude:
          case AdapterKind.openai:
            break;
          default:
            _adapter = AdapterKind.zhipu;
        }
      } else {
        switch (_adapter) {
          case AdapterKind.newapi:
          case AdapterKind.sub2api:
          case AdapterKind.generic:
            break;
          default:
            _adapter = AdapterKind.newapi;
        }
      }
      _syncPresetBaseUrl();
    });
  }

  /// 官方适配器切换时自动填入预设地址：输入框为空、或当前值是某个
  /// 官方预设（说明是上次自动填的）时才覆盖，不碰用户自定义地址。
  void _syncPresetBaseUrl() {
    final preset = AdapterRegistry.presetBaseUrls[_adapter];
    if (preset == null) return;
    final current = _baseUrlCtrl.text.trim();
    if (current.isEmpty || AdapterRegistry.presetBaseUrls.values.contains(current)) {
      _baseUrlCtrl.text = preset;
    }
  }

  void _onAdapterChanged(AdapterKind? v) {
    setState(() => _adapter = v ?? _adapter);
    _syncPresetBaseUrl();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(repositoryProvider).upsertProvider(
            id: widget.providerId,
            name: _nameCtrl.text.trim(),
            type: _type,
            adapterKind: _adapter,
            baseUrl: _baseUrlCtrl.text.trim(),
            accountLabel: _accountCtrl.text.trim(),
            systemToken: _sysTokenCtrl.text.trim(),
            systemUserId: _sysUserCtrl.text.trim().isEmpty
                ? null
                : _sysUserCtrl.text.trim(),
            checkinDisabled: _checkinDisabled,
          );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _load();
    final isEdit = widget.providerId != null;
    final showSystemToken =
        _adapter == AdapterKind.newapi || _adapter == AdapterKind.sub2api;

    final presetUrl = AdapterRegistry.presetBaseUrls[_adapter];
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '编辑供应商' : '添加供应商'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _saving ? null : _save,
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
            SegmentedButton<ProviderType>(
              segments: const [
                ButtonSegment(
                  value: ProviderType.relay,
                  icon: Icon(Icons.alt_route),
                  label: Text('API 中转站'),
                ),
                ButtonSegment(
                  value: ProviderType.official,
                  icon: Icon(Icons.verified_outlined),
                  label: Text('官方订阅'),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => _onTypeChanged(s.first),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AdapterKind>(
              initialValue: _adapter,
              decoration: const InputDecoration(
                labelText: '适配器',
                helperText: '决定请求格式与额度 / 余额 / 签到 / 预热等能力的实现方式',
              ),
              items: _adapterOptions(),
              onChanged: _onAdapterChanged,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: '名称', hintText: '例如：某某中转站 / Claude'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '请输入名称' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _accountCtrl,
              decoration: const InputDecoration(
                labelText: '账户标识（可选）',
                helperText: '同一供应商的不同账户视为不同实例，如「个人账号」「公司账号」',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _baseUrlCtrl,
              decoration: InputDecoration(
                labelText: 'Base URL',
                helperText: _type == ProviderType.official
                    ? '官方适配器已按所选格式预设，留空即用预设地址'
                    : null,
                hintText: presetUrl ?? 'https://api.example.com 或 https://api.example.com/v1',
              ),
              validator: (v) {
                if (_type == ProviderType.relay &&
                    (v == null || v.trim().isEmpty)) {
                  return '中转站必须填写 Base URL';
                }
                if (v != null && v.trim().isNotEmpty) {
                  final uri = Uri.tryParse(v.trim());
                  if (uri == null || !uri.hasScheme || !uri.isScheme('http') && !uri.isScheme('https')) {
                    return '请输入合法的 http(s) 地址';
                  }
                }
                return null;
              },
            ),
            if (showSystemToken) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _sysTokenCtrl,
                decoration: const InputDecoration(
                  labelText: '系统访问令牌（可选）',
                  helperText: 'NewAPI 控制台「个人设置 → 系统访问令牌」（随机串，'
                      '不是 sk- 开头的 API 密钥），用于余额查询与签到，'
                      '加密保存在系统安全存储',
                  suffixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sysUserCtrl,
                decoration: const InputDecoration(
                  labelText: 'New-Api-User ID（可选）',
                  helperText: '部分 NewAPI 版本接口要求携带用户 ID',
                ),
              ),
            ],
            if (AdapterRegistry.of(_adapter).capabilities.checkIn) ...[
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: const Text('启用签到'),
                subtitle: const Text('站点没有开启签到功能时关闭：隐藏签到入口，批量签到自动跳过'),
                value: !_checkinDisabled,
                onChanged: (v) => setState(() => _checkinDisabled = !v),
              ),
            ],
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('该适配器支持的能力',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    _caps(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<AdapterKind>> _adapterOptions() {
    const relay = [AdapterKind.newapi, AdapterKind.sub2api, AdapterKind.generic];
    const official = [
      AdapterKind.zhipu,
      AdapterKind.zhipuAnthropic,
      AdapterKind.deepseek,
      AdapterKind.deepseekAnthropic,
      AdapterKind.openai,
      AdapterKind.claude,
    ];
    final options = _type == ProviderType.official ? official : relay;
    const labels = {
      AdapterKind.newapi: 'NewAPI 中转站',
      AdapterKind.sub2api: 'Sub2API',
      AdapterKind.generic: '通用 OpenAI 兼容',
      AdapterKind.zhipu: '智谱 Coding Plan（OpenAI 格式）',
      AdapterKind.zhipuAnthropic: '智谱 Coding Plan（Anthropic 格式）',
      AdapterKind.deepseek: 'DeepSeek（OpenAI 格式）',
      AdapterKind.deepseekAnthropic: 'DeepSeek（Anthropic 格式）',
      AdapterKind.openai: 'OpenAI 官方',
      AdapterKind.claude: 'Anthropic / Claude 官方',
    };
    return [
      for (final k in options)
        DropdownMenuItem(value: k, child: Text(labels[k]!)),
    ];
  }

  Widget _caps() {
    final caps = AdapterRegistry.of(_adapter).capabilities;
    final items = <(String, bool)>[
      ('额度查询', caps.quota),
      ('余额查询', caps.balance),
      ('模型列表', caps.models),
      ('模型测试', caps.testModel),
      ('预热', caps.prewarm),
      ('签到', caps.checkIn),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        for (final (label, ok) in items)
          Chip(
            avatar: Icon(
              ok ? Icons.check_circle : Icons.remove_circle_outline,
              size: 16,
              color: ok ? Colors.green : Theme.of(context).colorScheme.outline,
            ),
            label: Text(label, style: const TextStyle(fontSize: 12)),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}
