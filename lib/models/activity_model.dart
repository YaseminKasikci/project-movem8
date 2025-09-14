import 'dart:convert';
import 'package:flutter/material.dart';

// --- Enums ---
// Utilise TON enum existant. Adapte l'import si besoin (ex: 'package:movem8/enums/level.dart')
import '../enums/level.dart';

Level levelFromJson(String? s) {
  if (s == null) return Level.B; // fallback
  try {
    // Dart 2.17+ : byName sur les enums (noms attendus: D, B, I, E)
    return Level.values.byName(s);
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
      ? int.parse('FF$h', radix: 16) // alpha 100%
      : int.parse(h, radix: 16);     // déjà ARGB
  return Color(value);
}

// ----------------------
// CreateActivityRequest
// ----------------------
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

  CreateActivityRequest({
    required this.title,
    required this.description,
    required this.location,
    required this.dateHour,
    required this.price,
    required this.numberOfParticipant,
    required this.level,
    required this.sportId,
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
      };
}

// ----------------------
// ActivityCard (mini carte)
// ----------------------
class ActivityCard {
  final int id;
  final String title;
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
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      photo: json['photo'] as String?,
      location: json['location'] as String,
      dateHour: DateTime.parse(json['dateHour'] as String),
      note: (json['price'] as num).toDouble(),
      numberOfParticipant: (json['numberOfParticipant'] as num).toInt(),
      level: levelFromJson(json['level'] as String?),
      sportId: (json['sportId'] as num?)?.toInt(),
      sportName: json['sportName'] as String?,
      creatorId: (json['creatorId'] as num?)?.toInt(),
      creatorFirstName: json['creatorFirstName'] as String?,
      creatorPhotoUrl: json['creatorPhotoUrl'] as String?,
      creatorAge: (json['creatorAge'] as num?)?.toInt(),
      communityId: (json['communityId'] as num?)?.toInt(),
    );
  }
}

// ----------------------
// ActivityDetail (fiche)
// ----------------------
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
  final String? statusActivity; // gardé en String pour éviter le mismatch enum

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
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      photo: json['photo'] as String?,
      description: json['description'] as String,
      location: json['location'] as String,
      dateHour: DateTime.parse(json['dateHour'] as String),
      price: (json['price'] as num).toDouble(),
      note: (json['note'] as num?)?.toDouble(),
      numberOfParticipant: (json['numberOfParticipant'] as num).toInt(),
      level: levelFromJson(json['level'] as String?),
      statusActivity: json['statusActivity'] as String?,
      sportId: (json['sportId'] as num?)?.toInt(),
      sportName: json['sportName'] as String?,
      creatorId: (json['creatorId'] as num?)?.toInt(),
      creatorFirstName: json['creatorFirstName'] as String?,
      creatorLastName: json['creatorLastName'] as String?,
      creatorPhotoUrl: json['creatorPhotoUrl'] as String?,
      creatorAge: (json['creatorAge'] as num?)?.toInt(),
      communityId: (json['communityId'] as num?)?.toInt(),
    );
  }
}
