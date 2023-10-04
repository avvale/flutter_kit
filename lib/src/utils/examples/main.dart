import 'package:flutter_kit/src/utils/examples/api_repository.dart';
import 'package:flutter_kit/src/utils/helpers.dart';
import 'package:flutter_kit/src/widgets/common/fx_app.dart';
import 'package:flutter_kit/src/widgets/common/space.dart';
import 'package:graphql/client.dart';

void runMain() {
  fxRunApp(
    FxApp(
      title: 'Flutter Kit',
      apiUrl: 'https://example.com',
      basicAuthToken: 'Basic _TOKEN_',
      gqlPolicies: Policies(fetch: FetchPolicy.networkOnly),
      apiRepository: apiRepository,
      authEndpoint: EndpointName.oAuthCreateCredentials,
      home: const Space(),
    ),
  );
}
