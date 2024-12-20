import 'package:flutter_kit/models/state/gql_client_state.dart';
import 'package:flutter_kit/providers/auth_provider.dart';
import 'package:flutter_kit/providers/l10n_provider.dart';
import 'package:flutter_kit/utils/debugger.dart';
import 'package:flutter_kit/utils/helpers.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gql_client_provider.g.dart';

const _initialState = FkGQLClientState();

@Riverpod(keepAlive: true)
class GQLClient extends _$GQLClient {
  @override
  FkGQLClientState build() => _initialState;

  HttpLink _baseHttpLink({Map<String, String> headers = const {}}) {
    return HttpLink(
      '${state.apiUrl}/graphql',
      defaultHeaders: headers,
    );
  }

  /// Inicializa el servicio de red
  void initialize<T>({
    required String apiUrl,
    String? basicAuthToken,
    Policies? gqlPolicies,
    String? authTokenPrefix,
    Map<String, dynamic>? headers,
    Duration maxRequestTime = const Duration(seconds: 30),
  }) {
    if (state.isInitialized) {
      return;
    }

    ref.listen(l10nProvider, (previous, next) {
      if (previous?.currentLocale != next.currentLocale) {
        setToken();
      }
    });

    ref.listen(authProvider, (previous, next) {
      if (previous?.accessToken != next.accessToken) {
        setToken();
      }
    });

    state = state.copyWith(
      isInitialized: true,
      apiUrl: apiUrl,
      authTokenPrefix: authTokenPrefix,
      gqlClientBasicAuth: GraphQLClient(
        queryRequestTimeout: maxRequestTime,
        link: AuthLink(getToken: () => basicAuthToken).concat(
          HttpLink('$apiUrl/graphql'),
        ),
        cache: GraphQLCache(),
      ),
      gqlClient: GraphQLClient(
        queryRequestTimeout: maxRequestTime,
        link: HttpLink('$apiUrl/graphql'),
        cache: GraphQLCache(),
        defaultPolicies: DefaultPolicies(
          query: gqlPolicies,
          mutate: gqlPolicies,
        ),
      ),
      headers: headers,
      maxRequestTime: maxRequestTime,
    );
  }

  Future<void> setToken() async {
    String timezone = '';

    try {
      timezone = await FlutterTimezone.getLocalTimezone();
    } catch (e) {
      Debugger.log('Error getting timezone', e);
    }

    final String? lang = ref.read(l10nProvider).currentLocale?.languageCode;
    final String token = ref.read(authProvider).accessToken;

    Debugger.log('Set auth token', {
      'Token': token,
      'Timezone': timezone,
      'Lang': lang,
    });

    if (existsNotEmpty(token)) {
      state = state.copyWith(
        gqlClient: GraphQLClient(
          queryRequestTimeout: state.maxRequestTime,
          link: AuthLink(
            getToken: () => '${state.authTokenPrefix} $token',
          ).concat(
            _baseHttpLink(
              headers: {
                'X-Timezone': timezone,
                if (existsNotEmpty(lang)) 'content-language': lang!,
                ...state.headers ?? {},
              },
            ),
          ),
          cache: GraphQLCache(),
          defaultPolicies: state.gqlClient?.defaultPolicies,
        ),
      );
    } else {
      state = state.copyWith(
        gqlClient: GraphQLClient(
          queryRequestTimeout: state.maxRequestTime,
          link: _baseHttpLink(
            headers: {
              'X-Timezone': timezone,
              if (existsNotEmpty(lang)) 'content-language': lang!,
              ...state.headers ?? {},
            },
          ),
          cache: GraphQLCache(),
          defaultPolicies: state.gqlClient?.defaultPolicies,
        ),
      );
    }
  }
}
