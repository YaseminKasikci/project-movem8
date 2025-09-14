// lib/models/participant_model.dart


enum StatusParticipant { WAITING, VALIDATED, REFUSED }

StatusParticipant statusParticipantFromString(String s) {
  switch (s) {
    case 'W': ///waiting
      return StatusParticipant.WAITING;
    case 'C':  //coming
      return StatusParticipant.VALIDATED;
    case 'R':   //refused
      return StatusParticipant.REFUSED;
    default:
      return StatusParticipant.WAITING;
  }
}

class ParticipantModel {
  final int id;
  final int activityId;
  final int userId;
  final StatusParticipant status;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final int? age;

  ParticipantModel({
    required this.id,
    required this.activityId,
    required this.userId,
    required this.status,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.age,
  });

factory ParticipantModel.fromJson(Map<String, dynamic> json) {
  final activityIdRaw = json['activity']?['id'] ?? json['activityId'];
  final userIdRaw = json['user']?['id'] ?? json['userId'];

  return ParticipantModel(
    id: (json['id'] as num).toInt(),
    activityId: (activityIdRaw is num) ? activityIdRaw.toInt() : 0,
    userId: (userIdRaw is num) ? userIdRaw.toInt() : 0,
    status: statusParticipantFromString(
      (json['statusParticipant'] ?? json['status'] ?? 'WAITING') as String,
    ),
    firstName: json['user']?['firstName'] as String?,
    lastName: json['user']?['lastName'] as String?,
    avatarUrl: json['user']?['photoUrl'] as String?,
    age: (json['user']?['age'] as num?)?.toInt(),
  );
}

}
