import 'dart:io';

import 'package:mobile/core/api/api_endpoints.dart';
import 'package:mobile/core/network_request/network_request.dart';
import 'package:mobile/core/network_retry/network_retry.dart';
import 'package:mobile/modules/secure_storage.dart';

abstract class ExampleSource {
  Future<String> getData();
}

class ExampleSourceImpl implements ExampleSource {
  final NetworkRequest networkRequest;
  final NetworkRetry networkRetry;

  ExampleSourceImpl({
    required this.networkRequest,
    required this.networkRetry,
  });

  @override
  Future<String> getData() async {
    final token = await SecureStorage().tokenRead();
    if (token == null) throw Exception('Unauthorized');

    final url = '${Endpoint.apiv3}example';
    final response = await networkRetry.networkRetry(
      () => networkRequest.get(
        url,
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      ),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
    return response.body;
  }
}
