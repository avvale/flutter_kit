import 'package:flutter/material.dart';
import 'package:flutter_kit/utils/debugger.dart';
import 'package:go_router/go_router.dart';

class TabsLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<BottomNavigationBarItem> tabs;

  const TabsLayout({
    super.key,
    required this.navigationShell,
    required this.tabs,
  });

  void _goBranch(int index) {
    Debugger.log('_Drawer._goBranch: index=$index');
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          _goBranch(index);
        },
        items: tabs,
      ),
    );
  }
}
