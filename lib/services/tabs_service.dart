import 'package:flutter/material.dart';
import 'package:flutter_kit/models/routing.dart';
import 'package:flutter_kit/models/state/tabs_state.dart';
import 'package:flutter_kit/utils/debugger.dart';
import 'package:flutter_kit/utils/helpers.dart';
import 'package:flutter_kit/widgets/space.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';
import 'package:url_launcher/url_launcher_string.dart';

const initialState = TabsState(
  selectedIndex: 0,
  tabsNavigator: [],
  isInitialized: false,
);

// TODO: actualmente el servicio solo puede gestionar un único conjunto de tabs
// refactorizar para que pueda gestionar varios conjuntos

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

  void initialize(
    BuildContext context,
    List<FxNavigator> tabsNavigator, [
    int? initialIndex,
  ]) {
    final index = initialIndex ?? ModalRoute.of(context)?.settings.arguments;
    final iIndex = (index != null && index is int) ? index : 0;

    _dataFetcher.add(
      value.copyWith(
        selectedIndex: iIndex,
        initialIndex: iIndex,
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
    int index, [
    double bottomPadding = 0,
  ]) {
    final route = [
      value.tabsNavigator[index].mainRoute,
      if (existsNotEmpty(value.tabsNavigator[index].childRoutes))
        ...value.tabsNavigator[index].childRoutes!,
    ].firstWhereOrNull((route) => route.route == settings.name);

    return MaterialPageRoute<dynamic>(
      builder: (context) => route?.screen != null
          ? Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: route!.screen!,
            )
          : const Space(),
      settings: settings,
    );
  }

  void navigateTab(
    BuildContext context,
    int newIndex, {
    bool initTab = true,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (value.selectedIndex == newIndex) {
      bool hasPopped = true;

      // Debugger.log('PRE WHILE', {
      //   'hasPopped': hasPopped,
      //   'context mounted': context.mounted,
      //   'canPop': context.mounted && Navigator.of(context).canPop(),
      // });

      final navState = value.tabsNavigator[newIndex].navigator?.currentState;

      while (navState != null && navState.canPop() && hasPopped) {
        // Debugger.log('WHILE', {
        //   'hasPopped': hasPopped,
        //   'context mounted': context.mounted,
        //   'canPop': context.mounted && Navigator.of(context).canPop(),
        // });

        hasPopped = await navState.maybePop();
      }

      // value.tabsNavigator[newIndex].navigator?.currentState!.popUntil(
      //   (route) => route.isFirst,
      // );
    } else {
      if (value.tabsNavigator[newIndex].mainRoute.external) {
        if (await canLaunchUrlString(
          value.tabsNavigator[newIndex].mainRoute.route,
        )) {
          launchUrlString(value.tabsNavigator[newIndex].mainRoute.route);
        }

        return;
      }

      _dataFetcher.add(value.copyWith(selectedIndex: newIndex));

      if (initTab && context.mounted) _initCurrentTab(context);
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
      appNavigator[tabIndex].mainRoute,
      if (existsNotEmpty(appNavigator[tabIndex].childRoutes))
        ...appNavigator[tabIndex].childRoutes!,
    ].firstWhereOrNull((route) => route.route == routeName)?.screen;

    // Si no se encuentra, se busca en los navigators del resto de tabs
    if (newPage == null) {
      Debugger.log('Route not found in current tab');

      for (int i = 0; i < appNavigator.length; i++) {
        Widget? nestedPage = [
          appNavigator[i].mainRoute,
          if (existsNotEmpty(appNavigator[i].childRoutes))
            ...appNavigator[i].childRoutes!,
        ].firstWhereOrNull((route) => route.route == routeName)?.screen;

        // Utilizamos el index, context y page del tab donde se encuentra la ruta
        if (nestedPage != null) {
          Debugger.log('Route found in tab $i');

          tabIndex = i;
          tabContext = appNavigator[i].navigator?.currentContext! ?? context;
          newPage = nestedPage;
        }
      }

      // Antes de navegar a la ruta se resetea el árbol de navegación del tab
      value.tabsNavigator[tabIndex].navigator?.currentState!.popUntil(
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
    final GlobalKey<NavigatorState>? navigatorKey =
        value.tabsNavigator[value.selectedIndex].navigator;

    final hasPopped = await navigatorKey?.currentState!.maybePop() ?? false;

    if (!hasPopped && value.selectedIndex != value.initialIndex) {
      _dataFetcher.add(
        value.copyWith(
          selectedIndex: value.initialIndex,
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
