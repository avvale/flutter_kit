import 'package:flutter_kit/models/auth_mode/auth_mode.dart';
import 'package:graphql/client.dart';

class NetworkState<T> {
  final bool isInitialized;
  final GraphQLClient gqlClient;
  final GraphQLClient gqlClientBasicAuth;
  final String apiUrl;
  final Map<T, String> apiRepository;
  final AuthMode authMode;
  // final String localeCode;
  final T? authEndpoint;
  final Map<String, String> apiMappedErrorCodes;
  final String? authTokenPrefix;

  const NetworkState({
    required this.isInitialized,
    required this.gqlClient,
    required this.gqlClientBasicAuth,
    required this.apiUrl,
    required this.apiRepository,
    required this.authMode,
    // required this.localeCode,
    this.authEndpoint,
    this.apiMappedErrorCodes = const {},
    this.authTokenPrefix,
  });

  NetworkState copyWith({
    bool? isInitialized,
    GraphQLClient? gqlClient,
    GraphQLClient? gqlClientBasicAuth,
    String? apiUrl,
    Map<T, String>? apiRepository,
    AuthMode? authMode,
    // String? localeCode,
    T? authEndpoint,
    Map<String, String>? apiMappedErrorCodes,
    String? authTokenPrefix,
  }) {
    return NetworkState(
      isInitialized: isInitialized ?? this.isInitialized,
      gqlClient: gqlClient ?? this.gqlClient,
      gqlClientBasicAuth: gqlClientBasicAuth ?? this.gqlClientBasicAuth,
      apiUrl: apiUrl ?? this.apiUrl,
      apiRepository: apiRepository ?? this.apiRepository,
      authMode: authMode ?? this.authMode,
      // localeCode: localeCode ?? this.localeCode,
      authEndpoint: authEndpoint ?? this.authEndpoint,
      apiMappedErrorCodes: apiMappedErrorCodes ?? this.apiMappedErrorCodes,
      authTokenPrefix: authTokenPrefix ?? this.authTokenPrefix,
    );
  }
}
