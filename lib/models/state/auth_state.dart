class AuthState {
  final bool isInitialized;
  final String accessToken;
  final String refreshToken;

  const AuthState({
    this.isInitialized = false,
    this.accessToken = '',
    this.refreshToken = '',
  });

  AuthState copyWith({
    bool? isInitialized,
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthState(
      isInitialized: isInitialized ?? this.isInitialized,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
