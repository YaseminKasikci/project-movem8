import 'package:flutter/material.dart';
import '../enums/level.dart';

/// ---------- Level helpers ----------
Level levelFromJson(String? s) {
  if (s == null) return Level.B; // fallback
  try {
    return Level.values.byName(s); // attend 'D','B','I','E'
  } catch (_) {
    return Level.B; // fallback
  }
}

String levelToJson(Level l) => l.name;

extension LevelX on Level {
  String get label => switch (this) {
        Level.D => 'Découverte',
        Level.B => 'Débutant',
        Level.I => 'Intermédiaire',
        Level.E => 'Expert',
      };

  String get hex => switch (this) {
        Level.D => '#60C8B3',
        Level.B => '#6EA1D4',
        Level.I => '#FFA74F',
        Level.E => '#1B5091',
      };

  Color get color => _hexToColor(hex);
}

Color _hexToColor(String hex) {
  assert(hex.startsWith('#'));
  final h = hex.replaceFirst('#', '');
  final value = (h.length == 6)
      ? int.parse('FF$h', radix: 16)
      : int.parse(h, radix: 16);
  return Color(value);
}

/// ---------- CreateActivityRequest ----------
class CreateActivityRequest {
  final String title;
  final String? photo; // URL (optionnel)
  final String description;
  final String location;
  final DateTime dateHour; // format ISO local
  final double price;
  final int numberOfParticipant;
  final Level level;
  final int sportId;
  final int communityId;

  CreateActivityRequest({
    required this.title,
    required this.description,
    required this.location,
    required this.dateHour,
    required this.price,
    required this.numberOfParticipant,
    required this.level,
    required this.sportId,
    required this.communityId,
    this.photo,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        if (photo != null) 'photo': photo,
        'description': description,
        'location': location,
        'dateHour': dateHour.toIso8601String().split('Z').first, // sans TZ
        'price': price,
        'numberOfParticipant': numberOfParticipant,
        'level': levelToJson(level),
        'sportId': sportId,
        'communityId': communityId,
      };
}

/// ---------- ActivityCard (mini carte) ----------
class ActivityCard {
  final int id;
  final String title;
  final String description;
  final String? photo;
  final String location;
  final DateTime dateHour;


  final double note;

  final int numberOfParticipant;
  final Level level;

  final int? sportId;
  final String? sportName;
  final int? communityId;

  // creator
  final int? creatorId;
  final String? creatorFirstName;
  final String? creatorPhotoUrl;
  final int? creatorAge;

  ActivityCard({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dateHour,
    required this.note,
    required this.numberOfParticipant,
    required this.level,
    this.photo,
    this.sportId,
    this.sportName,
    this.communityId,
    this.creatorId,
    this.creatorFirstName,
    this.creatorPhotoUrl,
    this.creatorAge,
  });

  factory ActivityCard.fromJson(Map<String, dynamic> json) {
    return ActivityCard(
      id: _asInt(json['id']) ?? 0,
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      photo: json['photo'] as String?,
      location: (json['location'] ?? '') as String,
      dateHour: _asDateTime(json['dateHour']) ?? DateTime.now(),
      // Ici, on tolére price/note null -> 0.0
      note: _asDouble(json['note'] ?? json['price']) ?? 0.0,
      numberOfParticipant: _asInt(json['numberOfParticipant']) ?? 0,
      level: levelFromJson(json['level'] as String?),
      sportId: _asInt(json['sportId']),
      sportName: json['sportName'] as String?,
      creatorId: _asInt(json['creatorId']),
      creatorFirstName: json['creatorFirstName'] as String?,
      creatorPhotoUrl: json['creatorPhotoUrl'] as String?,
      creatorAge: _asInt(json['creatorAge']),
      communityId: _asInt(json['communityId']),
    );
  }
}

/// ---------- ActivityUpdateRequest ----------
class ActivityUpdateRequest {
  final String? title;
  final String? description;
  final String? location;
  final DateTime? dateHour;
  final double? price;
  final int? numberOfParticipant;
  final String? photo;
  final Level? level; // optionnel
  final int? sportId; // optionnel

  ActivityUpdateRequest({
    this.title,
    this.description,
    this.location,
    this.dateHour,
    this.price,
    this.numberOfParticipant,
    this.photo,
    this.level,
    this.sportId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (dateHour != null)
        'dateHour': dateHour!.toIso8601String().split('Z').first,
      if (price != null) 'price': price,
      if (numberOfParticipant != null)
        'numberOfParticipant': numberOfParticipant,
      if (photo != null) 'photo': photo,
      if (level != null) 'level': level!.name, // 'D','B','I','E'
      if (sportId != null) 'sportId': sportId,
    };
    return map;
  }
}

/// ---------- ActivityDetail (fiche) ----------
class ActivityDetail {
  final int id;
  final String title;
  final String? photo;
  final String description;
  final String location;
  final DateTime dateHour;
  final double price;
  final double? note;
  final int numberOfParticipant;
  final Level level;
  final String? statusActivity;

  // sport
  final int? sportId;
  final String? sportName;

  // creator
  final int? creatorId;
  final String? creatorFirstName;
  final String? creatorLastName;
  final String? creatorPhotoUrl;
  final int? creatorAge;

  final int? communityId;

  ActivityDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dateHour,
    required this.price,
    required this.numberOfParticipant,
    required this.level,
    this.photo,
    this.note,
    this.statusActivity,
    this.sportId,
    this.sportName,
    this.creatorId,
    this.creatorFirstName,
    this.creatorLastName,
    this.creatorPhotoUrl,
    this.creatorAge,
    this.communityId,
  });

  factory ActivityDetail.fromJson(Map<String, dynamic> json) {
    return ActivityDetail(
      id: _asInt(json['id']) ?? 0,
      title: (json['title'] ?? '') as String,
      photo: json['photo'] as String?,
      description: (json['description'] ?? '') as String,
      location: (json['location'] ?? '') as String,
      dateHour: _asDateTime(json['dateHour']) ?? DateTime.now(),
      price: _asDouble(json['price']) ?? 0.0,
      note: _asDouble(json['note']),
      numberOfParticipant: _asInt(json['numberOfParticipant']) ?? 0,
      level: levelFromJson(json['level'] as String?),
      statusActivity: json['statusActivity'] as String?,
      sportId: _asInt(json['sportId']),
      sportName: json['sportName'] as String?,
      creatorId: _asInt(json['creatorId']),
      creatorFirstName: json['creatorFirstName'] as String?,
      creatorLastName: json['creatorLastName'] as String?,
      creatorPhotoUrl: json['creatorPhotoUrl'] as String?,
      creatorAge: _asInt(json['creatorAge']),
      communityId: _asInt(json['communityId']),
    );
  }
}

/// ---------- utils robustes pour parsing ----------
int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

double? _asDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.replaceAll(',', '.'));
  return null;
}

DateTime? _asDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) {
    // tente ISO standard
    final dt = DateTime.tryParse(v);
    if (dt != null) return dt;
  }
  return null;
}
