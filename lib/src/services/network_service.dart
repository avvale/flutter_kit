import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_kit/src/models/state/network_state.dart';
import 'package:flutter_kit/src/services/auth_service.dart';
import 'package:flutter_kit/src/utils/debugger.dart';
import 'package:flutter_kit/src/utils/toast.dart';
import 'package:graphql/client.dart';
import 'package:rxdart/rxdart.dart';

enum RequestType {
  query,
  mutation,
}

final initialState = NetworkState(
  isInitialized: false,
  gqlClient: GraphQLClient(link: HttpLink(''), cache: GraphQLCache()),
  gqlClientBasicAuth: GraphQLClient(link: HttpLink(''), cache: GraphQLCache()),
  apiUrl: '',
  apiRepository: {},
);

/// Servicio de red
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();

  final _dataFetcher = BehaviorSubject<NetworkState>()..startWith(initialState);

  NetworkState get networkStateSync =>
      _dataFetcher.hasValue ? _dataFetcher.value : initialState;
  Stream<NetworkState> get networkState => _dataFetcher.stream;

  factory NetworkService() {
    return _instance;
  }

  NetworkService._internal();

  /// Inicializa el servicio de red
  Future<void> initialize<T>({
    required String apiUrl,
    String? basicAuthToken,
    Policies? gqlPolicies,
    Map<T, String> apiRepository = const {},
    T? authEndpoint,
    Map<String, String>? apiMappedErrorCodes,
  }) async {
    _dataFetcher.add(
      networkStateSync.copyWith(
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
        authEndpoint: authEndpoint,
        apiMappedErrorCodes: apiMappedErrorCodes,
      ),
    );
  }

  HttpLink _baseHttpLink({Map<String, String> headers = const {}}) {
    return HttpLink(
      '{$networkStateSync.}/graphql',
      defaultHeaders: headers,
    );
  }

  /// Establece el token de la API
  Future<void> setToken(String? token) async {
    Debugger.log('setToken', token);

    if (token != null) {
      _dataFetcher.add(
        networkStateSync.copyWith(
          gqlClient: networkStateSync.gqlClient.copyWith(
            link: AuthLink(
              getToken: () => 'Bearer $token',
            ).concat(
              _baseHttpLink(
                headers: {
                  'X-Timezone': 'Europe/Madrid',
                  'content-language': 'es',
                },
              ),
            ),
          ),
        ),
      );
    } else {
      _dataFetcher.add(
        networkStateSync.copyWith(
          gqlClient: networkStateSync.gqlClient.copyWith(link: _baseHttpLink()),
        ),
      );
    }
  }

  // Default GraphQL error handler
  Future<QueryResult> _handleError<T>({
    required dynamic error,
    required T endpoint,
    required String request,
    required RequestType requestType,
  }) {
    Debugger.log('Handle error', error);

    String errorMsg = 'Ha habido un error desconocido, inténtalo de nuevo';

    // Connection error (most likely)
    if (error?.exception?.linkException?.originalException is SocketException) {
      errorMsg = 'Ha habido un error de red, es posible que no tengas conexión';
    }
    // Request error
    else if ((error?.exception?.graphqlErrors != null &&
            error?.exception?.graphqlErrors.isNotEmpty) ||
        error?.exception?.linkException?.response != null) {
      final dynamic statusCode = error?.exception?.graphqlErrors.length > 0
          ? (error?.exception?.graphqlErrors?[0]?.extensions?['response']
                  ?['statusCode'] ??
              error?.exception?.graphqlErrors?[0]?.extensions?['exception']
                  ?['status'] ??
              error?.exception?.graphqlErrors?[0]?.extensions?['originalError']
                  ?['statusCode'])
          : error?.exception?.linkException?.response?.statusCode;
      // Bad request
      if (statusCode == '400' || statusCode == 400) {
        if (error?.exception?.graphqlErrors.length > 0) {
          if (error?.exception?.graphqlErrors?[0]?.message is String) {
            errorMsg =
                (error?.exception?.graphqlErrors?[0]?.message as String).trim();
          }
        } else {
          if (error?.exception?.linkException?.response?.body is String) {
            final List<dynamic>? errors = json.decode(
              error?.exception?.linkException?.response?.body,
            )?['errors'];

            if (errors != null && errors.isNotEmpty) {
              errorMsg = errors[0]['message'];
            }
          }
        }
      }
      // Authentication error
      else if (statusCode == '401' || statusCode == 401) {
        AuthService().logout();

        errorMsg = 'La sesión ha caducado, vuelve a iniciar sesión';
      } else if (networkStateSync.apiMappedErrorCodes[statusCode.toString()] !=
          null) {
        errorMsg = networkStateSync.apiMappedErrorCodes[statusCode.toString()]!;
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

          if (hasAuthError && networkStateSync.authEndpoint != null) {
            Debugger.log('Authentication error, trying to reload token');

            if (await AuthService().login(
              endpoint: networkStateSync.authEndpoint,
              useRefreshToken: true,
            )) {
              return query(endpoint: endpoint, params: params, isRetry: true);
            } else {
              await AuthService()
                  .login(endpoint: networkStateSync.authEndpoint);

              return query(endpoint: endpoint, params: params, isRetry: true);
            }
          }
        }
      }

      _handleError(
        error: res,
        endpoint: endpoint,
        request: networkStateSync.apiRepository[endpoint]!,
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
    required GraphQLClient gqlClient,
  }) {
    final request = networkStateSync.apiRepository[endpoint]!;

    switch (requestType) {
      case RequestType.query:
        return gqlClient
            .query(
          QueryOptions(
            document: gql(request),
            variables: params ?? {},
          ),
        )
            .then((queryResult) {
          Debugger.log('HANDLE GQL QUERY', queryResult);

          return handler(
            endpoint: endpoint,
            requestType: requestType,
            params: params,
            res: queryResult,
            isRetry: isRetry,
          );
        });
      case RequestType.mutation:
        return gqlClient
            .mutate(
          MutationOptions(
            document: gql(request),
            variables: params ?? {},
          ),
        )
            .then((queryResult) {
          Debugger.log('HANDLE GQL MUTATION', queryResult);

          return handler(
            endpoint: endpoint,
            requestType: requestType,
            params: params,
            res: queryResult,
            isRetry: isRetry,
          );
        });
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
        gqlClient: useBasicAuth
            ? networkStateSync.gqlClientBasicAuth
            : networkStateSync.gqlClient,
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
        gqlClient: useBasicAuth
            ? networkStateSync.gqlClientBasicAuth
            : networkStateSync.gqlClient,
      );
}
