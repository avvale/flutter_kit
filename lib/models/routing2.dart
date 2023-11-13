import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

abstract class FkRoute {
  final String path;
  final String? name;
  final String? label;
  final IconData? icon;
  final String? iconAssetPath;
  final String? iconUrl;
  final List<FkRoute>? routes;
  // TODO: Implement onInit
  // final Function(BuildContext)? onInit;

  FkRoute({
    required this.path,
    this.name,
    this.label,
    this.icon,
    this.iconAssetPath,
    this.iconUrl,
    this.routes,
  });
}

class FkScreenRoute extends FkRoute {
  final Widget screen;

  FkScreenRoute({
    required this.screen,
    required String path,
    String? name,
    String? label,
    IconData? icon,
    String? iconAssetPath,
    String? iconUrl,
    List<FkRoute>? routes,
  }) : super(
          path: path,
          name: name,
          label: label,
          icon: icon,
          iconAssetPath: iconAssetPath,
          iconUrl: iconUrl,
          routes: routes,
        );
}

class FkNestedRoute extends FkRoute {
  final GlobalKey<NavigatorState>? key;
  Widget Function(BuildContext, GoRouterState, Widget)? builder;

  FkNestedRoute({
    this.key,
    this.builder,
    required path,
    String? name,
    String? label,
    IconData? icon,
    String? iconAssetPath,
    String? iconUrl,
    List<FkRoute>? routes,
  }) : super(
          path: path,
          name: name,
          label: label,
          icon: icon,
          iconAssetPath: iconAssetPath,
          iconUrl: iconUrl,
          routes: routes,
        );
}

/// Route config for a route that redirects to an external URL. This route is
/// not rendered in the app nor passed to the router; it is declared only for
/// information purposes and it's logic must be implemented manually.
class FkExternalRoute extends FkRoute {
  final String externalUrl;

  FkExternalRoute({
    required this.externalUrl,
    required path,
    String? name,
    String? label,
    IconData? icon,
    String? iconAssetPath,
    String? iconUrl,
    List<FkRoute>? routes,
  }) : super(
          path: path,
          name: name,
          label: label,
          icon: icon,
          iconAssetPath: iconAssetPath,
          iconUrl: iconUrl,
          routes: routes,
        );
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
