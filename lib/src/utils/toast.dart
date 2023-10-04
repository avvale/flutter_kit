import 'package:flutter/material.dart';
import 'package:flutter_kit/src/widgets/common/fx_app.dart';

enum ToastMode {
  success,
  error,
  warning,
  info,
}

const Map<ToastMode, MaterialColor> _toastColors = {
  ToastMode.success: Colors.green,
  ToastMode.error: Colors.red,
  ToastMode.warning: Colors.yellow,
  ToastMode.info: Colors.blue,
};

class Toast {
  static void show(
    String text, {
    Duration duration = const Duration(seconds: 3),
    ToastMode mode = ToastMode.success,
    Color? backgroundColor,
  }) {
    final ScaffoldMessengerState? sm = rootScaffoldMessengerKey.currentState;
    sm?.hideCurrentSnackBar();
    sm?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(text),
        duration: duration,
        backgroundColor: backgroundColor ?? _toastColors[mode],
      ),
    );
  }
}
