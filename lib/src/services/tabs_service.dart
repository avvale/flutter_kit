import 'package:flutter/material.dart';
import 'package:flutter_kit/src/models/routing.dart';
import 'package:flutter_kit/src/models/state/tabs_state.dart';
import 'package:flutter_kit/src/utils/debugger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

const initialState = TabsState(
  selectedIndex: 0,
  tabsNavigator: [],
  isInitialized: false,
);

class TabsService {
  static final TabsService _instance = TabsService._internal();
  final _dataFetcher = BehaviorSubject<TabsState>()
    ..startWith(
      initialState,
    );
  final List<int> _initTabs = [];

  TabsState get tabsStateSync =>
      _dataFetcher.hasValue ? _dataFetcher.value : initialState;
  Stream<TabsState> get tabsState => _dataFetcher.stream;

  factory TabsService() {
    return _instance;
  }

  TabsService._internal();

  _initCurrentTab(BuildContext context) {
    if (!context.mounted) return;

    if (!_initTabs.contains(tabsStateSync.selectedIndex)) {
      Debugger.log('Init tab ${tabsStateSync.selectedIndex}');

      _initTabs.add(tabsStateSync.selectedIndex);

      tabsStateSync.tabsNavigator[tabsStateSync.selectedIndex].onInit?.call(
        context,
      );
    }
  }

  void initialize(BuildContext context, List<FxNavigator> tabsNavigator) {
    final index = ModalRoute.of(context)?.settings.arguments;

    _dataFetcher.add(
      tabsStateSync.copyWith(
        selectedIndex: (index != null && index is int) ? index : 0,
        tabsNavigator: tabsNavigator,
        isInitialized: true,
      ),
    );

    _initCurrentTab(context);
  }

  void updateContext(BuildContext context) {
    _dataFetcher.add(
      tabsStateSync.copyWith(
        tabsContext: context,
      ),
    );
  }

  Route onGenerateRoute(
    RouteSettings settings,
    int index,
  ) =>
      MaterialPageRoute<dynamic>(
        builder: (context) => [
          tabsStateSync.tabsNavigator[index].initialRoute,
          ...tabsStateSync.tabsNavigator[index].routes,
        ].firstWhere((route) => route.route == settings.name).screen,
        settings: settings,
      );

  void navigateTab(
    BuildContext context,
    int newIndex, {
    bool initTab = true,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();

    if (tabsStateSync.selectedIndex == newIndex) {
      tabsStateSync.tabsNavigator[newIndex].navigator.currentState!.popUntil(
        (route) => route.isFirst,
      );
    } else {
      _dataFetcher.add(
        tabsStateSync.copyWith(
          selectedIndex: newIndex,
        ),
      );

      if (initTab) _initCurrentTab(context);
    }
  }

  Future<T?> navigateRoute<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool initTab = true,
  }) async {
    final List<FxNavigator> appNavigator = tabsStateSync.tabsNavigator;
    int tabIndex = tabsStateSync.selectedIndex;
    BuildContext tabContext = context;

    // Primero se busca la ruta en el navigator del tab actual
    Widget? newPage = [
      appNavigator[tabIndex].initialRoute,
      ...appNavigator[tabIndex].routes,
    ].firstWhereOrNull((route) => route.route == routeName)?.screen;

    // Si no se encuentra, se busca en los navigators del resto de tabs
    if (newPage == null) {
      Debugger.log('Route not found in current tab');

      for (int i = 0; i < appNavigator.length; i++) {
        Widget? nestedPage = [
          appNavigator[i].initialRoute,
          ...appNavigator[i].routes,
        ].firstWhereOrNull((route) => route.route == routeName)?.screen;

        // Utilizamos el index, context y page del tab donde se encuentra la ruta
        if (nestedPage != null) {
          Debugger.log('Route found in tab $i');

          tabIndex = i;
          tabContext = appNavigator[i].navigator.currentContext!;
          newPage = nestedPage;
        }
      }

      // Antes de navegar a la ruta se resetea el árbol de navegación del tab
      tabsStateSync.tabsNavigator[tabIndex].navigator.currentState!.popUntil(
        (route) => route.isFirst,
      );

      navigateTab(context, tabIndex, initTab: initTab);
    }

    return Navigator.of(tabContext).pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  Future<bool> onPopRoute() {
    final GlobalKey<NavigatorState> navigatorKey =
        tabsStateSync.tabsNavigator[tabsStateSync.selectedIndex].navigator;

    return navigatorKey.currentState!.maybePop().then((hasPopped) {
      if (!hasPopped && tabsStateSync.selectedIndex != 0) {
        _dataFetcher.add(
          tabsStateSync.copyWith(
            selectedIndex: 0,
          ),
        );

        return Future<bool>.value(false);
      } else {
        return Future<bool>.value(!hasPopped);
      }
    });
  }

  void dispose() {
    _dataFetcher.close();
  }
}
