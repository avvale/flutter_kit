import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

class Debugger {
  static void log(String key, [Object? value, printLongSrt = false]) {
    if (kDebugMode) {
      print('[DEBUG] $key');

      if (value != null) {
        if (value is String && printLongSrt) {
          developer.log(value);
        } else {
          print(value);
        }
      }
    }
  }
}
