import 'package:flutter_kit/models/auth_mode.dart';

class FkNetworkState<EndpointT> {
  final bool isInitialized;
  final Map<EndpointT, String>? apiRepository;
  final FkAuthMode authMode;
  final EndpointT? authEndpoint;
  final Map<String, String> apiMappedErrorCodes;

  const FkNetworkState({
    this.isInitialized = false,
    this.apiRepository,
    this.authMode = const FkDisabledAuthMode(),
    this.authEndpoint,
    this.apiMappedErrorCodes = const {},
  });

  FkNetworkState copyWith({
    bool? isInitialized,
    Map<EndpointT, String>? apiRepository,
    FkAuthMode? authMode,
    EndpointT? authEndpoint,
    Map<String, String>? apiMappedErrorCodes,
  }) {
    return FkNetworkState(
      isInitialized: isInitialized ?? this.isInitialized,
      apiRepository: apiRepository ?? this.apiRepository,
      authMode: authMode ?? this.authMode,
      authEndpoint: authEndpoint ?? this.authEndpoint,
      apiMappedErrorCodes: apiMappedErrorCodes ?? this.apiMappedErrorCodes,
    );
  }
}
