// 📁 lib/models/community_model.dart

class CommunityModel {
  final int id;
  final String communityName;

  CommunityModel({
    required this.id,
    required this.communityName,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    // certain backends renvoient "id", d'autres "id_community"
    final rawId = json['id'] ?? json['id_community'];
    // si rawId est null, on tombe sur 0 (vous pouvez ajuster)
    final parsedId = rawId == null
        ? 0
        : rawId is int
            ? rawId
            : int.tryParse(rawId.toString()) ?? 0;

    // idem pour le nom de communauté
    final rawName = json['communityName'] ?? json['community_name'];
    final name = rawName?.toString() ?? '';

    return CommunityModel(
      id: parsedId,
      communityName: name,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'communityName': communityName,
      };
}
