import 'package:graphql/client.dart';

class FkGQLClientState {
  final bool isInitialized;
  final GraphQLClient? gqlClient;
  final GraphQLClient? gqlClientBasicAuth;
  final String? apiUrl;
  final String? authTokenPrefix;

  const FkGQLClientState({
    this.isInitialized = false,
    this.gqlClient,
    this.gqlClientBasicAuth,
    this.apiUrl,
    this.authTokenPrefix,
  });

  FkGQLClientState copyWith({
    bool? isInitialized,
    GraphQLClient? gqlClient,
    GraphQLClient? gqlClientBasicAuth,
    String? apiUrl,
    String? authTokenPrefix,
  }) {
    return FkGQLClientState(
      isInitialized: isInitialized ?? this.isInitialized,
      gqlClient: gqlClient ?? this.gqlClient,
      gqlClientBasicAuth: gqlClientBasicAuth ?? this.gqlClientBasicAuth,
      apiUrl: apiUrl ?? this.apiUrl,
      authTokenPrefix: authTokenPrefix ?? this.authTokenPrefix,
    );
  }
}
