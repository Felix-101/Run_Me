import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Central token storage used by sources and [AuthRepository].
class SecureStorage {
  SecureStorage();

  static const _tokenKey = 'accessToken';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> tokenRead() => _storage.read(key: _tokenKey);

  Future<void> tokenWrite(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> tokenDelete() => _storage.delete(key: _tokenKey);
}
