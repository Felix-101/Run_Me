import 'package:http/http.dart' as http;

class NetworkRequest {
  final http.Client _client;

  NetworkRequest({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> get(String url, {Map<String, String>? headers}) {
    return _client.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _client.post(Uri.parse(url), headers: headers, body: body);
  }
}
