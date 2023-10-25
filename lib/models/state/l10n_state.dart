import 'package:flutter/widgets.dart';

class L10nState {
  final bool isInitialized;
  final Locale? currentLocale;

  L10nState({
    required this.isInitialized,
    this.currentLocale,
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
      );
}
