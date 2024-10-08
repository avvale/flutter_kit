import 'dart:io';
import 'package:flutter_kit/models/auth_mode.dart';
import 'package:flutter_kit/models/state/network_state.dart';
import 'package:flutter_kit/providers/auth_provider.dart';
import 'package:flutter_kit/providers/gql_client_provider.dart';
import 'package:flutter_kit/utils/debugger.dart';
import 'package:flutter_kit/utils/helpers.dart';
import 'package:flutter_kit/utils/toast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_provider.g.dart';

enum FkRequestType {
  query,
  mutation,
}

const _initialState = FkNetworkState();

@Riverpod(keepAlive: true)
class Network extends _$Network {
  @override
  FkNetworkState build() => _initialState;

  // Default GraphQL error handler
  Future<QueryResult> _handleError<T>({
    required dynamic error,
    required T endpoint,
    required String? request,
    required FkRequestType requestType,
  }) {
    Debugger.log('Handle network error', error);

    String errorMsg = 'Ha habido un error desconocido, inténtalo de nuevo';

    // Connection error (most likely)
    if (error?.exception?.linkException?.originalException is SocketException) {
      Debugger.log('Connection error');

      errorMsg = 'Ha habido un error de red, es posible que no tengas conexión';
    }
    // Request error
    else if (existsNotEmpty(error?.exception?.graphqlErrors) ||
        exists(error?.exception?.linkException?.response)) {
      Debugger.log('Request error');

      dynamic statusCode = error?.exception?.graphqlErrors.length > 0
          ? (error?.exception?.graphqlErrors?[0]?.extensions?['response']
                  ?['statusCode'] ??
              error?.exception?.graphqlErrors?[0]?.extensions?['exception']
                  ?['status'] ??
              error?.exception?.graphqlErrors?[0]?.extensions?['originalError']
                  ?['statusCode'])
          : error?.exception?.linkException?.response?.statusCode;

      Debugger.log('Status code', statusCode);

      if (statusCode?.toString != null) {
        statusCode = statusCode.toString();
      }

      // Bad request
      if (statusCode == '400') {
        errorMsg = getErrorMessageFromGraphQLError(error) ?? errorMsg;
      }
      // Authentication error
      else if (statusCode == '401') {
        ref.read(authProvider.notifier).logout();
        final authMode = ref.read(authProvider).authMode;

        switch (authMode) {
          case FkDisabledAuthMode():
            errorMsg = 'No tienes permisos para realizar esta acción';
            break;
          case FkManualAuthMode():
            errorMsg = 'La sesión ha caducado, vuelve a iniciar sesión';
            break;
          case FkAutoAuthMode():
          default:
            errorMsg = 'Ha ocurrido un error inesperado con la sesión';
        }
      }
      // Forbidden error
      else if (statusCode == '403') {
        errorMsg = getErrorMessageFromGraphQLError(error) ?? errorMsg;
      } else if (state.apiMappedErrorCodes[statusCode.toString()] != null) {
        errorMsg = state.apiMappedErrorCodes[statusCode.toString()]!;
      }
    }

    Future.delayed(
      Duration.zero,
      () => Toast.show(
        errorMsg,
        mode: ToastMode.error,
        duration: const Duration(seconds: 6),
      ),
    );

    throw error;
  }

  // Default response handler for GraphQL requests with Basic Auth
  Future<QueryResult> _handleResponseBasicAuth<T>({
    required T endpoint,
    required FkRequestType requestType,
    required Map<String, dynamic>? params,
    required QueryResult res,
    bool isRetry = false,
  }) async {
    Debugger.log('_handleResponseBasicAuth', res);

    return res;
  }

