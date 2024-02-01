library flutter_kit;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_kit/models/auth_mode.dart';
import 'package:flutter_kit/models/loader_config.dart';
import 'package:flutter_kit/models/router.dart';
import 'package:flutter_kit/providers/auth_provider.dart';
import 'package:flutter_kit/providers/l10n_provider.dart';
import 'package:flutter_kit/providers/network_provider.dart';
import 'package:flutter_kit/utils/helpers.dart';
import 'package:flutter_kit/widgets/space.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Handles localization logic.
/// If [useLocalization] is false, only the child widget is returned.
/// Otherwise, the localization is initialized with EasyLocalization and the
/// child widget is returned.
class _L10nWrapper extends ConsumerWidget {
  final bool useLocalization;
  final Widget child;
  final String? defaultLang;
  final List<Locale>? supportedLocales;
  final String? translationsPath;

  _L10nWrapper({
    required this.useLocalization,
    required this.child,
    this.defaultLang,
    this.supportedLocales,
    this.translationsPath,
  }) : assert(
          useLocalization == false ||
              (existsNotEmpty(defaultLang) &&
                  existsNotEmpty(translationsPath) &&
                  existsNotEmpty(supportedLocales)),
          'If localization is used, defaultLang parameter is required',
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!useLocalization) {
      return child;
    }

    return EasyLocalization(
      supportedLocales: supportedLocales!.toList(),
      path: translationsPath!,
      fallbackLocale: Locale(defaultLang!),
      child: Consumer(
        builder: (context, ref, cChild) {
          final l10n = ref.watch(l10nProvider);

          if (!l10n.isInitialized) {
            Future.delayed(
              Duration.zero,
              () => ref
                  .read(l10nProvider.notifier)
                  .initialize(defaultLang: context.locale.languageCode),
            );

            return const Space();
          }

          return child;
        },
      ),
    );
  }
}

/// Handles network logic.
/// Initializes the network provider with the given configuration.
class _NetworkWrapper<T> extends ConsumerWidget {
  final Widget child;
  final String apiUrl;
  final String? basicAuthToken;
  final Policies? gqlPolicies;
  final Map<String, String>? apiMappedErrorCodes;
  final Map<T, String> apiRepository;
  final T? authEndpoint;
  final FkAuthMode authMode;
  final String authTokenPrefix;

  const _NetworkWrapper({
    super.key,
    required this.child,
    required this.apiUrl,
    required this.basicAuthToken,
    required this.gqlPolicies,
    required this.apiMappedErrorCodes,
    required this.apiRepository,
    required this.authEndpoint,
    required this.authMode,
    required this.authTokenPrefix,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final network = ref.watch(networkProvider);

    if (!network.isInitialized) {
      Future.delayed(
        Duration.zero,
        () => ref.read(networkProvider.notifier).initialize(
              apiUrl: apiUrl,
              basicAuthToken: basicAuthToken,
              gqlPolicies: gqlPolicies,
              apiRepository: apiRepository,
              authEndpoint: authEndpoint,
              apiMappedErrorCodes: apiMappedErrorCodes,
              authMode: authMode,
              authTokenPrefix: authTokenPrefix,
            ),
      );

      return const Space();
    }

    return child;
  }
}

/// Handles authentication logic.
/// If [authMode] is [FkDisabledAuthMode], only the child widget is returned.
/// Otherwise, the authentication is initialized with the given configuration
/// and the child widget is returned.
class _AuthWrapper extends StatelessWidget {
  final Widget child;
  final FkAuthMode authMode;

  const _AuthWrapper({
    required this.child,
    required this.authMode,
  });

  @override
  Widget build(BuildContext context) {
    switch (authMode) {
      case FkManualAuthMode():
      case FkAutoAuthMode():
        return Consumer(
          builder: (context, ref, cChild) {
            final auth = ref.watch(authProvider);

            if (!auth.isInitialized) {
              Future.delayed(
                Duration.zero,
                () => ref.read(authProvider.notifier).initialize(),
              );

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

class _AppWrapper extends ConsumerWidget {
  final String? title;
  final FkRouter router;
  final Color? primaryColor;
  final ThemeData Function(BuildContext)? theme;
  final bool useLocalization;

  const _AppWrapper({
    this.title,
    required this.router,
    this.primaryColor,
    this.theme,
    required this.useLocalization,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    final goRouter = generateRouter(router, auth);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: title ?? 'Flutter Kit',
      color: primaryColor,
      theme: theme != null
          ? theme!(context).copyWith(primaryColor: primaryColor)
          : ThemeData(primaryColor: primaryColor),
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      locale: useLocalization ? context.locale : null,
      localizationsDelegates:
          useLocalization ? context.localizationDelegates : null,
      supportedLocales: useLocalization
          ? context.supportedLocales
          : const <Locale>[Locale('en', 'US')],
      builder: EasyLoading.init(),
      routeInformationParser: goRouter.routeInformationParser,
      routerDelegate: goRouter.routerDelegate,
      routeInformationProvider: goRouter.routeInformationProvider,
    );
  }
}

/// Run application with custom configuration
void fkRunApp<T>({
  /// The title of the application.
  String? title,

  /// The routing configuration for the application.
  required FkRouter router,

  /// The primary color for the application. It is defined separately from the
  /// theme to be able to use it in more specific areas like the loader.
  Color? primaryColor,

  /// The theme for the application.
  ThemeData Function(BuildContext)? theme,

  /// The duration of the native splash screen.
  Duration? splashDuration,

  /// The API URL.
  String apiUrl = '',

  /// The authentication mode.
  /// Defaults to [FkDisabledAuthMode].
  /// Use [FkAutoAuthMode] when Aurora generic token is used.
  /// Use [FkManualAuthMode] when the user must be authenticated.
  FkAuthMode authMode = const FkDisabledAuthMode(),

  /// The basic auth token.
  String? basicAuthToken,

  /// The GraphQL policies.
  Policies? gqlPolicies,

  /// The API repository.
  /// This is a map of the API endpoints and their respective names.
  /// [T] is the type of the endpoint name (commonly an enum)
  Map<T, String> apiRepository = const {},

  /// The auth token prefix.
  String authTokenPrefix = 'Bearer',

  /// The auth endpoint.
  T? authEndpoint,

  /// The mapped error codes.
  /// These are Aurora custom error codes mapped to their respective messages.
  Map<String, String>? apiMappedErrorCodes,

  /// The allowed orientations for the application.
  List<DeviceOrientation> orientations = const [DeviceOrientation.portraitUp],

  /// Style for the loader to be shown on loading data.
  EasyLoadingConfig? loaderConfig,

  /// Whether to use localization services or not.
  bool useLocalization = false,

  /// The default language. If localization is used, this parameter is required.
  String? defaultLang,

  /// The path to the translations folder. If localization is used, this
  /// parameter is required.
  String? translationsPath,

  /// The supported locales. If localization is used, this parameter is
  /// required.
  List<Locale>? supportedLocales,
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
          maskColor: primaryColor ?? Colors.black.withOpacity(0.5),
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
    ProviderScope(
      child: GestureDetector(
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
                router: router,
                useLocalization: useLocalization,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
