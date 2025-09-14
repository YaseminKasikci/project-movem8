// lib/services/base_service.dart
import 'package:move_m8/services/auth_service.dart';

enum HeaderMode { json, basic }

class BaseService {
  Future<Map<String, String>> headers({HeaderMode mode = HeaderMode.json, bool withAuth = true}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (mode == HeaderMode.json) {
      headers['Content-Type'] = 'application/json; charset=utf-8';
    }

    if (withAuth) {
      final token = await AuthService().getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }
}
