import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

abstract class FkRoute {
  final List<FkRoute>? routes;

  FkRoute({
    this.routes,
  });
}

class FkScreenRoute extends FkRoute {
  final String path;
  final Widget screen;

  FkScreenRoute({
    required this.path,
    required this.screen,
    List<FkRoute>? routes,
  }) : super(routes: routes);
}

class FkNestedRoute extends FkRoute {
  final GlobalKey<NavigatorState> key;
  Widget Function(BuildContext, GoRouterState, Widget)? builder;

  FkNestedRoute({
    required this.key,
    this.builder,
    List<FkRoute>? routes,
  }) : super(routes: routes);
}

class FkExternalRoute extends FkRoute {
  final String path;
  final String externalUrl;

  FkExternalRoute({
    required this.path,
    required this.externalUrl,
    List<FkRoute>? routes,
  }) : super(routes: routes);
}

class FkNavigator {
  final GlobalKey<NavigatorState>? key;
  final String initialLocation;
  final List<FkRoute> routes;

  FkNavigator({
    this.key,
    this.initialLocation = '/',
    required this.routes,
  });
}
