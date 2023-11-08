// import 'package:flutter/widgets.dart';

// class FxRoute {
//   /// The route path. If it is a mainRoute, it must be '/'
//   final String route;

//   /// The screen to be displayed when the route is called
//   final Widget? screen;

//   /// The external URL to be opened when the route is called
//   final String? externalUrl;

//   FxRoute({
//     required this.route,
//     this.screen,
//     this.externalUrl,
//   })  : assert(
//           screen != null || externalUrl != null,
//           'At least the screen or the external URL must be defined',
//         ),
//         assert(
//           screen == null || externalUrl == null,
//           'Only one of the screen or the external URL can be defined',
//         );
// }

// class FxNavigator {
//   final String label;
//   final FxRoute mainRoute;
//   final List<FxRoute>? childRoutes;

//   /// Needed when declaring child routes
//   final GlobalKey<NavigatorState>? navigator;
//   final IconData? icon;
//   final String? iconAssetPath;
//   final String? iconUrl;
//   final Function(BuildContext)? onInit;

//   FxNavigator({
//     required this.label,
//     required this.mainRoute,
//     this.navigator,
//     this.childRoutes,
//     this.icon,
//     this.iconAssetPath,
//     this.iconUrl,
//     this.onInit,
//   }) : assert(childRoutes == null || navigator != null);
// }
