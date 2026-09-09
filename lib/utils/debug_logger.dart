import 'package:flutter/foundation.dart';

class DebugLogger {
  static bool isVerbose = true;

  static void log(String message, {String? tag}) {
    if (kDebugMode && isVerbose) {
      debugPrint('${DateTime.now()} ${tag ?? ''} $message');
    }
  }
}