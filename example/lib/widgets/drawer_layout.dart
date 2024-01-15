import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_kit/utils/debugger.dart';

class _Drawer extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _Drawer({Key? key, required this.navigationShell}) : super(key: key);

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
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Drawer Header',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Home Screen'),
            onTap: () {
              _goBranch(0);
              Scaffold.of(context).openEndDrawer();
            },
          ),
          ListTile(
            title: const Text('Screen 1'),
            onTap: () {
              _goBranch(1);
              Scaffold.of(context).openEndDrawer();
            },
          ),
          ListTile(
            title: const Text('Screen 2'),
            onTap: () {
              _goBranch(2);
              Scaffold.of(context).openEndDrawer();
            },
          ),
          ListTile(
            title: const Text('Screen 3'),
            onTap: () {
              _goBranch(3);
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
    );
  }
}

class DrawerLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DrawerLayout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawer Layout'),
      ),
      drawer: _Drawer(navigationShell: navigationShell),
      body: navigationShell,
    );
  }
}
