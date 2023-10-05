import 'package:flutter/material.dart';

class FxRoute {
  final Widget screen;
  final String route;

  FxRoute({
    required this.screen,
    required this.route,
  });
}

class FxNavigator {
  final String label;
  final GlobalKey<NavigatorState> navigator;
  final FxRoute initialRoute;
  final List<FxRoute> routes;
  final IconData? icon;
  final String? iconAssetPath;
  final String? iconUrl;
  final Function(BuildContext)? onInit;

  FxNavigator({
    required this.label,
    required this.navigator,
    required this.initialRoute,
    required this.routes,
    this.icon,
    this.iconAssetPath,
    this.iconUrl,
    this.onInit,
  });
}
