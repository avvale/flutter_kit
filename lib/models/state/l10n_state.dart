import 'package:flutter/widgets.dart';

class FkL10nState {
  final bool isInitialized;
  final Locale? currentLocale;

  const FkL10nState({
    this.isInitialized = false,
    this.currentLocale,
  });

  FkL10nState copyWith({
    bool? isInitialized,
    Locale? currentLocale,
  }) =>
      FkL10nState(
        isInitialized: isInitialized ?? this.isInitialized,
        currentLocale: currentLocale ?? this.currentLocale,
      );
}
