// lib/services/activity_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:move_m8/config/api_config.dart';
import 'package:move_m8/models/activity_model.dart';
import 'base_service.dart';

class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);
  @override
  String toString() => 'ApiException($statusCode): $body';
}

class ActivityService extends BaseService {
  final http.Client _client;
  ActivityService({http.Client? client}) : _client = client ?? http.Client();

  /// POST /api/activities/save
  Future<ActivityDetail> create(CreateActivityRequest req) async {
    final uri = ApiConfig.path(['activities', 'save']); // ✅ /api/activities/save

    if (kDebugMode) {
      debugPrint('➡️ POST $uri');
      debugPrint('➡️ Body: ${jsonEncode(req.toJson())}');
    }

    final res = await _client.post(
      uri,
      headers: await headers(), // JSON + Bearer depuis BaseService
      body: jsonEncode(req.toJson()),
    );

    if (kDebugMode) {
      debugPrint('⬅️ Status: ${res.statusCode}');
      debugPrint('⬅️ Body: ${res.body}');
    }

    if (res.statusCode == 200 || res.statusCode == 201) {
      return ActivityDetail.fromJson(jsonDecode(res.body));
    }
    throw ApiException(res.statusCode, res.body);
  }

  /// GET /api/activities/{id}
  Future<ActivityDetail> getById(int id) async {
    final uri = ApiConfig.path(['activities', id.toString()]);

    if (kDebugMode) debugPrint('➡️ GET $uri');

    final res = await _client.get(uri, headers: await headers());

    if (kDebugMode) {
      debugPrint('⬅️ Status: ${res.statusCode}');
      debugPrint('⬅️ Body: ${res.body}');
    }

    if (res.statusCode == 200) {
      return ActivityDetail.fromJson(jsonDecode(res.body));
    }
    throw ApiException(res.statusCode, res.body);
  }

/// PATCH /api/activities/update/{id}  -> met à jour partiellement et renvoie le détail
  Future<ActivityDetail> update(int id, ActivityUpdateRequest req) async {
    final uri = ApiConfig.path(['activities', 'update', id.toString()]);

    // on n’envoie que les champs non-nuls
    final payload = req.toJson();

    if (kDebugMode) {
      debugPrint('➡️ PATCH $uri');
      debugPrint('➡️ Body: ${jsonEncode(payload)}');
    }

    final res = await _client.patch(
      uri,
      headers: await headers(),
      body: jsonEncode(payload),
    );

    if (kDebugMode) {
      debugPrint('⬅️ Status: ${res.statusCode}');
      debugPrint('⬅️ Body: ${res.body}');
    }

    if (res.statusCode == 200) {
      return ActivityDetail.fromJson(jsonDecode(res.body));
    }
    throw ApiException(res.statusCode, res.body);
  }

  /// GET /api/activities?communityId=...
  Future<List<ActivityCard>> list({int? communityId}) async {
    final base = ApiConfig.path(['activities']);
    final uri = base.replace(queryParameters: {
      if (communityId != null) 'communityId': communityId.toString(),
    });

    if (kDebugMode) debugPrint('➡️ GET $uri');

    final res = await _client.get(uri, headers: await headers());

    if (kDebugMode) {
      debugPrint('⬅️ Status: ${res.statusCode}');
      debugPrint('⬅️ Body: ${res.body}');
    }

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => ActivityCard.fromJson(e)).toList();
    }
    throw ApiException(res.statusCode, res.body);
  }

    /// DELETE /api/activities/delete/{id}
  Future<void> delete(int id) async {
    final uri = ApiConfig.path(['activities', 'delete', id.toString()]);

    if (kDebugMode) debugPrint('➡️ DELETE $uri');

    final res = await _client.delete(uri, headers: await headers());

    if (kDebugMode) {
      debugPrint('⬅️ Status: ${res.statusCode}');
      debugPrint('⬅️ Body: ${res.body}');
    }

    if (res.statusCode == 200) {
      return; // succès → rien à renvoyer
    }
    throw ApiException(res.statusCode, res.body);
  }
}
