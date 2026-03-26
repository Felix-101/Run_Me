import '../models/admin_summary.dart';
import '../models/me.dart';
import '../modules/secure_storage.dart';
import '../services/api_client.dart';

class AuthRepository {
  final ApiClient api;
  final SecureStorage _storage;

  AuthRepository({
    required this.api,
    SecureStorage? storage,
  }) : _storage = storage ?? SecureStorage();

  Future<String?> getAccessToken() => _storage.tokenRead();

  Future<void> saveAccessToken(String token) => _storage.tokenWrite(token);

  Future<void> clearAccessToken() => _storage.tokenDelete();

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

