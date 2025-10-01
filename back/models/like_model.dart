class Like {
  final String userId;
  final String likedUserId;

  Like({required this.userId, required this.likedUserId});

  factory Like.fromJson(Map<String, dynamic> json) => Like(
        userId: json['userId'] as String,
        likedUserId: json['likedUserId'] as String,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'likedUserId': likedUserId,
      };
}