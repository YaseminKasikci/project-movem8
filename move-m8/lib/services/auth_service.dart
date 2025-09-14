// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/auth_model.dart';

/// Exception métier pour remonter un message d’erreur à l’UI
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

class AuthService {
  // ----------------------
  // Helpers en-têtes
  // ----------------------
  Map<String, String> _jsonHeaders({String? token}) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  // ----------------------
  // 1) REGISTER
  // ----------------------
  Future<void> register(String email, String password) async {
    final uri = ApiConfig.path(['auth', 'register']);
    try {
      final resp = await http
          .post(
            uri,
            headers: _jsonHeaders(),
            body: jsonEncode({
              'email': email,
              'password': password,
              'confirmPassword': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      switch (resp.statusCode) {
        case 201:
          await initiateLogin(email, password);
          return;
        case 400:
          throw ApiException('Email ou mot de passe invalide');
        case 403:
        case 409:
          throw ApiException('Cet email est déjà utilisé');
        default:
          throw ApiException('Erreur serveur (${resp.statusCode})');
      }
    } on SocketException {
      throw ApiException('Impossible de joindre le serveur.');
    } on TimeoutException {
      throw ApiException('Délai dépassé. Réessaie.');
    } catch (e) {
      throw ApiException('Erreur inattendue: $e');
    }
  }

  // ----------------------
  // 2) LOGIN (étape 1)
  // ----------------------
  Future<void> initiateLogin(String email, String password) async {
    final uri = ApiConfig.path(['auth', 'login']);
    try {
      final resp = await http
          .post(
            uri,
            headers: _jsonHeaders(),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode != 204) {
        throw ApiException(
          resp.statusCode == 401
              ? 'Email ou mot de passe incorrect'
              : 'Erreur serveur (${resp.statusCode})',
        );
      }
    } on SocketException {
      throw ApiException('Impossible de joindre le serveur.');
    } on TimeoutException {
      throw ApiException('Délai dépassé. Réessaie.');
    } catch (e) {
      throw ApiException('Erreur inattendue: $e');
    }
  }

  // ----------------------
  // 3) LOGIN VERIFY (étape 2)
  // ----------------------
  Future<AuthModel> verifyLogin(String email, String code) async {
    final uri = ApiConfig.path(['auth', 'login', 'verify']);
    try {
      final resp = await http
          .post(
            uri,
            headers: _jsonHeaders(),
            body: jsonEncode({'email': email, 'code': code}),
          )
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final auth = AuthModel.fromJson(data);
        await _storeToken(auth);
        await _fetchAndStoreUserProfile(auth.token);
        return auth;
      }

      if (resp.statusCode == 403) {
        throw ApiException('Code invalide ou expiré');
      }

      throw ApiException('Erreur serveur (${resp.statusCode})');
    } on SocketException {
      throw ApiException('Impossible de joindre le serveur.');
    } on TimeoutException {
      throw ApiException('Délai dépassé. Réessaie.');
    } on FormatException {
      throw ApiException('Réponse invalide du serveur.');
    } catch (e) {
      throw ApiException('Erreur inattendue: $e');
    }
  }

  // ----------------------
  // 4) PROFILE ME
  // ----------------------
  Future<void> _fetchAndStoreUserProfile(String token) async {
    final uri = ApiConfig.path(['users', 'me']);
    try {
      final resp = await http
          .get(
            uri,
            headers: _jsonHeaders(token: token),
          )
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', resp.body);
        return;
      }

      throw ApiException('Impossible de charger le profil utilisateur (${resp.statusCode})');
    } on SocketException {
      throw ApiException('Impossible de joindre le serveur.');
    } on TimeoutException {
      throw ApiException('Délai dépassé. Réessaie.');
    } catch (e) {
      throw ApiException('Erreur inattendue: $e');
    }
  }

  // ----------------------
  // 5) Mot de passe oublié
  // ----------------------
  Future<void> forgotPassword(String email) async {
    final uri = ApiConfig.path(['auth', 'forgot-password']);
    try {
      final resp = await http.post(
        uri,
        headers: _jsonHeaders(),
        body: jsonEncode({'email': email}),
      );
      if (resp.statusCode != 200) {
        // on ne révèle pas l’existence de l’email
        throw ApiException('Une erreur est survenue. Réessayez plus tard.');
      }
    } on SocketException {
      throw ApiException('Impossible de joindre le serveur.');
    }
  }

  // ----------------------
  // 6) Reset password
  // ----------------------
  Future<void> resetPassword(String token, String newPassword) async {
    final uri = ApiConfig.path(['auth', 'reset-password']);
    try {
      final resp = await http.post(
        uri,
        headers: _jsonHeaders(),
        body: jsonEncode({'token': token, 'newPassword': newPassword}),
      );
      if (resp.statusCode == 200) return;
      if (resp.statusCode == 401) {
        throw ApiException('Token invalide ou expiré');
      }
      throw ApiException('Erreur serveur (${resp.statusCode})');
    } on SocketException {
      throw ApiException('Impossible de joindre le serveur.');
    }
  }

  // ----------------------
  // 7) Logout & token utils
  // ----------------------
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<AuthModel> _storeToken(AuthModel auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', auth.token);
    await prefs.setString('auth', jsonEncode(auth.toJson()));
    return auth;
  }
}
