// Tipado de los endpoints necesarios
enum EndpointName {
  oAuthCreateCredentials,
}

class GQLModel {
  final String name;
  final List<String> fields;

  const GQLModel({required this.name, required this.fields});
}

String _composeRequest(
  GQLModel baseModel, {
  bool addModelName = true,
  List<String>? includes,
}) {
  String request = '';

  if (addModelName) {
    request += '${baseModel.name} {\n';
  }

  request += baseModel.fields.join('\n');

  if (includes != null && includes.isNotEmpty) {
    request += '\n${includes.join('\n')}';
  }

  if (addModelName) {
    request += '\n}';
  }

  return request;
}

// Tipado de los modelos necesarios
const _oAuthCredentials = GQLModel(
  name: 'oAuthCredentials',
  fields: [
    'accessToken',
    'refreshToken',
  ],
);

// Repositorio de endpoints
final Map<EndpointName, String> apiRepository = {
  EndpointName.oAuthCreateCredentials: '''
mutation (\$payload: OAuthCreateCredentialsInput!) {
	oAuthCreateCredentials (payload: \$payload) {
		${_composeRequest(_oAuthCredentials, addModelName: false)}
	}
}
''',
};
