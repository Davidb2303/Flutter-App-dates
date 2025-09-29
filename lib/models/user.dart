class User {
  final int userId;
  final String username;
  final String passwordHash;
  final String? photoUrl;
  final String name;
  final int? age;
  final List<String> interests;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.userId,
    required this.username,
    required this.passwordHash,
    this.photoUrl,
    required this.name,
    this.age,
    required this.interests,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      passwordHash: json['password_hash'] ?? '',
      photoUrl: json['photo_url'],
      name: json['name'] ?? '',
      age: json['age'],
      interests: json['interests'] != null 
          ? List<String>.from(json['interests'])
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'password_hash': passwordHash,
      'photo_url': photoUrl,
      'name': name,
      'age': age,
      'interests': interests,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Para la UI (mantener compatibilidad)
  String get displayName => name;
  List<String> get photos => photoUrl != null ? [photoUrl!] : [];
  String get bio => interests.isNotEmpty ? interests.join(' • ') : '';
  String get location => 'Online'; // Esto lo puedes agregar a la tabla si lo necesitas
  double get distance => 0.0; // Esto lo puedes calcular con coordenadas si las agregas
}

class Like {
  final int likeId;
  final int userId;
  final int targetUserId;
  final String status; // 'like' o 'dislike'
  final DateTime createdAt;

  Like({
    required this.likeId,
    required this.userId,
    required this.targetUserId,
    required this.status,
    required this.createdAt,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      likeId: json['like_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      targetUserId: json['target_user_id'] ?? 0,
      status: json['status'] ?? 'like',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'like_id': likeId,
      'user_id': userId,
      'target_user_id': targetUserId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isLike => status == 'like';
  bool get isDislike => status == 'dislike';
}

class Match {
  final int matchId;
  final int user1Id;
  final int user2Id;
  final DateTime createdAt;
  
  // Datos adicionales para la UI (se obtienen con JOIN)
  final User? matchedUser;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  Match({
    required this.matchId,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    this.matchedUser,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      matchId: json['match_id'] ?? 0,
      user1Id: json['user1_id'] ?? 0,
      user2Id: json['user2_id'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      matchedUser: json['matched_user'] != null
          ? User.fromJson(json['matched_user'])
          : null,
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'match_id': matchId,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'created_at': createdAt.toIso8601String(),
      'matched_user': matchedUser?.toJson(),
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
    };
  }

  // Para compatibilidad con la UI
  User get user => matchedUser!;
  DateTime get matchedAt => createdAt;
  bool get isRead => false; // Agregar tabla de mensajes si necesitas esto
}