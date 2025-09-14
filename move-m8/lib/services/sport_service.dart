// lib/services/sport_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:move_m8/config/api_config.dart';
import 'package:move_m8/models/sport_model.dart';
import 'package:move_m8/services/auth_service.dart';
import 'base_service.dart';

class SportService extends BaseService {
  final _client = http.Client();

  /// Liste des sports d'une catégorie (GET JSON)
  Future<List<SportModel>> fetchByCategory(int categoryId) async {
    final uri = ApiConfig.path(['sports', 'category', categoryId.toString()]);
    final res = await _client.get(uri, headers: await headers());

    if (kDebugMode) {
      debugPrint('📥 GET $uri  -> ${res.statusCode}');
    }

    if (res.statusCode == 200) {
      final raw = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();

      // 🔧 Normalise les URLs d’icônes renvoyées en localhost
      for (final m in raw) {
        final u = m['iconUrl'];
        if (u is String) m['iconUrl'] = ApiConfig.fixImageHost(u);
      }
      return raw.map(SportModel.fromJson).toList();
    }
    throw Exception('Erreur de chargement des sports (${res.statusCode})');
  }

  /// Création d’un sport (multipart/form-data)
  /// Back attend: sportName (text), categoryId (text), icon (file) optionnel
  Future<SportModel> create(int categoryId, String sportName, File? iconFile) async {
    final uri = ApiConfig.path(['sports', 'save']);
    final token = await AuthService().getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token manquant : reconnectez-vous.');
    }

    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['sportName'] = sportName
      ..fields['categoryId'] = categoryId.toString();

    if (iconFile != null) {
      req.files.add(
        await http.MultipartFile.fromPath(
          'icon', // ⚠️ doit matcher @RequestPart("icon")
          iconFile.path,
          contentType: _mediaTypeFor(iconFile.path),
        ),
      );
    }

    if (kDebugMode) {
      debugPrint('📤 POST multipart: $uri');
      debugPrint('📤 fields: ${req.fields}');
      debugPrint('📤 file: ${iconFile?.path}');
    }

    final resp = await req.send();
    final body = await resp.stream.bytesToString();

    if (kDebugMode) {
      debugPrint('📥 Status: ${resp.statusCode}');
      debugPrint('📥 Body: $body');
    }

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final map = jsonDecode(body) as Map<String, dynamic>;
      // 🔧 corrige l’URL d’icône si le back renvoie localhost
      if (map['iconUrl'] is String) {
        map['iconUrl'] = ApiConfig.fixImageHost(map['iconUrl']);
      }
      return SportModel.fromJson(map);
    }
    throw Exception('Erreur création sport (${resp.statusCode})');
  }

  /// Mise à jour d’un sport (multipart/form-data)
  /// Back prend: sportName (text, optionnel), icon (file, optionnel)
  Future<SportModel> update(int sportId, String sportName, File? iconFile) async {
    final uri = ApiConfig.path(['sports', 'update', sportId.toString()]);
    final token = await AuthService().getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token manquant : reconnectez-vous.');
    }

    final req = http.MultipartRequest('PATCH', uri)
      ..headers['Authorization'] = 'Bearer $token';

    if (sportName.isNotEmpty) {
      req.fields['sportName'] = sportName;
    }
    if (iconFile != null) {
      req.files.add(
        await http.MultipartFile.fromPath(
          'icon',
          iconFile.path,
          contentType: _mediaTypeFor(iconFile.path),
        ),
      );
    }

    if (kDebugMode) {
      debugPrint('📤 PATCH multipart: $uri');
      debugPrint('📤 fields: ${req.fields}');
      debugPrint('📤 file: ${iconFile?.path}');
    }

    final resp = await req.send();
    final body = await resp.stream.bytesToString();

    if (kDebugMode) {
      debugPrint('📥 Status: ${resp.statusCode}');
      debugPrint('📥 Body: $body');
    }

    if (resp.statusCode == 200) {
      final map = jsonDecode(body) as Map<String, dynamic>;
      if (map['iconUrl'] is String) {
        map['iconUrl'] = ApiConfig.fixImageHost(map['iconUrl']);
      }
      return SportModel.fromJson(map);
    }
    throw Exception('Erreur modification sport (${resp.statusCode})');
  }

  /// Suppression sport
  Future<void> delete(int sportId) async {
    final uri = ApiConfig.path(['sports', 'delete', sportId.toString()]);
    final res = await _client.delete(uri, headers: await headers());

    if (kDebugMode) {
      debugPrint('📤 DELETE: $uri');
      debugPrint('📥 Status: ${res.statusCode}');
      debugPrint('📥 Body: ${res.body}');
    }

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Erreur suppression sport (${res.statusCode})');
    }
  }

  /// Devine un MediaType correct pour le fichier icône
  MediaType _mediaTypeFor(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.png'))  return MediaType('image', 'png');
    if (p.endsWith('.jpg') || p.endsWith('.jpeg')) return MediaType('image', 'jpeg');
    if (p.endsWith('.webp')) return MediaType('image', 'webp');
    if (p.endsWith('.svg'))  return MediaType('image', 'svg+xml');
    // valeur par défaut safe
    return MediaType('image', 'jpeg');
  }
}
