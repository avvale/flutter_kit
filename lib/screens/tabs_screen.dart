import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit/models/routing.dart';
import 'package:flutter_kit/models/state/tabs_state.dart';
import 'package:flutter_kit/services/tabs_service.dart';
import 'package:flutter_kit/widgets/space.dart';

class TabsScreen extends StatelessWidget {
  static const routeName = '/tabs';

  final List<FxNavigator> tabsNavigator;
  final Widget Function(
    List<FxNavigator> navigator,
    int selectedIndex,
    Function(int) onTap,
  ) tabBar;
  final Color? statusBarColor;

  const TabsScreen({
    Key? key,
    required this.tabsNavigator,
    required this.tabBar,
    this.statusBarColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TabsService().updateContext(context);

    return WillPopScope(
      onWillPop: TabsService().onPopRoute,
      child: StreamBuilder(
        stream: TabsService().tabsState,
        builder: (context, AsyncSnapshot<TabsState?> tabsState) {
          if (!tabsState.hasData || !tabsState.data!.isInitialized) {
            TabsService().initialize(context, tabsNavigator);

            return const Space();
          }

          final TabsState tabsStateData = tabsState.data!;

          return AnnotatedRegion(
            value: SystemUiOverlayStyle(
              statusBarColor: statusBarColor,
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarIconBrightness: Brightness.light,
            ),
            child: Center(
              child: Scaffold(
                body: SafeArea(
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
