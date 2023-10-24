import 'dart:convert';

import 'package:flutter/material.dart';

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

  switch (x.runtimeType) {
    case String:
      return (x as String).trim().isNotEmpty;
    case List:
      return (x as List).isNotEmpty;
    case Map:
      return (x as Map).isNotEmpty;
    default:
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
