class AuthState {
  final bool isInitialized;
  final String accessToken;
  final String refreshToken;

  const AuthState({
    required this.isInitialized,
    required this.accessToken,
    required this.refreshToken,
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
