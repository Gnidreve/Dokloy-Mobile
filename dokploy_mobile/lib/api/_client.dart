import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  String get _baseUrl {
    final raw = dotenv.env['BASE_URL']?.trim() ?? '';
    if (raw.isEmpty) throw const ApiException('BASE_URL fehlt in der .env Datei.');
    return _normalize(raw);
  }

  String get _apiKey {
    final key = dotenv.env['API_KEY']?.trim() ?? '';
    if (key.isEmpty) throw const ApiException('API_KEY fehlt in der .env Datei.');
    return key;
  }

  Future<dynamic> get(
    String path, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _http
        .get(uri, headers: {'x-api-key': _apiKey, 'accept': 'application/json'})
        .timeout(timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('HTTP ${response.statusCode} bei $path.');
    }

    return jsonDecode(response.body);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _http
        .post(
          uri,
          headers: {
            'x-api-key': _apiKey,
            'accept': 'application/json',
            'content-type': 'application/json',
          },
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('HTTP ${response.statusCode} bei $path.');
    }

    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  static String _normalize(String raw) {
    var url = raw;
    if ((url.startsWith('"') && url.endsWith('"')) ||
        (url.startsWith("'") && url.endsWith("'"))) {
      url = url.substring(1, url.length - 1);
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      url = 'http://$url';
    }
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
