import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_kit/models/easy_loading_config.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

/// Initialize loader with custom configuration
void _initializeLoaderConfig({EasyLoadingConfig? elc}) {
  EasyLoading.instance
    ..animationDuration =
        elc?.animationDuration ?? EasyLoading.instance.animationDuration
    ..animationStyle =
        elc?.animationStyle ?? EasyLoading.instance.animationStyle
    ..backgroundColor =
        elc?.backgroundColor ?? EasyLoading.instance.backgroundColor
    ..boxShadow = elc?.boxShadow ?? EasyLoading.instance.boxShadow
    ..contentPadding =
        elc?.contentPadding ?? EasyLoading.instance.contentPadding
    ..customAnimation =
        elc?.customAnimation ?? EasyLoading.instance.customAnimation
    ..dismissOnTap = elc?.dismissOnTap ?? EasyLoading.instance.dismissOnTap
    ..displayDuration =
        elc?.displayDuration ?? EasyLoading.instance.displayDuration
    ..errorWidget = elc?.errorWidget ?? EasyLoading.instance.errorWidget
    ..fontSize = elc?.fontSize ?? EasyLoading.instance.fontSize
    ..indicatorColor =
        elc?.indicatorColor ?? EasyLoading.instance.indicatorColor
    ..indicatorSize = elc?.indicatorSize ?? EasyLoading.instance.indicatorSize
    ..indicatorType = elc?.indicatorType ?? EasyLoading.instance.indicatorType
    ..indicatorWidget =
        elc?.indicatorWidget ?? EasyLoading.instance.indicatorWidget
    ..infoWidget = elc?.infoWidget ?? EasyLoading.instance.infoWidget
    ..lineWidth = elc?.lineWidth ?? EasyLoading.instance.lineWidth
    ..loadingStyle = elc?.loadingStyle ?? EasyLoading.instance.loadingStyle
    ..maskColor = elc?.maskColor ?? EasyLoading.instance.maskColor
    ..maskType = elc?.maskType ?? EasyLoading.instance.maskType
    ..progressColor = elc?.progressColor ?? EasyLoading.instance.progressColor
    ..progressWidth = elc?.progressWidth ?? EasyLoading.instance.progressWidth
    ..radius = elc?.radius ?? EasyLoading.instance.radius
    ..successWidget = elc?.successWidget ?? EasyLoading.instance.successWidget
    ..textAlign = elc?.textAlign ?? EasyLoading.instance.textAlign
    ..textColor = elc?.textColor ?? EasyLoading.instance.textColor
    ..textPadding = elc?.textPadding ?? EasyLoading.instance.textPadding
    ..textStyle = elc?.textStyle ?? EasyLoading.instance.textStyle
    ..toastPosition = elc?.toastPosition ?? EasyLoading.instance.toastPosition
    ..userInteractions =
        elc?.userInteractions ?? EasyLoading.instance.userInteractions;
}

/// Run application with custom configuration
void fxRunApp(
  Widget app, {
  /// The orientations to use for the application.
  List<DeviceOrientation> orientations = const [DeviceOrientation.portraitUp],
  // Configuration for loader to be shown on loading data
  loaderConfig = const EasyLoadingConfig(
    backgroundColor: Colors.transparent,
    boxShadow: [],
    contentPadding: EdgeInsets.all(16),
    indicatorColor: Colors.white,
    indicatorSize: 36,
    indicatorType: EasyLoadingIndicatorType.foldingCube,
    loadingStyle: EasyLoadingStyle.custom,
    maskType: EasyLoadingMaskType.custom,
    maskColor: Colors.green,
    radius: 8,
    textColor: Colors.white,
    userInteractions: false,
  ),
}) {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  _initializeLoaderConfig(elc: loaderConfig);

  SystemChrome.setPreferredOrientations(orientations).then(
    (_) {
      /// We wait a few milliseconds to remove the splash screen so that the
      /// orientation is fully applied before removing it.
      Future.delayed(
        const Duration(milliseconds: 333),
        () => FlutterNativeSplash.remove(),
      );

      // Initialize app
      runApp(app);
    },
  );
}

Brightness computeBrightness(Color color, {bool reverse = false}) {
  final brightness = ThemeData.estimateBrightnessForColor(color);

  return reverse ? reverseBrightness(brightness) : brightness;
}

Brightness reverseBrightness(Brightness brightness) {
  return brightness == Brightness.dark ? Brightness.light : Brightness.dark;
}
