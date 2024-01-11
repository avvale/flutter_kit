import 'package:flutter/widgets.dart';

class FkRoute {
  /// The route path. If it is a mainRoute, it must be '/'
  final String route;

  /// The screen to be displayed when the route is called
  final Widget? screen;

  /// The external URL to be opened when the route is called
  final String? externalUrl;

  FkRoute({
    required this.route,
    this.screen,
    this.externalUrl,
  })  : assert(
          screen != null || externalUrl != null,
          'At least the screen or the external URL must be defined',
        ),
        assert(
          screen == null || externalUrl == null,
          'Only one of the screen or the external URL can be defined',
        );
}

class FkNavigator {
  final String label;
  final FkRoute mainRoute;
  final List<FkRoute>? childRoutes;

  /// Needed when declaring child routes
  final GlobalKey<NavigatorState>? navigator;
  final IconData? icon;
  final String? iconAssetPath;
  final String? iconUrl;
  final Function(BuildContext)? onInit;

  FkNavigator({
    // TODO ¿Es necesario que el label sea requerido?
    required this.label,
    required this.mainRoute,
    this.navigator,
    this.childRoutes,
    this.icon,
    this.iconAssetPath,
    this.iconUrl,
    this.onInit,
  }) : assert(childRoutes == null || navigator != null);
}
