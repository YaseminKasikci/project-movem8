// lib/services/participant_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:move_m8/config/api_config.dart';
import 'package:move_m8/models/participant_model.dart';

class ParticipantService {
  final _client = http.Client();

  Uri _u(List<String> seg, [Map<String, dynamic>? qp]) =>
      ApiConfig.path(['activities', ...seg]).replace(
        queryParameters: qp?.map((k, v) => MapEntry(k, '$v')),
      );

  // GET /api/activities/{id}/participants
  Future<List<ParticipantModel>> list(int activityId) async {
    final res = await _client.get(_u(['$activityId', 'participants']));
    if (res.statusCode != 200) {
      throw Exception('participants: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as List;
    return data.map((e) => ParticipantModel.fromJson(e)).toList();
  }

  // POST /api/activities/{activityId}/request/{userId}
  Future<void> request(int activityId, int userId) async {
    final res = await _client.post(_u(['$activityId', 'request', '$userId']));
    if (res.statusCode != 200) {
      throw Exception('request: ${res.statusCode} ${res.body}');
    }
  }

  // PATCH /api/activities/{activityId}/validate/{participantId}?creatorId={id}
  Future<ParticipantModel> validate({
    required int activityId,
    required int participantId,
    required int creatorId,
  }) async {
    final res = await _client.patch(_u(
      ['$activityId', 'validate', '$participantId'],
      {'creatorId': creatorId},
    ));
    if (res.statusCode != 200) {
      throw Exception('validate: ${res.statusCode} ${res.body}');
    }
    return ParticipantModel.fromJson(jsonDecode(res.body));
  }

  // DELETE /api/activities/{activityId}/remove/{userId}
  Future<void> remove(int activityId, int userId) async {
    final res = await _client.delete(_u(['$activityId', 'remove', '$userId']));
    if (res.statusCode != 200) {
      throw Exception('remove: ${res.statusCode} ${res.body}');
    }
  }

  // POST /api/activities/{activityId}/rate?rating=4.5
  Future<double> rate(int activityId, double rating) async {
    final res =
        await _client.post(_u(['$activityId', 'rate'], {'rating': rating}));
    if (res.statusCode != 200) {
      throw Exception('rate: ${res.statusCode} ${res.body}');
    }
    return (jsonDecode(res.body) as num).toDouble();
  }
}


