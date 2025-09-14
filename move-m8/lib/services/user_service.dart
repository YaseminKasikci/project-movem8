// lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:move_m8/models/user_model.dart';
import 'package:move_m8/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class UserService {
  final _client = http.Client();

  Future<void> completeProfile(int userId, UserModel user) async {
    final token = await AuthService().getToken();
    final uri = ApiConfig.path(['users', 'complete-profile']); // /api/users/complete-profile

    final payload = <String, dynamic>{
      "firstName": user.firstName,
      "lastName": user.lastName,
      "description": user.description,
      "gender": user.gender,
        if (user.birthday != null)
      "birthday": DateFormat('dd-MM-yyyy').format(user.birthday!),
      "pictureProfile": user.pictureProfile,
      "role": user.role,
    }..removeWhere((_, v) => v == null);

    final res = await _client.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      String message = 'Erreur profil (${res.statusCode})';
      try {
        final data = jsonDecode(res.body);
        if (data is Map && data['detail'] is String) message = data['detail'];
        if (data is Map && data['message'] is String) message = data['message'];
      } catch (_) {}
      throw Exception(message);
    }
  }

  Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<UserModel> getMyProfile() async {
    final token = await AuthService().getToken();
    final uri = ApiConfig.path(['users', 'me']);
    final res = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("Erreur lors de la récupération du profil (${res.statusCode})");
    }
  }
}
