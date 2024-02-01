import 'package:flutter_kit/flutter_kit.dart';
import 'package:flutter_kit/models/auth_mode.dart';
import 'package:flutter/material.dart';
import 'package:riverpod101/utils/router.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  fkRunApp(
    useLocalization: true,
    defaultLang: 'en',
    translationsPath: 'lib/translations',
    supportedLocales: [const Locale('en'), const Locale('es')],
    authMode: const FkManualAuthMode(),
    router: appRouter,
  );
}
