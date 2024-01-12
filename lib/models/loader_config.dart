import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// TODO Abstraer propiedades que dependen de EasyLoading
class FkLoaderConfig {
  final Duration? animationDuration;
  final EasyLoadingAnimationStyle? animationStyle;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final EdgeInsets? contentPadding;
  final EasyLoadingAnimation? customAnimation;
  final bool? dismissOnTap;
  final Duration? displayDuration;
  final Widget? errorWidget;
  final double? fontSize;
  final Color? indicatorColor;
  final double? indicatorSize;
  final EasyLoadingIndicatorType? indicatorType;
  final Widget? indicatorWidget;
  final Widget? infoWidget;
  final double? lineWidth;
  final EasyLoadingStyle? loadingStyle;
  final Color? maskColor;
  final EasyLoadingMaskType? maskType;
  final Color? progressColor;
  final double? progressWidth;
  final double? radius;
  final Widget? successWidget;
  final TextAlign? textAlign;
  final Color? textColor;
  final EdgeInsets? textPadding;
  final TextStyle? textStyle;
  final EasyLoadingToastPosition? toastPosition;
  final bool? userInteractions;

  const FkLoaderConfig({
    this.animationDuration,
    this.animationStyle,
    this.backgroundColor,
    this.boxShadow,
    this.contentPadding,
    this.customAnimation,
    this.dismissOnTap,
    this.displayDuration,
    this.errorWidget,
    this.fontSize,
    this.indicatorColor,
    this.indicatorSize,
    this.indicatorType,
    this.indicatorWidget,
    this.infoWidget,
    this.lineWidth,
    this.loadingStyle,
    this.maskColor,
    this.maskType,
    this.progressColor,
    this.progressWidth,
    this.radius,
    this.successWidget,
    this.textAlign,
    this.textColor,
    this.textPadding,
    this.textStyle,
    this.toastPosition,
    this.userInteractions,
  });
}
