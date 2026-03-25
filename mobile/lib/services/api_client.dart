import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../models/admin_summary.dart';
import '../models/me.dart';

class ApiClient {
  final Dio _dio;

  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.serverBaseUrl,
            headers: const {
              'Content-Type': 'application/json',
            },
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final res = await _dio.post(path, data: body);
    return res.data as Map<String, dynamic>;
  }

  Future<Me> getMe({required String accessToken}) async {
    final res = await _dio.get(
      '/me',
      options: Options(headers: { 'Authorization': 'Bearer $accessToken' }),
    );
    final json = res.data as Map<String, dynamic>;
    return Me.fromJson(json);
  }

  Future<AdminSummary> getAdminSummary({required String accessToken}) async {
    final res = await _dio.get(
      '/admin/summary',
      options: Options(headers: { 'Authorization': 'Bearer $accessToken' }),
    );
    final json = res.data as Map<String, dynamic>;
    return AdminSummary.fromJson(json);
  }
}

