import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/toast.dart';
import '../../state/monitor_providers.dart';

/// 添加 / 编辑监控站点（Komari）。
/// 保存前先实测 /api/nodes 连通性，避免存入打不开的地址。
class MonitorSiteEditPage extends ConsumerStatefulWidget {
  const MonitorSiteEditPage({super.key, this.siteId});

  final int? siteId;

  @override
  ConsumerState<MonitorSiteEditPage> createState() =>
      _MonitorSiteEditPageState();
}

class _MonitorSiteEditPageState extends ConsumerState<MonitorSiteEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _url = TextEditingController();
  final _token = TextEditingController();

  bool _showOnHome = true;
  bool _hasToken = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.siteId != null) {
      final site = ref
          .read(monitorSitesProvider)
          .value
          ?.where((s) => s.id == widget.siteId)
          .firstOrNull;
      if (site != null) {
        _name.text = site.name;
        _url.text = site.baseUrl;
        _showOnHome = site.showOnHome;
        _hasToken = site.apiTokenRef != null;
        if (_hasToken) {
          _token.text = '········';
        }
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    _token.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(monitorRepoProvider);

    // token：编辑时占位符 ········ = 不修改
    final placeholder = _token.text == '········';
    final token = placeholder && widget.siteId != null
        ? null // 不修改
        : _token.text.trim();

    // 保存前先实测连通性（失败给出原因，可强制保存）
    final error = await repo.testSite(_url.text.trim(), token);
    if (error != null && mounted) {
      final force = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('站点测试未通过'),
          content: Text('$error\n\n仍要保存吗？保存后可稍后再试。'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('返回修改')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('仍然保存')),
          ],
        ),
      );
      if (force != true) {
        if (mounted) setState(() => _saving = false);
        return;
      }
    }

    if (widget.siteId == null) {
      final id = await repo.addSite(
        name: _name.text.trim(),
        baseUrl: _url.text.trim(),
        token: token,
        showOnHome: _showOnHome,
      );
      // 新站点立即拉一次数据
      final site = await repo.getSite(id);
      if (site != null) await repo.refresh(site);
    } else {
      await repo.updateSite(
        id: widget.siteId!,
        name: _name.text.trim(),
        baseUrl: _url.text.trim(),
        token: token,
        showOnHome: _showOnHome,
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);
    Toast.show(context, '已保存');
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除站点'),
        content: Text('确定删除「${_name.text}」？缓存的节点数据将一并删除。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('删除')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(monitorRepoProvider).deleteSite(widget.siteId!);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.siteId == null ? '添加监控站点' : '编辑监控站点'),
        actions: [
          if (widget.siteId != null)
            IconButton(
              tooltip: '删除站点',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: '站点名称',
                hintText: '如：我的监控站',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '请输入名称' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _url,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: '站点地址（Komari 面板）',
                hintText: 'https://status.example.com',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final u = v?.trim() ?? '';
                if (u.isEmpty) return '请输入地址';
                if (!u.startsWith('http://') && !u.startsWith('https://')) {
                  return '需以 http(s):// 开头';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _token,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'API Token（选填）',
                helperText: _hasToken
                    ? '已设置。留空提交 = 清除；输入新值 = 替换'
                    : '公开站点无需填写；私有站点填管理员 API Key（Bearer）',
                helperMaxLines: 2,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('在首页探针区显示'),
              subtitle: Text('关闭后仅在工作台管理，首页不占位',
                  style: TextStyle(fontSize: 12, color: cs.outline)),
              value: _showOnHome,
              onChanged: (v) => setState(() => _showOnHome = v),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('保存（先测试连接）'),
            ),
            const SizedBox(height: 24),
            Text(
              '当前支持 Komari（github.com/komari-monitor）。'
              '数据来源：/api/nodes + /api/recent，Token 仅保存在本机安全存储。',
              style: TextStyle(fontSize: 12, color: cs.outline),
            ),
          ],
        ),
      ),
    );
  }
}
