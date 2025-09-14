// lib/models/sport_model.dart
import 'package:move_m8/config/api_config.dart';

class SportModel {
  final int id;
  final String sportName;
  final String? iconUrl;

  SportModel({
    required this.id,
    required this.sportName,
    this.iconUrl,
  });

  factory SportModel.fromJson(Map<String, dynamic> json) {
    final raw = json['iconUrl'] as String?;
    final fixed = raw == null ? null : ApiConfig.fixImageHost(raw);
    return SportModel(
      id: (json['id'] as num).toInt(),
      sportName: json['sportName'] as String,
      iconUrl: fixed,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sportName': sportName,
    'iconUrl': iconUrl,
  };
}
