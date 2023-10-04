import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_kit/services/network_service.dart';
import 'package:flutter_kit/models/state/network_state.dart';
import 'package:flutter_kit/widgets/space.dart';
import 'package:graphql/client.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class FxApp<T> extends StatelessWidget {
  final String? title;
  final String apiUrl;
  final String? basicAuthToken;
  final Policies? gqlPolicies;
  final Map<T, String> apiRepository;
  final T? authEndpoint;
  final Map<String, String>? apiMappedErrorCodes;
  final Widget? home;
  final Map<String, Widget Function(BuildContext)> routes;

  /// Wrapper for [MaterialApp] with custom configuration
  const FxApp({
    Key? key,
    this.title,
    this.apiUrl = '',
    this.basicAuthToken,
    this.gqlPolicies,
    this.apiRepository = const {},
    this.authEndpoint,
    this.apiMappedErrorCodes,
    this.home,
    this.routes = const <String, WidgetBuilder>{},
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
    );

    return GestureDetector(
      /// When tapping outside of a text field, the keyboard is hidden
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: StreamBuilder(
        stream: NetworkService().networkState,
        builder: (context, AsyncSnapshot<NetworkState> snapshot) {
          if (!snapshot.hasData || !snapshot.data!.isInitialized) {
            NetworkService().initialize(
              apiUrl: apiUrl,
              basicAuthToken: basicAuthToken,
              gqlPolicies: gqlPolicies,
              apiRepository: apiRepository,
              authEndpoint: authEndpoint,
              apiMappedErrorCodes: apiMappedErrorCodes,
            );

            return const Space();
          }

          return MaterialApp(
            title: title ?? 'Flutter Kit',
            scaffoldMessengerKey: rootScaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            builder: EasyLoading.init(),
            routes: routes,
            color: Colors.green,
            theme: ThemeData(primarySwatch: Colors.green),
            home: home,
          );
        },
      ),
    );
  }
}
