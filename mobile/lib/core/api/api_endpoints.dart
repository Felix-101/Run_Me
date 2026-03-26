import 'package:mobile/config/app_config.dart';

/// Base URL and path helpers. Call only after [AppConfig.load].
class Endpoint {
  Endpoint._();

  static String get baseUrl => AppConfig.serverBaseUrl;

  /// Trailing slash for path concatenation (e.g. `apiv3 + 'example'`).
  static String get apiv3 => '$baseUrl/';
}
