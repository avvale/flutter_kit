import 'package:flutter/material.dart';
import 'package:flutter_kit/models/routing.dart';
import 'package:flutter_kit/models/state/tabs_state.dart';
import 'package:flutter_kit/services/tabs_service.dart';
import 'package:flutter_kit/widgets/layout.dart';
import 'package:flutter_kit/widgets/space.dart';

class TabsScreen extends StatelessWidget {
  static const routeName = '/tabs';

  final List<FxNavigator> tabsNavigator;
  final Widget Function(
    List<FxNavigator> navigator,
    int selectedIndex,
    Function(int) onTap,
  ) tabBar;
  final int? initialIndex;
  final Color? statusBarColor;
  final bool transparentStatusBar;
  final double tabBarPadding;

  const TabsScreen({
    Key? key,
    required this.tabsNavigator,
    required this.tabBar,
    this.initialIndex,
    this.statusBarColor,
    this.transparentStatusBar = false,
    this.tabBarPadding = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TabsService().updateContext(context);

    return WillPopScope(
      onWillPop: TabsService().onPopRoute,
      child: StreamBuilder(
        stream: TabsService().stream,
        builder: (context, AsyncSnapshot<TabsState?> tabsState) {
          if (!tabsState.hasData || !tabsState.data!.isInitialized) {
            TabsService().initialize(context, tabsNavigator, initialIndex);

            return const Space();
          }

          final TabsState tabsStateData = tabsState.data!;

          return Layout(
            statusBarColor: statusBarColor,
            transparentStatusBar: transparentStatusBar,
            child: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Stack(
                children: [
                  IndexedStack(
                    index: tabsStateData.selectedIndex,
                    children: List<Widget>.generate(
                      tabsStateData.tabsNavigator.length,
                      (index) => Navigator(
                        key: tabsStateData.tabsNavigator[index].navigator,
                        onGenerateRoute: (RouteSettings settings) =>
                            TabsService().onGenerateRoute(
                          settings,
                          index,
                          tabBarPadding,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: tabBar(
                      tabsStateData.tabsNavigator,
                      tabsStateData.selectedIndex,
                      (i) => TabsService().navigateTab(context, i),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
