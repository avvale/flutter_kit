import 'package:graphql/client.dart';

class NetworkState<T> {
  final bool isInitialized;
  final GraphQLClient gqlClient;
  final GraphQLClient gqlClientBasicAuth;
  final String apiUrl;
  final Map<T, String> apiRepository;
  final T? authEndpoint;
  final Map<String, String> apiMappedErrorCodes;

  const NetworkState({
    required this.isInitialized,
    required this.gqlClient,
    required this.gqlClientBasicAuth,
    required this.apiUrl,
    required this.apiRepository,
    this.authEndpoint,
    this.apiMappedErrorCodes = const {},
  });

  NetworkState copyWith({
    bool? isInitialized,
    GraphQLClient? gqlClient,
    GraphQLClient? gqlClientBasicAuth,
    String? apiUrl,
    Map<T, String>? apiRepository,
    T? authEndpoint,
    Map<String, String>? apiMappedErrorCodes,
  }) {
    return NetworkState(
      isInitialized: isInitialized ?? this.isInitialized,
      gqlClient: gqlClient ?? this.gqlClient,
      gqlClientBasicAuth: gqlClientBasicAuth ?? this.gqlClientBasicAuth,
      apiUrl: apiUrl ?? this.apiUrl,
      apiRepository: apiRepository ?? this.apiRepository,
      authEndpoint: authEndpoint ?? this.authEndpoint,
      apiMappedErrorCodes: apiMappedErrorCodes ?? this.apiMappedErrorCodes,
    );
  }
}