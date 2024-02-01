import 'dart:io';

import 'package:flutter_kit/models/auth_mode.dart';
import 'package:flutter_kit/models/state/network_state.dart';
import 'package:flutter_kit/providers/auth_provider.dart';
import 'package:flutter_kit/providers/l10n_provider.dart';
import 'package:flutter_kit/utils/debugger.dart';
import 'package:flutter_kit/utils/helpers.dart';
import 'package:flutter_kit/utils/toast.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_provider.g.dart';

enum RequestType {
  query,
  mutation,
}

const _initialState = FkNetworkState();

@riverpod
class Network extends _$Network {
  @override
  FkNetworkState build() {
    return _initialState;
  }

  HttpLink _baseHttpLink({Map<String, String> headers = const {}}) {
    return HttpLink(
      '${state.apiUrl}/graphql',
      defaultHeaders: headers,
    );
  }

  // Default GraphQL error handler
  Future<QueryResult> _handleError<T>({
    required dynamic error,
    required T endpoint,
    required String? request,
    required RequestType requestType,
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

        switch (state.authMode) {
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
    required RequestType requestType,
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
    required RequestType requestType,
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

            final FkAuthMode authMode = state.authMode;

            switch (authMode) {
              case FkDisabledAuthMode():
                break;
              case FkManualAuthMode():
                if (existsNotEmpty(ref.read(authProvider).refreshToken) &&
                    await ref.read(authProvider.notifier).login(
                          endpoint: state.authEndpoint,
                          useRefreshToken: true,
                        )) {
                  return query(
                    endpoint: endpoint,
                    params: params,
                    isRetry: true,
                  );
                }
                break;
              case FkAutoAuthMode():
                if (existsNotEmpty(ref.read(authProvider).refreshToken) &&
                    await ref.read(authProvider.notifier).login(
                          endpoint: state.authEndpoint,
                          useRefreshToken: true,
                        )) {
                  return query(
                    endpoint: endpoint,
                    params: params,
                    isRetry: true,
                  );
                } else {
                  if (await ref.read(authProvider.notifier).login(
                        endpoint: state.authEndpoint,
                        authMode: authMode,
                      )) {
                    return query(
                      endpoint: endpoint,
                      params: params,
                      isRetry: true,
                    );
                  }
                }
              default:
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
    required RequestType requestType,
    required Map<String, dynamic>? params,
    bool isRetry = false,
    required Future<QueryResult> Function({
      required T endpoint,
      required RequestType requestType,
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
      case RequestType.query:
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
      case RequestType.mutation:
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
  Future<void> initialize<T>({
    required String apiUrl,
    String? basicAuthToken,
    Policies? gqlPolicies,
    Map<T, String> apiRepository = const {},
    T? authEndpoint,
    FkAuthMode authMode = const FkDisabledAuthMode(),
    Map<String, String>? apiMappedErrorCodes,
    String? authTokenPrefix,
  }) async {
    state = state.copyWith(
      isInitialized: true,
      gqlClientBasicAuth: GraphQLClient(
        link: AuthLink(getToken: () => basicAuthToken).concat(
          HttpLink('$apiUrl/graphql'),
        ),
        cache: GraphQLCache(),
      ),
      gqlClient: GraphQLClient(
        link: HttpLink('$apiUrl/graphql'),
        cache: GraphQLCache(),
        defaultPolicies: DefaultPolicies(
          query: gqlPolicies,
          mutate: gqlPolicies,
        ),
      ),
      apiUrl: apiUrl,
      apiRepository: apiRepository,
      authMode: authMode,
      authEndpoint: authEndpoint,
      apiMappedErrorCodes: apiMappedErrorCodes,
      authTokenPrefix: authTokenPrefix,
    );
  }

  /// Establece el token de la API
  Future<void> setToken(String? token) async {
    Debugger.log('Set auth token', token);

    final String timezone = await FlutterTimezone.getLocalTimezone();
    final String? lang = ref.read(l10nProvider).currentLocale?.languageCode;

    if (existsNotEmpty(token)) {
      state = state.copyWith(
        gqlClient: state.gqlClient?.copyWith(
          link: AuthLink(
            getToken: () => '${state.authTokenPrefix} $token',
          ).concat(
            _baseHttpLink(
              headers: {
                'X-Timezone': timezone,
                if (existsNotEmpty(lang)) 'content-language': lang!,
              },
            ),
          ),
        ),
      );
    } else {
      state = state.copyWith(
        gqlClient: state.gqlClient?.copyWith(
          link: _baseHttpLink(
            headers: {
              'X-Timezone': timezone,
              if (existsNotEmpty(lang)) 'content-language': lang!,
            },
          ),
        ),
      );
    }
  }

  /// Realiza una petición GraphQL
  Future<QueryResult> query<T>({
    bool useBasicAuth = false,
    bool isRetry = false,
    required T endpoint,
    Map<String, dynamic>? params,
  }) =>
      _handleRequest(
        endpoint: endpoint,
        params: params,
        requestType: RequestType.query,
        isRetry: isRetry,
        handler: useBasicAuth ? _handleResponseBasicAuth : _handleResponse,
        gqlClient: useBasicAuth ? state.gqlClientBasicAuth : state.gqlClient,
      );

  /// Realiza una mutación GraphQL
  Future<QueryResult> mutate<T>({
    bool useBasicAuth = false,
    bool isRetry = false,
    required T endpoint,
    Map<String, dynamic>? params,
  }) =>
      _handleRequest(
        endpoint: endpoint,
        params: params,
        requestType: RequestType.mutation,
        isRetry: isRetry,
        handler: useBasicAuth ? _handleResponseBasicAuth : _handleResponse,
        gqlClient: useBasicAuth ? state.gqlClientBasicAuth : state.gqlClient,
      );
}