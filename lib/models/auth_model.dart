class AuthModel {
  final int userId;
  final String email;
  final String token;
  final int? communityId;

  AuthModel({
    required this.userId,
    required this.email,
    required this.token,
    this.communityId,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
    userId: json['userId'],
    email: json['email'],
    token: json['token'],
    communityId: json['communityId'],
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'token': token,
    'communityId': communityId,
  };
}
