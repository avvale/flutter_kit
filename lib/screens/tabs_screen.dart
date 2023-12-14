import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_kit/models/routing.dart';
import 'package:flutter_kit/models/state/tabs_state.dart';
import 'package:flutter_kit/services/tabs_service.dart';
import 'package:flutter_kit/widgets/layout.dart';
import 'package:flutter_kit/widgets/space.dart';

class TabsScreen extends StatefulWidget {
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
  final void Function(BuildContext context)? onInit;

  const TabsScreen({
    Key? key,
    required this.tabNavigators,
    required this.tabBar,
    this.initialIndex,
    this.statusBarColor,
    this.transparentStatusBar = false,
    this.onInit,
  }) : super(key: key);

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback(
      (_) => widget.onInit?.call(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    TabsService().updateContext(context);

    return NavigatorPopHandler(
      onPop: () async {
        final NavigatorState navigator = Navigator.of(context);

        if (await TabsService().canPopTabs()) {
          navigator.pop();
        }
      },
      child: StreamBuilder(
        stream: TabsService().stream,
        builder: (context, AsyncSnapshot<TabsState?> tabsState) {
          if (!tabsState.hasData || !tabsState.data!.isInitialized) {
            final argsIndex = ModalRoute.of(context)?.settings.arguments;

            TabsService().initialize(
              context,
              widget.tabNavigators,
              argsIndex is int ? argsIndex : widget.initialIndex,
            );

            return const Space();
          }

          final TabsState tabsStateData = tabsState.data!;

          return Layout(
            statusBarColor: widget.statusBarColor,
            transparentStatusBar: widget.transparentStatusBar,
            child: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Stack(
                children: [
                  IndexedStack(
                    index: tabsStateData.selectedIndex,
                    children: List<Widget>.generate(
                      tabsStateData.tabNavigators.length,
                      (index) => HeroControllerScope(
                        controller: MaterialApp.createMaterialHeroController(),
                        child: Navigator(
                          key: tabsStateData.tabNavigators[index].navigator,
                          onGenerateRoute: (RouteSettings settings) =>
                              TabsService().onGenerateRoute(
                            settings,
                            index,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: widget.tabBar(
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
