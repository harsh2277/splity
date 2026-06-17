import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_env.dart';

class ApiException implements Exception {
  ApiException(this.statusCode, this.message, [this.details]);

  final int statusCode;
  final String message;
  final Object? details;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<Map<String, String>> _headers() async {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;

    if (token == null || token.isEmpty) {
      throw ApiException(401, 'You need to sign in first.');
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = AppEnv.apiBaseUrl.endsWith('/')
        ? AppEnv.apiBaseUrl.substring(0, AppEnv.apiBaseUrl.length - 1)
        : AppEnv.apiBaseUrl;
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final response = await _httpClient.get(
      _uri(path, query),
      headers: await _headers(),
    );
    return _decode(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await _httpClient.post(
      _uri(path),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final response = await _httpClient.patch(
      _uri(path),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  dynamic _decode(http.Response response) {
    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decoded is Map<String, dynamic> ? decoded['error'] : null;
      throw ApiException(
        response.statusCode,
        error is Map<String, dynamic>
            ? error['message'] as String? ?? 'Request failed'
            : 'Request failed',
        error is Map<String, dynamic> ? error['details'] : null,
      );
    }

    return decoded is Map<String, dynamic> && decoded.containsKey('data')
        ? decoded['data']
        : decoded;
  }
}
