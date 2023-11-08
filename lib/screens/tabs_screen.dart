import 'package:flutter/material.dart';
import 'package:flutter_kit/widgets/layout.dart';

class TabsScreen extends StatelessWidget {
  static const routeName = '/tabs';

  final Widget child;
  final Widget? tabBar;
  final Color? statusBarColor;
  final bool transparentStatusBar;

  const TabsScreen({
    Key? key,
    required this.child,
    this.tabBar,
    this.statusBarColor,
    this.transparentStatusBar = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TabsService().updateContext(context);

    return Layout(
      // onWillPop: TabsService().onWillPop,
      statusBarColor: statusBarColor,
      transparentStatusBar: transparentStatusBar,
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            child,
            if (tabBar != null) Positioned.fill(child: tabBar!),
          ],
        ),
      ),
    );
  }
}
