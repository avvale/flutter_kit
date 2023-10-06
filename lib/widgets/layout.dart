import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit/utils/helpers.dart';

class _AnnotatedRegionWrapper extends StatelessWidget {
  final Widget child;
  final Color? statusBarColor;
  final Brightness? brightness;

  const _AnnotatedRegionWrapper({
    Key? key,
    required this.child,
    this.statusBarColor,
    this.brightness,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return statusBarColor != null
        ? AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarBrightness:
                  brightness ?? computeBrightness(statusBarColor!),
              statusBarIconBrightness: brightness != null
                  ? reverseBrightness(brightness!)
                  : computeBrightness(
                      statusBarColor!,
                      reverse: true,
                    ),
            ),
            child: child,
          )
        : child;
  }
}

class _RefreshIndicatorWrapper extends StatelessWidget {
  final Future<void> Function()? onRefresh;
  final Widget child;

  const _RefreshIndicatorWrapper({
    Key? key,
    required this.onRefresh,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return onRefresh != null
        ? RefreshIndicator(
            onRefresh: onRefresh!,
            child: child,
          )
        : child;
  }
}

class _SafeAreaWrapper extends StatelessWidget {
  final bool safeArea;
  final Widget child;

  const _SafeAreaWrapper(this.safeArea, this.child);

  @override
  Widget build(BuildContext context) {
    return safeArea ? SafeArea(child: child) : child;
  }
}

class Layout extends StatelessWidget {
  final Widget child;
  final Color? statusBarColor;
  final Brightness? statusBarForcedBrightness;
  final bool safeArea;
  final Future<void> Function()? onPullToRefresh;
  final Future<bool> Function()? onWillPop;

  /// A layout widget that can be used to wrap a page.
  const Layout({
    Key? key,
    required this.child,
    this.statusBarColor,
    this.statusBarForcedBrightness,
    this.safeArea = true,
    this.onPullToRefresh,
    this.onWillPop,
  }) : super(key: key);

  Future<bool> _onWillPop() async {
    if (onWillPop != null) {
      return onWillPop!();
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: _AnnotatedRegionWrapper(
        statusBarColor: statusBarColor,
        brightness: statusBarForcedBrightness,
        child: Scaffold(
          appBar: statusBarColor != null
              ? PreferredSize(
                  preferredSize: Size.zero,
                  child: Container(color: statusBarColor),
                )
              : null,
          body: _RefreshIndicatorWrapper(
            onRefresh: onPullToRefresh,
            child: _SafeAreaWrapper(safeArea, child),
          ),
        ),
      ),
    );
  }
}
