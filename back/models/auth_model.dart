class Auth {
  final String userId;
  final String token;

  Auth({required this.userId, required this.token});

  factory Auth.fromJson(Map<String, dynamic> json) => Auth(
        userId: json['userId'] as String,
        token: json['token'] as String,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'token': token,
      };
}