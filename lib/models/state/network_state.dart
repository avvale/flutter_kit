class FkNetworkState<EndpointT> {
  final bool isInitialized;
  final Map<EndpointT, String>? apiRepository;
  final EndpointT? authEndpoint;
  final Map<String, String> apiMappedErrorCodes;

  const FkNetworkState({
    this.isInitialized = false,
    this.apiRepository,
    this.authEndpoint,
    this.apiMappedErrorCodes = const {},
  });

  FkNetworkState copyWith({
    bool? isInitialized,
    Map<EndpointT, String>? apiRepository,
    EndpointT? authEndpoint,
    Map<String, String>? apiMappedErrorCodes,
  }) {
    return FkNetworkState(
      isInitialized: isInitialized ?? this.isInitialized,
      apiRepository: apiRepository ?? this.apiRepository,
      authEndpoint: authEndpoint ?? this.authEndpoint,
      apiMappedErrorCodes: apiMappedErrorCodes ?? this.apiMappedErrorCodes,
    );
  }
}
