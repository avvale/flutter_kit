library flutter_kit;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_kit/models/auth_mode/auth_mode.dart';
import 'package:flutter_kit/models/auth_mode/auto_auth_mode.dart';
import 'package:flutter_kit/models/auth_mode/disabled_auth_mode.dart';
import 'package:flutter_kit/models/auth_mode/manual_auth_mode.dart';
import 'package:flutter_kit/models/easy_loading_config.dart';
import 'package:flutter_kit/models/state/auth_state.dart';
import 'package:flutter_kit/models/state/l10n_state.dart';
import 'package:flutter_kit/models/state/network_state.dart';
import 'package:flutter_kit/services/auth_service.dart';
import 'package:flutter_kit/services/l10n_service.dart';
import 'package:flutter_kit/services/network_service.dart';
import 'package:flutter_kit/utils/helpers.dart';
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

class _L10nWrapper extends StatelessWidget {
  final bool useLocalization;
  final Widget child;
  final String? defaultLang;
  final List<Locale>? supportedLocales;
  final String? translationsPath;

  _L10nWrapper({
    Key? key,
    required this.useLocalization,
    required this.child,
    this.defaultLang,
    this.supportedLocales,
    this.translationsPath,
  })  : assert(
          useLocalization == false ||
              (existsNotEmpty(defaultLang) &&
                  existsNotEmpty(translationsPath) &&
                  existsNotEmpty(supportedLocales)),
          'If localization is used, defaultLang parameter is required',
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!useLocalization) {
      return StreamBuilder(
        stream: L10nService().stream,
        builder: (context, AsyncSnapshot<L10nState> snapshot) {
          if (!snapshot.hasData || !snapshot.data!.isInitialized) {
            L10nService().initialize();

            return const Space();
          }

          return child;
        },
      );
    }

    return EasyLocalization(
      supportedLocales: supportedLocales!.toList(),
      path: translationsPath!,
      fallbackLocale: Locale(defaultLang!),
      child: StreamBuilder(
        stream: L10nService().stream,
        builder: (context, AsyncSnapshot<L10nState> snapshot) {
          if (!snapshot.hasData || !snapshot.data!.isInitialized) {
            L10nService().initialize(defaultLang: context.locale.languageCode);

            return const Space();
          }

          return child;
        },
      ),
    );
  }
}

class _NetworkWrapper<T> extends StatelessWidget {
  final Widget child;
  final String apiUrl;
  final String? basicAuthToken;
  final Policies? gqlPolicies;
  final Map<String, String>? apiMappedErrorCodes;
  final Map<T, String> apiRepository;
  final T? authEndpoint;
  final AuthMode authMode;
  final String authTokenPrefix;

  const _NetworkWrapper({
    Key? key,
    required this.child,
    required this.apiUrl,
    required this.basicAuthToken,
    required this.gqlPolicies,
    required this.apiMappedErrorCodes,
    required this.apiRepository,
    required this.authEndpoint,
    required this.authMode,
    required this.authTokenPrefix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: NetworkService().stream,
      builder: (context, AsyncSnapshot<NetworkState> snapshot) {
        if (!snapshot.hasData || !snapshot.data!.isInitialized) {
          NetworkService().initialize(
            apiUrl: apiUrl,
            basicAuthToken: basicAuthToken,
            gqlPolicies: gqlPolicies,
            apiRepository: apiRepository,
            authEndpoint: authEndpoint,
            apiMappedErrorCodes: apiMappedErrorCodes,
            authMode: authMode,
            authTokenPrefix: authTokenPrefix,
          );

          return const Space();
        }

        return child;
      },
    );
  }
}

class _AuthWrapper extends StatelessWidget {
  final Widget child;
  final AuthMode authMode;

  const _AuthWrapper({
    Key? key,
    required this.child,
    required this.authMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (authMode) {
      case ManualAuthMode():
      case AutoAuthMode():
        return StreamBuilder(
          stream: AuthService().stream,
          builder: (context, AsyncSnapshot<AuthState> snapshot) {
            if (!snapshot.hasData || !snapshot.data!.isInitialized) {
              AuthService().initialize();

              return const Space();
            }

            return child;
          },
        );
      default:
        return child;
    }
  }
}

class _AppWrapper extends StatelessWidget {
  final String? title;
  final Color? primaryColor;
  final ThemeData Function(BuildContext)? theme;
  final Map<String, Widget Function(BuildContext)> routes;
  final Widget? home;

  const _AppWrapper({
    Key? key,
    this.title,
    this.primaryColor,
    this.theme,
    this.routes = const <String, WidgetBuilder>{},
    this.home,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title ?? 'Flutter Kit',
      color: primaryColor,
      theme: theme != null
          ? theme!(context).copyWith(primaryColor: primaryColor)
          : ThemeData(primaryColor: primaryColor),
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      routes: routes,
      builder: EasyLoading.init(),
      home: home,
    );
  }
}

/// Run application with custom configuration
void fxRunApp<T>({
  /// The title of the application.
  String? title,

  /// The primary color to use for the application.
  Color? primaryColor,

  /// The theme to use for the application.
  ThemeData Function(BuildContext)? theme,

  /// The duration of the splash screen.
  Duration? splashDuration,

  /// The API URL.
  String apiUrl = '',

  /// The authentication mode.
  AuthMode authMode = const DisabledAuthMode(),

  /// The basic auth token.
  String? basicAuthToken,

  /// The GraphQL policies.
  Policies? gqlPolicies,

  /// The API repository.
  Map<T, String> apiRepository = const {},

  /// The auth token prefix.
  String authTokenPrefix = 'Bearer',

  /// The auth endpoint.
  T? authEndpoint,

  /// The mapped error codes.
  Map<String, String>? apiMappedErrorCodes,

  /// The home page/initial screen.
  Widget? home,

  /// The routes for the application.
  Map<String, Widget Function(BuildContext)> routes =
      const <String, WidgetBuilder>{},

  /// The orientations to use for the application.
  List<DeviceOrientation> orientations = const [DeviceOrientation.portraitUp],

  /// Configuration for loader to be shown on loading data.
  EasyLoadingConfig? loaderConfig,

  /// Whether to use localization services or not.
  bool useLocalization = false,

  /// The default language. If localization is used, this parameter is required.
  String defaultLang = 'en',
  String translationsPath = '',
  List<Locale> supportedLocales = const <Locale>[Locale('en', 'US')],
}) async {
  assert(
    useLocalization == false ||
        (existsNotEmpty(defaultLang) &&
            existsNotEmpty(translationsPath) &&
            existsNotEmpty(supportedLocales)),
    'If localization is used, defaultLang parameter is required',
  );

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  if (useLocalization) await EasyLocalization.ensureInitialized();

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

  await SystemChrome.setPreferredOrientations(orientations);

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
      child: _L10nWrapper(
        useLocalization: useLocalization,
        defaultLang: defaultLang,
        translationsPath: translationsPath,
        supportedLocales: supportedLocales,
        child: _NetworkWrapper(
          apiUrl: apiUrl,
          basicAuthToken: basicAuthToken,
          gqlPolicies: gqlPolicies,
          apiRepository: apiRepository,
          authEndpoint: authEndpoint,
          apiMappedErrorCodes: apiMappedErrorCodes,
          authMode: authMode,
          authTokenPrefix: authTokenPrefix,
          child: _AuthWrapper(
            authMode: authMode,
            child: _AppWrapper(
              title: title,
              primaryColor: primaryColor,
              theme: theme,
              routes: routes,
              home: home,
            ),
          ),
        ),
      ),
    ),
  );
}
