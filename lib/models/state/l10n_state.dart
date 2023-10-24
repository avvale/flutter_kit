import 'package:flutter/widgets.dart';

class L10nState {
  final bool isInitialized;
  final Locale? currentLocale;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final Iterable<Locale>? supportedLocales;

  L10nState({
    required this.isInitialized,
    this.currentLocale,
    this.localizationsDelegates,
    this.supportedLocales,
  });

  L10nState copyWith({
    bool? isInitialized,
    Locale? currentLocale,
    Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates,
    Iterable<Locale>? supportedLocales,
  }) =>
      L10nState(
        isInitialized: isInitialized ?? this.isInitialized,
        currentLocale: currentLocale ?? this.currentLocale,
        localizationsDelegates:
            localizationsDelegates ?? this.localizationsDelegates,
        supportedLocales: supportedLocales ?? this.supportedLocales,
      );
}
