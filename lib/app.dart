import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'state/app_providers.dart';
import 'state/lock_providers.dart';
import 'ui/home/home_page.dart';
import 'ui/lock/lock_screen.dart';
import 'ui/settings/settings_page.dart';
import 'ui/workbench/workbench_page.dart';

class AIVaultApp extends StatelessWidget {
  const AIVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIVault',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const LockGate(child: MainShell()),
    );
  }
}

/// 底部固定三个 Tab：首页 / 工作台 / 设置。
/// 每次切回首页立即静默刷新看板（节流见 HomeRefresher）。
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  static const _pages = [
    HomePage(),
    WorkbenchPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
          if (i == 0) {
            ref.read(homeRefresherProvider).refreshNow();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.hub_outlined),
            selectedIcon: Icon(Icons.hub),
            label: '工作台',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}


/// App 锁门卫（Plan #54）：锁定时以锁屏覆盖全部内容。
class LockGate extends ConsumerWidget {
  const LockGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lock = ref.watch(lockProvider);
    if (lock.locked) {
      return const LockScreen();
    }
    return child;
  }
}
