import 'package:flutter/foundation.dart';

/// Server address comes from `--dart-define=SERVER_URL=...` or the Play online field.
/// Release builds do not fall back to dev tokens. Debug builds can, for a local server.
class AppConfig {
  static const serverUrl = String.fromEnvironment('SERVER_URL');

  static bool get allowDevAuth {
    const mode = String.fromEnvironment('AUTH_MODE');
    if (mode == 'guest' || mode == 'firebase') return false;
    if (mode == 'dev') return true;
    return kDebugMode;
  }
}
