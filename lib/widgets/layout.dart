import 'package:flutter/material.dart';

class Layout extends StatelessWidget {
  final Widget child;
  final String? title;
  final Future<void> Function()? onPullToRefresh;
  final Future<bool> Function()? onWillPop;

  /// A layout widget that can be used to wrap a page.
  const Layout({
    Key? key,
    required this.child,
    this.title,
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
      child: Scaffold(
        appBar: null,
        body: onPullToRefresh != null
            ? RefreshIndicator(
                onRefresh: onPullToRefresh!,
                child: child,
              )
            : child,
      ),
    );
  }
}
