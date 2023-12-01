import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit/utils/helpers.dart';

class _PopScopeWrapper extends StatelessWidget {
  final Future<bool> Function()? onWillPop;
  final Widget child;

  const _PopScopeWrapper({
    Key? key,
    required this.onWillPop,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (onWillPop == null) return child;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;

        if (await onWillPop!() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}

class _AnnotatedRegionWrapper extends StatelessWidget {
  final Widget child;
  final Color statusBarColor;
  final Brightness? statusBarForcedBrightness;
  final bool transparentStatusBar;

  const _AnnotatedRegionWrapper({
    Key? key,
    required this.child,
    required this.statusBarColor,
    this.statusBarForcedBrightness,
    required this.transparentStatusBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusBarBrightness = statusBarForcedBrightness ??
        (transparentStatusBar ? null : computeColorBrightness(statusBarColor));

    final reversedStatusBarBrightness = statusBarBrightness != null
        ? reverseBrightness(statusBarBrightness)
        : null;

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        statusBarBrightness: statusBarBrightness,
        statusBarIconBrightness: reversedStatusBarBrightness,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: child,
    );
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
  final EdgeInsetsGeometry padding;
  final bool transparentStatusBar;

  const _SafeAreaWrapper(
    this.safeArea,
    this.child,
    this.padding,
    this.transparentStatusBar, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return safeArea
        ? SafeArea(
            top: !transparentStatusBar,
            child: Padding(
              padding: padding,
              child: child,
            ),
          )
        : Padding(padding: padding, child: child);
  }
}

class Layout extends StatelessWidget {
  final Widget child;

  /// The color of the [SystemUiOverlayStyle.statusBarColor] for this page.
  final Color? statusBarColor;

  /// Whether the [SystemUiOverlayStyle.statusBarColor] should be transparent.
  /// If true, [statusBarColor] will be ignored.
  final bool transparentStatusBar;
  final Brightness? statusBarForcedBrightness;
  final bool safeArea;
  final EdgeInsetsGeometry padding;
  final Future<void> Function()? onPullToRefresh;
  final Future<bool> Function()? onWillPop;

  /// A layout widget that can be used to wrap a page.
  const Layout({
    Key? key,
    required this.child,
    this.statusBarColor,
    this.transparentStatusBar = false,
    this.statusBarForcedBrightness,
    this.safeArea = true,
    this.padding = const EdgeInsets.all(0),
    this.onPullToRefresh,
    this.onWillPop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _PopScopeWrapper(
      onWillPop: onWillPop,
      child: _AnnotatedRegionWrapper(
        statusBarColor: transparentStatusBar
            ? Colors.transparent
            : (statusBarColor ?? Theme.of(context).primaryColor),
        statusBarForcedBrightness: statusBarForcedBrightness,
        transparentStatusBar: transparentStatusBar,
        child: Scaffold(
          appBar: transparentStatusBar
              ? null
              : PreferredSize(
                  preferredSize: Size.zero,
                  child: Container(
                    color: statusBarColor ?? Theme.of(context).primaryColor,
                  ),
                ),
          body: _RefreshIndicatorWrapper(
            onRefresh: onPullToRefresh,
            child: _SafeAreaWrapper(
              safeArea,
              child,
              padding,
              transparentStatusBar,
            ),
          ),
        ),
      ),
    );
  }
}
