// TODO: actualmente el servicio solo puede gestionar un único conjunto de tabs, refactorizar para que pueda gestionar varios conjuntos

import 'package:flutter/material.dart';
import 'package:flutter_kit/models/routing.dart';
import 'package:flutter_kit/models/state/tabs_state.dart';
import 'package:flutter_kit/utils/debugger.dart';
import 'package:flutter_kit/utils/helpers.dart';
import 'package:flutter_kit/widgets/space.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';
import 'package:url_launcher/url_launcher_string.dart';

const initialState = TabsState();

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
    if (!_initTabs.contains(value.selectedIndex)) {
      Debugger.log('Init tab ${value.selectedIndex}');

      _initTabs.add(value.selectedIndex);

      value.tabNavigators[value.selectedIndex].onInit?.call(context);
    }
  }

  // TODO ajustar, no funciona correctamente
  _popRoot(NavigatorState? navState) async {
    // if (navState == null) return;

    // Antigua funcionalidad
    // navState.popUntil(
    //   (route) => route.isFirst,
    // );

    // Nuevo approach - se espera que maybePop devuelva false cuando no se
    // permita retroceder, pero llega true
    // if (navState.canPop()) {
    //   bool hasPopped = await navState.maybePop();

    //   Debugger.log('Pop root: $hasPopped');

    //   if (hasPopped) {
    //     _popRoot(navState);
    //   }
    // }
  }

  void updateContext(BuildContext context) {
    _dataFetcher.add(
      value.copyWith(
        tabsContext: context,
      ),
    );
  }

  void initialize(
    BuildContext context,
    List<FxNavigator> tabNavigators, [
    int? initialIndex,
  ]) {
    final index = initialIndex ?? ModalRoute.of(context)?.settings.arguments;
    final i = (index is int) ? index : 0;

    _dataFetcher.add(
      value.copyWith(
        selectedIndex: i,
        initialIndex: i,
        tabNavigators: tabNavigators,
        isInitialized: true,
      ),
    );

    _initCurrentTab(context);
  }

  /// Devuelve la ruta correspondiente al nombre de ruta y tab recibidos
  Route onGenerateRoute(RouteSettings settings, int index) {
    final route = [
      value.tabNavigators[index].mainRoute,
      if (existsNotEmpty(value.tabNavigators[index].childRoutes))
        ...value.tabNavigators[index].childRoutes!,
    ].firstWhere((route) => route.route == settings.name);

    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (context) =>
          route.screen != null ? route.screen! : const Space(),
    );
  }

  /// Comprueba si se puede retroceder en el árbol de navegación del tab actual.
  /// Si se puede, devuelve false para evitar retroceder en los tabs. Si no se
  /// puede, comprueba si el tab actual es el inicial. Si no lo es, se navega
  /// al tab inicial. Si lo es, devuelve true para permitir retroceder en los
  /// tabs.
  Future<bool> canPopTabs() async {
    // Navigator del tab actual
    final NavigatorState? currentTabNavigator =
        value.tabNavigators[value.selectedIndex].navigator?.currentState;

    // TODO actualmente canPop siempre devuelve true, por lo que nunca entra en
    // la segunda condición y en caso de que el sea la pantalla raíz del tab
    // actual, se cierra la app
    if (currentTabNavigator != null && currentTabNavigator.canPop()) {
      // Realiza un intento de retroceder en el navigator del tab actual,
      // llamando si existe a la función onWillPop de la pantalla visible
      currentTabNavigator.maybePop();

      return false;
    } else {
      if (value.selectedIndex != value.initialIndex) {
        _dataFetcher.add(value.copyWith(selectedIndex: value.initialIndex));

        return false;
      } else {
        return true;
      }
    }
  }

  // Navigation logic between tabs. If the tab has an externalUrl, it will be
  // launched in the browser. Otherwise, the tab will be selected.
  void navigateTab(
    BuildContext context,
    int newIndex, {
    bool initTab = true,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (value.selectedIndex == newIndex) {
      _popRoot(value.tabNavigators[newIndex].navigator?.currentState);
    } else {
      if (value.tabNavigators[newIndex].mainRoute.externalUrl != null) {
        if (await canLaunchUrlString(
          value.tabNavigators[newIndex].mainRoute.externalUrl!,
        )) {
          launchUrlString(value.tabNavigators[newIndex].mainRoute.externalUrl!);
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
    final List<FxNavigator> appNavigator = value.tabNavigators;
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
      value.tabNavigators[tabIndex].navigator?.currentState!.popUntil(
        (route) => route.isFirst,
      );

      navigateTab(context, tabIndex, initTab: initTab);
    }

    return Navigator.of(tabContext).pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  void dispose() {
    _dataFetcher.close();
  }
}
