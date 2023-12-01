import 'package:flutter/material.dart';
import 'package:flutter_kit/models/routing.dart';
import 'package:flutter_kit/models/state/tabs_state.dart';
import 'package:flutter_kit/services/tabs_service.dart';
import 'package:flutter_kit/widgets/layout.dart';
import 'package:flutter_kit/widgets/space.dart';

class TabsScreen extends StatelessWidget {
  static const routeName = '/tabs';

  final List<FxNavigator> tabNavigators;
  final Widget Function(
    List<FxNavigator> navigator,
    int selectedIndex,
    Function(int) onTap,
  ) tabBar;
  final int? initialIndex;
  final Color? statusBarColor;
  final bool transparentStatusBar;

  const TabsScreen({
    Key? key,
    required this.tabNavigators,
    required this.tabBar,
    this.initialIndex,
    this.statusBarColor,
    this.transparentStatusBar = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TabsService().updateContext(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;

        if (await TabsService().canPopTabs() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: StreamBuilder(
        stream: TabsService().stream,
        builder: (context, AsyncSnapshot<TabsState?> tabsState) {
          if (!tabsState.hasData || !tabsState.data!.isInitialized) {
            TabsService().initialize(context, tabNavigators, initialIndex);

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
                      tabsStateData.tabNavigators.length,
                      (index) => Navigator(
                        key: tabsStateData.tabNavigators[index].navigator,
                        onGenerateRoute: (RouteSettings settings) =>
                            TabsService().onGenerateRoute(
                          settings,
                          index,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: tabBar(
                      tabsStateData.tabNavigators,
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