  // Default response handler for GraphQL requests
  Future<QueryResult> _handleResponse<T>({
    required T endpoint,
    required FkRequestType requestType,
    required Map<String, dynamic>? params,
    required QueryResult res,
    bool isRetry = false,
  }) async {
    Debugger.log('_handleResponse', res);

    final exception = res.exception;

    if (exception != null) {
      Debugger.log('Catched exception', exception);

      if (!isRetry) {
        if (exception.graphqlErrors.isNotEmpty) {
          final bool hasAuthError = exception.graphqlErrors.any(
            (error) =>
                error.extensions?['response']?['statusCode'] == 401 ||
                error.extensions?['originalError']?['statusCode'] == 401,
          );

          if (hasAuthError && state.authEndpoint != null) {
            Debugger.log('Authentication error, trying to reload token');

            final FkAuthMode authMode = ref.read(authProvider).authMode;

            switch (authMode) {
              case FkDisabledAuthMode():
                break;
              case FkManualAuthMode():
                if (existsNotEmpty(ref.read(authProvider).refreshToken) &&
                    await ref.read(authProvider.notifier).login(
                          endpoint: state.authEndpoint,
                          useRefreshToken: true,
                        )) {
                  // Retry asynchonously after login to allow gql listeners to refresh
                  return Future.delayed(
                    Duration.zero,
                    () => query(
                      endpoint: endpoint,
                      params: params,
                      isRetry: true,
                    ),
                  );
                }
                break;
              case FkAutoAuthMode():
                if (existsNotEmpty(ref.read(authProvider).refreshToken) &&
                    await ref.read(authProvider.notifier).login(
                          endpoint: state.authEndpoint,
                          useRefreshToken: true,
                        )) {
                  // Retry asynchonously after login to allow gql listeners to refresh
                  return Future.delayed(
                    Duration.zero,
                    () => query(
                      endpoint: endpoint,
                      params: params,
                      isRetry: true,
                    ),
                  );
                } else {
                  if (await ref.read(authProvider.notifier).login(
                        endpoint: state.authEndpoint,
                        authMode: authMode,
                      )) {
                    // Retry asynchonously after login to allow gql listeners to refresh
                    return Future.delayed(
                      Duration.zero,
                      () => query(
                        endpoint: endpoint,
                        params: params,
                        isRetry: true,
                      ),
                    );
                  }
                }
                break;
              default:
                break;
            }
          }
        }
      }

      _handleError(
        error: res,
        endpoint: endpoint,
        request: state.apiRepository?[endpoint],
        requestType: requestType,
      );

      throw res;
    }

    return res;
  }

  // Default GraphQL request handler
  Future<QueryResult> _handleRequest<T>({
    required T endpoint,
    required FkRequestType requestType,
    required Map<String, dynamic>? params,
    bool isRetry = false,
    required Future<QueryResult> Function({
      required T endpoint,
      required FkRequestType requestType,
      required Map<String, dynamic>? params,
      required QueryResult res,
      required bool isRetry,
    }) handler,
    required GraphQLClient? gqlClient,
  }) async {
    final request = state.apiRepository?[endpoint];

    if (request == null) {
      throw Exception('No request found for endpoint $endpoint');
    }

    if (gqlClient == null) {
      throw Exception('No GraphQL client found');
    }

    switch (requestType) {
      case FkRequestType.query:
        try {
          final res = await gqlClient.query(
            QueryOptions(
              document: gql(request),
              variables: params ?? {},
            ),
          );

          Debugger.log('HANDLE GQL QUERY', res);

          return handler(
            endpoint: endpoint,
            requestType: requestType,
            params: params,
            res: res,
            isRetry: isRetry,
          );
        } catch (e) {
          Debugger.log('RETHROW GQL QUERY ERROR', e);

          rethrow;
        }
      case FkRequestType.mutation:
        try {
          final res = await gqlClient.mutate(
            MutationOptions(
              document: gql(request),
              variables: params ?? {},
            ),
          );

          Debugger.log('HANDLE GQL MUTATION', res);

          return handler(
            endpoint: endpoint,
            requestType: requestType,
            params: params,
            res: res,
            isRetry: isRetry,
          );
        } catch (e) {
          Debugger.log('RETHROW GQL MUTATION ERROR', e);

          rethrow;
        }
    }
  }

  /// Inicializa el servicio de red
  void initialize<T>({
    Map<T, String> apiRepository = const {},
    T? authEndpoint,
    Map<String, String>? apiMappedErrorCodes,
  }) {
    if (state.isInitialized) {
      return;
    }

    state = state.copyWith(
      isInitialized: true,
      apiRepository: apiRepository,
      authEndpoint: authEndpoint,
      apiMappedErrorCodes: apiMappedErrorCodes,
    );
  }

  /// Realiza una petición GraphQL
  Future<QueryResult> query<T>({
    bool useBasicAuth = false,
    bool isRetry = false,
    required T endpoint,
    Map<String, dynamic>? params,
  }) {
    final gql = ref.read(gQLClientProvider);

    return _handleRequest(
      endpoint: endpoint,
      params: params,
      requestType: FkRequestType.query,
      isRetry: isRetry,
      handler: useBasicAuth ? _handleResponseBasicAuth : _handleResponse,
      gqlClient: useBasicAuth ? gql.gqlClientBasicAuth : gql.gqlClient,
    );
  }

  /// Realiza una mutación GraphQL
  Future<QueryResult> mutate<T>({
    bool useBasicAuth = false,
    bool isRetry = false,
    required T endpoint,
    Map<String, dynamic>? params,
  }) {
    final gql = ref.read(gQLClientProvider);

    return _handleRequest(
      endpoint: endpoint,
      params: params,
      requestType: FkRequestType.mutation,
      isRetry: isRetry,
      handler: useBasicAuth ? _handleResponseBasicAuth : _handleResponse,
      gqlClient: useBasicAuth ? gql.gqlClientBasicAuth : gql.gqlClient,
    );
  }
}
