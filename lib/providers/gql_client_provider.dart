import 'package:flutter_kit/models/state/gql_client_state.dart';
import 'package:flutter_kit/providers/l10n_provider.dart';
import 'package:flutter_kit/utils/debugger.dart';
import 'package:flutter_kit/utils/helpers.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gql_client_provider.g.dart';

const _initialState = FkGQLClientState();

@riverpod
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
  Future<void> initialize<T>({
    required String apiUrl,
    String? basicAuthToken,
    Policies? gqlPolicies,
    String? authTokenPrefix,
  }) async {
    state = state.copyWith(
      isInitialized: true,
      apiUrl: apiUrl,
      authTokenPrefix: authTokenPrefix,
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
    );
  }

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
}
