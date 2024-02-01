import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_kit/models/gql_model.dart';
import 'package:flutter_kit/models/router.dart';
import 'package:flutter_kit/models/state/auth_state.dart';
import 'package:go_router/go_router.dart';

Brightness computeColorBrightness(Color color, {bool reverse = false}) {
  final brightness = ThemeData.estimateBrightnessForColor(color);

  return reverse ? reverseBrightness(brightness) : brightness;
}

double computeLuminance(Color color) {
  return (0.2126 * color.red) + (0.7152 * color.green) + (0.0722 * color.blue);
}

Brightness reverseBrightness(Brightness brightness) {
  return brightness == Brightness.dark ? Brightness.light : Brightness.dark;
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }

  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }

  return MaterialColor(color.value, swatch);
}

bool exists(dynamic x) {
  return x != null;
}

bool existsNotEmpty(dynamic x) {
  if (!exists(x)) return false;

  if (x is String) {
    return x.trim().isNotEmpty;
  } else if (x is List) {
    return x.isNotEmpty;
  } else if (x is Map) {
    return x.isNotEmpty;
  } else {
    return true;
  }
}

String? getErrorMessageFromGraphQLError(dynamic error) {
  if (error?.exception?.graphqlErrors.length > 0) {
    if (error?.exception?.graphqlErrors?[0]?.message is String) {
      return (error?.exception?.graphqlErrors?[0]?.message as String).trim();
    }
  } else {
    if (error?.exception?.linkException?.response?.body is String) {
      final List<dynamic>? errors = json.decode(
        error?.exception?.linkException?.response?.body,
      )?['errors'];

      if (errors != null && errors.isNotEmpty) {
        return errors[0]['message'];
      }
    }
  }

  return null;
}

String capitalize(String str) {
  return str[0].toUpperCase() + str.substring(1);
}

List<StatefulShellBranch> generateBranches(
  List<FkRouteTreeBranch> branches,
  FkAuthState authState,
) {
  return branches.map((branch) {
    return StatefulShellBranch(
      navigatorKey: branch.navigatorKey,
      initialLocation: branch.initialLocation,
      routes: generateRoutes(branch.routes, authState),
      observers: branch.observers,
    );
  }).toList();
}

List<RouteBase> generateRoutes(
  List<FkRouteBase> routes,
  FkAuthState authState,
) {
  return routes.map((route) {
    if (route is FkRoute) {
      return GoRoute(
        path: route.path,
        name: route.name,
        builder: route.builder,
        pageBuilder: route.pageBuilder,
        redirect: (context, state) => route.redirect?.call(
          context,
          state,
          authState,
        ),
        routes: generateRoutes(route.routes, authState),
      );
    } else if (route is FkRouteTree) {
      return StatefulShellRoute.indexedStack(
        branches: generateBranches(route.branches, authState),
        builder: route.builder,
        pageBuilder: route.pageBuilder,
      );
    } else {
      throw Exception('Invalid route type');
    }
  }).toList();
}

GoRouter generateRouter(FkRouter fkRouter, FkAuthState authState) {
  return GoRouter(
    navigatorKey: fkRouter.navigatorKey,
    initialLocation: fkRouter.initialLocation,
    routes: generateRoutes(fkRouter.routes, authState),
    redirect: (context, state) => fkRouter.redirect?.call(
      context,
      state,
      authState,
    ),
    onException: fkRouter.onException,
    errorPageBuilder: fkRouter.errorPageBuilder,
    errorBuilder: fkRouter.errorBuilder,
  );
}

String composeRequest(
  GQLModel baseModel, {
  bool addModelName = true,
  List<String>? includes,
}) {
  String request = '';

  if (addModelName) {
    request += '${baseModel.name} {\n';
  }

  request += baseModel.fields.join('\n');

  if (includes != null && includes.isNotEmpty) {
    request += '\n${includes.join('\n')}';
  }

  if (addModelName) {
    request += '\n}';
  }

  return request;
}
