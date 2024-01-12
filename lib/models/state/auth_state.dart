class FkAuthState {
  final bool isInitialized;
  final String accessToken;
  final String refreshToken;

  const FkAuthState({
    this.isInitialized = false,
    this.accessToken = '',
    this.refreshToken = '',
  });

  FkAuthState copyWith({
    bool? isInitialized,
    String? accessToken,
    String? refreshToken,
  }) {
    return FkAuthState(
      isInitialized: isInitialized ?? this.isInitialized,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
