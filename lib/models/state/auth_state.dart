import 'package:flutter_kit/models/auth_mode.dart';

class FkAuthState {
  final bool isInitialized;
  final FkAuthMode authMode;
  final String accessToken;
  final String refreshToken;

  const FkAuthState({
    this.isInitialized = false,
    this.authMode = const FkDisabledAuthMode(),
    this.accessToken = '',
    this.refreshToken = '',
  });

  FkAuthState copyWith({
    bool? isInitialized,
    FkAuthMode? authMode,
    String? accessToken,
    String? refreshToken,
  }) {
    return FkAuthState(
      isInitialized: isInitialized ?? this.isInitialized,
      authMode: authMode ?? this.authMode,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
