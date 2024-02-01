import 'package:flutter_kit/models/auth_mode.dart';
import 'package:graphql/client.dart';

class FkNetworkState<EndpointT> {
  final bool isInitialized;
  // final GraphQLClient? gqlClient;
  // final GraphQLClient? gqlClientBasicAuth;
  // final String? apiUrl;
  final Map<EndpointT, String>? apiRepository;
  final FkAuthMode authMode;
  final EndpointT? authEndpoint;
  final Map<String, String> apiMappedErrorCodes;
  // final String? authTokenPrefix;

  const FkNetworkState({
    this.isInitialized = false,
    // this.gqlClient,
    // this.gqlClientBasicAuth,
    // this.apiUrl,
    this.apiRepository,
    this.authMode = const FkDisabledAuthMode(),
    this.authEndpoint,
    this.apiMappedErrorCodes = const {},
    // this.authTokenPrefix,
  });

  FkNetworkState copyWith({
    bool? isInitialized,
    // GraphQLClient? gqlClient,
    // GraphQLClient? gqlClientBasicAuth,
    // String? apiUrl,
    Map<EndpointT, String>? apiRepository,
    FkAuthMode? authMode,
    EndpointT? authEndpoint,
    Map<String, String>? apiMappedErrorCodes,
    // String? authTokenPrefix,
  }) {
    return FkNetworkState(
      isInitialized: isInitialized ?? this.isInitialized,
      // gqlClient: gqlClient ?? this.gqlClient,
      // gqlClientBasicAuth: gqlClientBasicAuth ?? this.gqlClientBasicAuth,
      // apiUrl: apiUrl ?? this.apiUrl,
      apiRepository: apiRepository ?? this.apiRepository,
      authMode: authMode ?? this.authMode,
      authEndpoint: authEndpoint ?? this.authEndpoint,
      apiMappedErrorCodes: apiMappedErrorCodes ?? this.apiMappedErrorCodes,
      // authTokenPrefix: authTokenPrefix ?? this.authTokenPrefix,
    );
  }
}
