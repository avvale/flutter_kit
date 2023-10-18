library flutter_kit;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_kit/models/easy_loading_config.dart';
import 'package:flutter_kit/models/state/network_state.dart';
import 'package:flutter_kit/services/network_service.dart';
import 'package:flutter_kit/widgets/space.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:graphql/client.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Initialize loader with custom configuration
void _initializeLoaderConfig({required EasyLoadingConfig elc}) {
  EasyLoading.instance
    ..animationDuration =
        elc.animationDuration ?? EasyLoading.instance.animationDuration
    ..animationStyle = elc.animationStyle ?? EasyLoading.instance.animationStyle
    ..backgroundColor =
        elc.backgroundColor ?? EasyLoading.instance.backgroundColor
    ..boxShadow = elc.boxShadow ?? EasyLoading.instance.boxShadow
    ..contentPadding = elc.contentPadding ?? EasyLoading.instance.contentPadding
    ..customAnimation =
        elc.customAnimation ?? EasyLoading.instance.customAnimation
    ..dismissOnTap = elc.dismissOnTap ?? EasyLoading.instance.dismissOnTap
    ..displayDuration =
        elc.displayDuration ?? EasyLoading.instance.displayDuration
    ..errorWidget = elc.errorWidget ?? EasyLoading.instance.errorWidget
    ..fontSize = elc.fontSize ?? EasyLoading.instance.fontSize
    ..indicatorColor = elc.indicatorColor ?? EasyLoading.instance.indicatorColor
    ..indicatorSize = elc.indicatorSize ?? EasyLoading.instance.indicatorSize
    ..indicatorType = elc.indicatorType ?? EasyLoading.instance.indicatorType
    ..indicatorWidget =
        elc.indicatorWidget ?? EasyLoading.instance.indicatorWidget
    ..infoWidget = elc.infoWidget ?? EasyLoading.instance.infoWidget
    ..lineWidth = elc.lineWidth ?? EasyLoading.instance.lineWidth
    ..loadingStyle = elc.loadingStyle ?? EasyLoading.instance.loadingStyle
    ..maskColor = elc.maskColor ?? EasyLoading.instance.maskColor
    ..maskType = elc.maskType ?? EasyLoading.instance.maskType
    ..progressColor = elc.progressColor ?? EasyLoading.instance.progressColor
    ..progressWidth = elc.progressWidth ?? EasyLoading.instance.progressWidth
    ..radius = elc.radius ?? EasyLoading.instance.radius
    ..successWidget = elc.successWidget ?? EasyLoading.instance.successWidget
    ..textAlign = elc.textAlign ?? EasyLoading.instance.textAlign
    ..textColor = elc.textColor ?? EasyLoading.instance.textColor
    ..textPadding = elc.textPadding ?? EasyLoading.instance.textPadding
    ..textStyle = elc.textStyle ?? EasyLoading.instance.textStyle
    ..toastPosition = elc.toastPosition ?? EasyLoading.instance.toastPosition
    ..userInteractions =
        elc.userInteractions ?? EasyLoading.instance.userInteractions;
}

/// Run application with custom configuration
void fxRunApp<T>({
  String? title,
  Color? primaryColor,
  ThemeData? theme,
  Duration? splashDuration,
  String apiUrl = '',
  String? basicAuthToken,
  Policies? gqlPolicies,
  Map<T, String> apiRepository = const {},
  T? authEndpoint,
  Map<String, String>? apiMappedErrorCodes,
  Widget? home,
  Map<String, Widget Function(BuildContext)> routes =
      const <String, WidgetBuilder>{},

  /// The orientations to use for the application.
  List<DeviceOrientation> orientations = const [DeviceOrientation.portraitUp],

  /// Configuration for loader to be shown on loading data
  EasyLoadingConfig? loaderConfig,
}) {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  if (splashDuration != null) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  _initializeLoaderConfig(
    elc: loaderConfig ??
        EasyLoadingConfig(
          backgroundColor: Colors.transparent,
          boxShadow: [],
          contentPadding: const EdgeInsets.all(16),
          indicatorColor: Colors.white,
          indicatorSize: 36,
          indicatorType: EasyLoadingIndicatorType.foldingCube,
          loadingStyle: EasyLoadingStyle.custom,
          maskType: EasyLoadingMaskType.custom,
          maskColor: primaryColor,
          radius: 8,
          textColor: Colors.white,
          userInteractions: false,
        ),
  );

  SystemChrome.setPreferredOrientations(orientations).then(
    (_) {
      /// We wait a few milliseconds to remove the splash screen so that the
      /// orientation is fully applied before removing it.
      if (splashDuration != null) {
        Future.delayed(
          splashDuration,
          () => FlutterNativeSplash.remove(),
        );
      }

      // Initialize app
      runApp(
        GestureDetector(
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
                color: primaryColor,
                theme: theme != null
                    ? theme.copyWith(primaryColor: primaryColor)
                    : ThemeData(primaryColor: primaryColor),
                home: home,
              );
            },
          ),
        ),
      );
    },
  );
}
