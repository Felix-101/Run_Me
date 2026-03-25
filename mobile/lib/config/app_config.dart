import 'dart:convert';

import 'package:flutter/services.dart';

class AppConfig {
  static late final String serverBaseUrl;

  static Future<void> load() async {
    final raw = await rootBundle.loadString('assets/config.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    serverBaseUrl = decoded['server_base_url'] as String;
  }
}

