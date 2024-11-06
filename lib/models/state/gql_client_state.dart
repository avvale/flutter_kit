import 'package:graphql/client.dart';

class FkGQLClientState {
  final bool isInitialized;
  final GraphQLClient? gqlClient;
  final GraphQLClient? gqlClientBasicAuth;
  final String? apiUrl;
  final String? authTokenPrefix;
  final Map<String, dynamic>? headers;
  final Duration maxRequestTime;

  const FkGQLClientState({
    this.isInitialized = false,
    this.gqlClient,
    this.gqlClientBasicAuth,
    this.apiUrl,
    this.authTokenPrefix,
    this.headers,
    this.maxRequestTime = const Duration(seconds: 30),
  });

  FkGQLClientState copyWith({
    bool? isInitialized,
    GraphQLClient? gqlClient,
    GraphQLClient? gqlClientBasicAuth,
    String? apiUrl,
    String? authTokenPrefix,
    Map<String, dynamic>? headers,
    Duration? maxRequestTime,
  }) {
    return FkGQLClientState(
      isInitialized: isInitialized ?? this.isInitialized,
      gqlClient: gqlClient ?? this.gqlClient,
      gqlClientBasicAuth: gqlClientBasicAuth ?? this.gqlClientBasicAuth,
      apiUrl: apiUrl ?? this.apiUrl,
      authTokenPrefix: authTokenPrefix ?? this.authTokenPrefix,
      headers: headers ?? this.headers,
      maxRequestTime: maxRequestTime ?? this.maxRequestTime,
    );
  }
}
