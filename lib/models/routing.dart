import 'package:flutter/widgets.dart';

class FxRoute {
  final String route;
  final Widget? screen;
  final bool external;

  FxRoute({
    required this.route,
    this.screen,
    this.external = false,
  }) : assert(external || screen != null);
}

class FxNavigator {
  final String label;
  final FxRoute mainRoute;
  final List<FxRoute>? childRoutes;

  // Needed when declaring child routes
  final GlobalKey<NavigatorState>? navigator;
  final IconData? icon;
  final String? iconAssetPath;
  final String? iconUrl;
  final Function(BuildContext)? onInit;

  FxNavigator({
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
