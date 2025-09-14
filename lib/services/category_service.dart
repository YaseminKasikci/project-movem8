// lib/services/category_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:move_m8/config/api_config.dart';
import 'package:move_m8/models/category_model.dart';

import 'package:move_m8/services/base_service.dart';

class CategoryService extends BaseService {
  final _client = http.Client();

  Future<List<CategoryModel>> fetchAll() async {
    final uri = ApiConfig.path(['categories', 'all']);
    final res = await _client.get(uri, headers: await headers());

    if (kDebugMode) {
      debugPrint("📥 GET: $uri  -> ${res.statusCode}");
    }

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    }
    throw Exception("Erreur de chargement des catégories (${res.statusCode})");
  }

  Future<void> delete(int id) async {
    final uri = ApiConfig.path(['categories', 'delete', id.toString()]);
    final res = await _client.delete(uri, headers: await headers(mode: HeaderMode.basic));

    if (kDebugMode) {
      debugPrint("🗑️ DELETE: $uri  -> ${res.statusCode}");
      debugPrint("📥 Body: ${res.body}");
    }

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception("Erreur suppression : ${res.statusCode}");
    }
  }

  Future<void> update(int id, String name) async {
    final uri = ApiConfig.path(['categories', 'update', id.toString()]);
    final body = jsonEncode({"id": id, "categoryName": name});

    if (kDebugMode) {
      debugPrint("📤 PATCH: $uri");
      debugPrint("📤 Body: $body");
    }

    final res = await _client.patch(uri, headers: await headers(), body: body);

    if (kDebugMode) {
      debugPrint("📥 Status: ${res.statusCode}");
      debugPrint("📥 Body: ${res.body}");
    }

    if (res.statusCode != 200) {
      throw Exception("Erreur modification catégorie (${res.statusCode})");
    }
  }

  Future<CategoryModel> create(String name) async {
    final uri = ApiConfig.path(['categories', 'save']);
    final body = jsonEncode({"categoryName": name});

    if (kDebugMode) {
      debugPrint("📤 POST: $uri");
      debugPrint("📤 Body: $body");
    }

    final res = await _client.post(uri, headers: await headers(), body: body);

    if (kDebugMode) {
      debugPrint("📥 Status: ${res.statusCode}");
      debugPrint("📥 Body: ${res.body}");
    }

    if (res.statusCode == 201 || res.statusCode == 200) {
      return CategoryModel.fromJson(jsonDecode(res.body));
    }
    throw Exception("Erreur de création (${res.statusCode})");
  }
}
