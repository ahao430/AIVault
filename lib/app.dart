import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'ui/home/home_page.dart';
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
      home: const MainShell(),
    );
  }
}

/// 底部固定三个 Tab：首页 / 工作台 / 设置
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
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
        onDestinationSelected: (i) => setState(() => _index = i),
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
