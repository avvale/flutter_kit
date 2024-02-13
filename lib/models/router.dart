import 'package:flutter/widgets.dart';
import 'package:flutter_kit/models/state/auth_state.dart';
import 'package:flutter_kit/models/state/router_state.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

abstract class FkRouteBase {}

class FkRoute extends FkRouteBase {
  final String path;
  final String? name;
  final Widget Function(BuildContext, GoRouterState)? builder;
  Page<dynamic> Function(BuildContext, GoRouterState)? pageBuilder;
  FutureOr<String?> Function(
    BuildContext,
    GoRouterState,
    FkAuthState?,
  )? redirect;
  List<FkRouteBase> routes = const <FkRouteBase>[];

  FkRoute({
    required this.path,
    this.name,
    this.builder,
    this.pageBuilder,
    this.redirect,
    this.routes = const <FkRouteBase>[],
  });
}

class FkRouteTreeBranch {
  final GlobalKey<NavigatorState>? navigatorKey;
  final String? initialLocation;
  final List<FkRouteBase> routes;
  final List<NavigatorObserver>? observers;

  const FkRouteTreeBranch({
    this.navigatorKey,
    this.initialLocation,
    required this.routes,
    this.observers,
  });
}

class FkRouteTree extends FkRouteBase {
  final List<FkRouteTreeBranch> branches;
  final Widget Function(
    BuildContext,
    GoRouterState,
    StatefulNavigationShell,
  )? builder;
  final Page<dynamic> Function(
    BuildContext,
    GoRouterState,
    StatefulNavigationShell,
  )? pageBuilder;

  FkRouteTree({
    required this.branches,
    this.builder,
    this.pageBuilder,
  });
}

class FkRouter {
  final GlobalKey<NavigatorState>? navigatorKey;
  final String? initialLocation;
  final List<FkRouteBase> routes;
  final FutureOr<String?> Function(
    BuildContext,
    GoRouterState,
    ValueNotifier<FkAuthState>,
    NotifierProviderRef<FkRouterState>,
  )? redirect;
  final void Function(BuildContext, GoRouterState, GoRouter)? onException;
  final Page<dynamic> Function(BuildContext, GoRouterState)? errorPageBuilder;
  final Widget Function(BuildContext, GoRouterState)? errorBuilder;

  const FkRouter({
    this.navigatorKey,
    this.initialLocation,
    required this.routes,
    this.redirect,
    this.onException,
    this.errorPageBuilder,
    this.errorBuilder,
  });
}
