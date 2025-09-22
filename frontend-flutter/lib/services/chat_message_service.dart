import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/chat_message.dart';

class ChatMessageService {
  /// Récupère l’historique d’une conversation
  Future<List<ChatMessage>> getHistory(String conversationId, {int limit = 50}) async {
    final uri = ApiConfig.path(['chat', 'history', conversationId])
        .replace(queryParameters: {'limit': '$limit'});

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Erreur getHistory: ${res.statusCode} ${res.body}');
    }

    final List data = jsonDecode(res.body) as List;
    return data.map((j) => ChatMessage.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// Envoie un message
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  }) async {
    final uri = ApiConfig.path(['chat', 'send']);

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'conversationId': conversationId,
        'senderId': senderId,
        'content': content,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Erreur sendMessage: ${res.statusCode} ${res.body}');
    }

    final Map<String, dynamic> data = jsonDecode(res.body);
    return ChatMessage.fromJson(data);
  }


 Future<List<ChatMessage>> listConversations(int communityId, {int limit = 50}) async {
  final uri = ApiConfig.path(['chat', 'conversations'])
      .replace(queryParameters: {'communityId': '$communityId', 'limit': '$limit'});

  final res = await http.get(uri);
  if (res.statusCode != 200) {
    throw Exception("Erreur ${res.statusCode}: ${res.body}");
  }

  final List data = jsonDecode(res.body);
  return data.map((j) => ChatMessage.fromJson(j)).toList();
}


}
