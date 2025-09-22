class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime sentAt;

  // Optionnels pour la liste de conversations
  final int? communityId;
  final int? activityId;
  final String? sportName;
  final String? creatorFirstName;
  final String? creatorLastName;
  final String? creatorPhotoUrl;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    this.communityId,
    this.activityId,
    this.sportName,
    this.creatorFirstName,
    this.creatorLastName,
    this.creatorPhotoUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
    id: j['id'] ?? '',
    conversationId: j['conversationId'] ?? '',
    senderId: j['senderId'] ?? '',
    content: j['content'] ?? '',
    sentAt: j['sentAt'] != null ? DateTime.parse(j['sentAt']) : DateTime.now(),
    communityId: j['communityId'],
    activityId: j['activityId'],
    sportName: j['sportName'],
    creatorFirstName: j['creatorFirstName'],
    creatorLastName: j['creatorLastName'],
    creatorPhotoUrl: j['creatorPhotoUrl'],
  );
}
