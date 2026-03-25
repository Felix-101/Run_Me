import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/admin_summary.dart';
import '../models/me.dart';
import '../services/api_client.dart';

class AuthRepository {
  final ApiClient api;
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'accessToken';

  AuthRepository({required this.api}) : _storage = const FlutterSecureStorage();

  Future<String?> getAccessToken() => _storage.read(key: _tokenKey);

  Future<void> saveAccessToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<void> clearAccessToken() => _storage.delete(key: _tokenKey);

  Future<String> login({required String email, required String password}) async {
    final json = await api.postJson('/auth/login', {
      'email': email,
      'password': password,
    });
    final token = json['accessToken'] as String?;
    if (token == null) throw Exception('Login failed (missing accessToken)');
    return token;
  }

  Future<Me> fetchMe() async {
    final token = await getAccessToken();
    if (token == null) throw Exception('Not authenticated');
    return api.getMe(accessToken: token);
  }

  Future<AdminSummary> fetchAdminSummary() async {
    final token = await getAccessToken();
    if (token == null) throw Exception('Not authenticated');
    return api.getAdminSummary(accessToken: token);
  }
}

