// lib/models/user_model.dart
import 'package:intl/intl.dart';

class UserModel {
  final int id;                
  final String firstName;
  final String lastName;
  final String? gender;
  final String? description;
  final String? pictureProfile;
  final DateTime? birthday;
  final bool? verifiedProfile;
  final bool? paymentMade;
  final String? role;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.description,
    this.pictureProfile,
    this.birthday,
    this.verifiedProfile,
    this.paymentMade,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,    
      firstName: (json['firstName'] as String?) ?? '',
      lastName:  (json['lastName']  as String?) ?? '',
      gender: json['gender'] as String?,
      description: json['description'] as String?,
      pictureProfile: json['pictureProfile'] as String?,
      birthday: _parseBirthday(json['birthday']),
      verifiedProfile: json['verifiedProfile'] as bool?,
      paymentMade: json['paymentMade'] as bool?,
      role: json['role'] as String?,
    );
  }

  static DateTime? _parseBirthday(dynamic v) {
    if (v == null) return null;
    if (v is! String) return null;
    final s = v.trim();
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;
    try { return DateFormat('dd-MM-yyyy').parseStrict(s); } catch (_) {}
    try { return DateFormat('dd/MM/yyyy').parseStrict(s); } catch (_) {}
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'description': description,
    'pictureProfile': pictureProfile,
    'gender': gender,
    'birthday': birthday?.toIso8601String().split('T').first, // yyyy-MM-dd
    'role': role,
    if (verifiedProfile != null) 'verifiedProfile': verifiedProfile,
    if (paymentMade != null) 'paymentMade': paymentMade,
  };
}
