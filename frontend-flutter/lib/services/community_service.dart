// 📁 lib/services/community_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/community_model.dart';

class CommunityException implements Exception {
  final String message;
  CommunityException(this.message);
}

class CommunityService {
  final _client = http.Client();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Map<String, String> _headers({String? token, bool json = true}) {
    final h = <String, String>{
      'Accept': 'application/json',
    };
    if (json) h['Content-Type'] = 'application/json';
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  // ---------- READ ----------
  Future<List<CommunityModel>> fetchAll() async {
    final token = await _getToken();
    if (token == null) throw CommunityException('Vous devez être connecté.');

    final uri = ApiConfig.path(['communities', 'all']);
    try {
      if (kDebugMode) debugPrint('📥 GET $uri');
      final resp = await _client.get(uri, headers: _headers(token: token));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as List;
        return body
            .map((e) => CommunityModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        throw CommunityException('Accès non autorisé – veuillez vous reconnecter.');
      }
      throw CommunityException('Erreur serveur (${resp.statusCode}).');
    } on SocketException {
      throw CommunityException('Impossible de joindre le serveur. Vérifiez votre connexion.');
    } on FormatException {
      throw CommunityException('Données invalides reçues.');
    } catch (e) {
      throw CommunityException('Erreur inattendue : ${e.toString()}');
    }
  }

  Future<CommunityModel> getById(int id) async {
    final uri = ApiConfig.path(['communities', id.toString()]);
    if (kDebugMode) debugPrint('📥 GET $uri');
    final resp = await _client.get(uri, headers: _headers(json: false)); // public (ajoute token si protégé)

    if (resp.statusCode == 200) {
      return CommunityModel.fromJson(jsonDecode(resp.body));
    }
    throw CommunityException('Impossible de charger la communauté ($id) [${resp.statusCode}]');
  }

  // ---------- ACTIONS UTILISATEUR ----------
  Future<void> joinCommunity(int userId, int communityId) async {
    final token = await _getToken();
    if (token == null) throw CommunityException('Vous devez être connecté.');

    final uri = ApiConfig.path(['communities', 'users', userId.toString(), 'join-community', communityId.toString()]);
    try {
      if (kDebugMode) debugPrint('📤 POST $uri');
      final resp = await _client.post(uri, headers: _headers(token: token));

      if (resp.statusCode != 200) {
        if (resp.statusCode == 401 || resp.statusCode == 403) {
          throw CommunityException('Accès non autorisé.');
        }
        throw CommunityException('Impossible de rejoindre (code ${resp.statusCode}).');
      }
    } on SocketException {
      throw CommunityException('Impossible de joindre le serveur.');
    } catch (e) {
      throw CommunityException('Erreur inattendue : ${e.toString()}');
    }
  }

  Future<void> chooseCommunity(int userId, int communityId) async {
    final token = await _getToken();
    if (token == null) throw CommunityException('Vous devez être connecté.');

    final uri = ApiConfig.path(['communities', 'users', userId.toString(), 'choose-community', communityId.toString()]);
    try {
      if (kDebugMode) debugPrint('📤 POST $uri');
      final resp = await _client.post(uri, headers: _headers(token: token));

      if (resp.statusCode != 200) {
        if (resp.statusCode == 401 || resp.statusCode == 403) {
          throw CommunityException('Accès non autorisé.');
        }
        throw CommunityException('Impossible de sélectionner (code ${resp.statusCode}).');
      }
    } on SocketException {
      throw CommunityException('Impossible de joindre le serveur.');
    } catch (e) {
      throw CommunityException('Erreur inattendue : ${e.toString()}');
    }
  }

  // ---------- ADMIN CRUD ----------
  Future<CommunityModel> create(String name) async {
    final token = await _getToken();
    if (token == null) throw CommunityException('Vous devez être connecté.');

    final uri = ApiConfig.path(['communities', 'save']);
    if (kDebugMode) debugPrint('📤 POST $uri');
    final resp = await _client.post(
      uri,
      headers: _headers(token: token),
      body: jsonEncode({'communityName': name}),
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return CommunityModel.fromJson(jsonDecode(resp.body));
    }
    if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw CommunityException('Accès non autorisé.');
    }
    throw CommunityException('Erreur création (${resp.statusCode}).');
  }

  Future<void> update(int id, String name) async {
    final token = await _getToken();
    if (token == null) throw CommunityException('Vous devez être connecté.');

    final uri = ApiConfig.path(['communities', 'update', id.toString()]);
    if (kDebugMode) debugPrint('📤 PATCH $uri');
    final resp = await _client.patch(
      uri,
      headers: _headers(token: token),
      body: jsonEncode({'id': id, 'communityName': name}),
    );

    if (resp.statusCode == 200) return;
    if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw CommunityException('Accès non autorisé.');
    }
    throw CommunityException('Erreur modification (${resp.statusCode}).');
  }

  Future<void> delete(int id) async {
    final token = await _getToken();
    if (token == null) throw CommunityException('Vous devez être connecté.');

    final uri = ApiConfig.path(['communities', 'delete', id.toString()]);
    if (kDebugMode) debugPrint('🗑️ DELETE $uri');
    final resp = await _client.delete(uri, headers: _headers(token: token, json: false));

    if (resp.statusCode == 204 || resp.statusCode == 200) return;
    if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw CommunityException('Accès non autorisé.');
    }
    throw CommunityException('Erreur suppression (${resp.statusCode}).');
  }
}
