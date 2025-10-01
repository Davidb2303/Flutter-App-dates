class Match {
  final String userId1;
  final String userId2;

  Match({required this.userId1, required this.userId2});

  factory Match.fromJson(Map<String, dynamic> json) => Match(
        userId1: json['userId1'] as String,
        userId2: json['userId2'] as String,
      );

  Map<String, dynamic> toJson() => {
        'userId1': userId1,
        'userId2': userId2,
      };
}