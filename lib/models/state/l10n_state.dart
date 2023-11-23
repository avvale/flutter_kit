import 'package:flutter/widgets.dart';

class L10nState {
  final bool isInitialized;
  final Locale? currentLocale;

  const L10nState({
    this.isInitialized = false,
    this.currentLocale,
  });

  L10nState copyWith({
    bool? isInitialized,
    Locale? currentLocale,
  }) =>
      L10nState(
        isInitialized: isInitialized ?? this.isInitialized,
        currentLocale: currentLocale ?? this.currentLocale,
      );
}
