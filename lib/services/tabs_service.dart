import 'package:flutter/material.dart';
import 'package:flutter_kit/models/routing.dart';
import 'package:flutter_kit/models/state/tabs_state.dart';
import 'package:flutter_kit/utils/debugger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

const initialState = TabsState(
  selectedIndex: 0,
  tabsNavigator: [],
  isInitialized: false,
);

/// Servicio que gestiona el estado de la navegación por tabs
class TabsService {
  static final TabsService _instance = TabsService._internal();

  final _dataFetcher = BehaviorSubject<TabsState>()
    ..startWith(
      initialState,
    );

  TabsState get value =>
      _dataFetcher.hasValue ? _dataFetcher.value : initialState;
  Stream<TabsState> get stream => _dataFetcher.stream;

  factory TabsService() {
    return _instance;
  }

  TabsService._internal();

  final List<int> _initTabs = [];

  _initCurrentTab(BuildContext context) {
    if (!context.mounted) return;

    if (!_initTabs.contains(value.selectedIndex)) {
      Debugger.log('Init tab ${value.selectedIndex}');

      _initTabs.add(value.selectedIndex);

      value.tabsNavigator[value.selectedIndex].onInit?.call(
        context,
      );
    }
  }

  void initialize(BuildContext context, List<FxNavigator> tabsNavigator) {
    final index = ModalRoute.of(context)?.settings.arguments;

    _dataFetcher.add(
      value.copyWith(
        selectedIndex: (index != null && index is int) ? index : 0,
        tabsNavigator: tabsNavigator,
        isInitialized: true,
      ),
    );

    _initCurrentTab(context);
  }

  void updateContext(BuildContext context) {
    _dataFetcher.add(
      value.copyWith(
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
          value.tabsNavigator[index].initialRoute,
          ...value.tabsNavigator[index].routes,
        ].firstWhere((route) => route.route == settings.name).screen,
        settings: settings,
      );

  void navigateTab(
    BuildContext context,
    int newIndex, {
    bool initTab = true,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();

    if (value.selectedIndex == newIndex) {
      value.tabsNavigator[newIndex].navigator.currentState!.popUntil(
        (route) => route.isFirst,
      );
    } else {
      _dataFetcher.add(
        value.copyWith(
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
    final List<FxNavigator> appNavigator = value.tabsNavigator;
    int tabIndex = value.selectedIndex;
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
      value.tabsNavigator[tabIndex].navigator.currentState!.popUntil(
        (route) => route.isFirst,
      );

      navigateTab(context, tabIndex, initTab: initTab);
    }

    return Navigator.of(tabContext).pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  Future<bool> onPopRoute() async {
    final GlobalKey<NavigatorState> navigatorKey =
        value.tabsNavigator[value.selectedIndex].navigator;

    final hasPopped = await navigatorKey.currentState!.maybePop();

    if (!hasPopped && value.selectedIndex != 0) {
      _dataFetcher.add(
        value.copyWith(
          selectedIndex: 0,
        ),
      );

      return Future<bool>.value(false);
    } else {
      return Future<bool>.value(!hasPopped);
    }
  }

  void dispose() {
    _dataFetcher.close();
  }
}
