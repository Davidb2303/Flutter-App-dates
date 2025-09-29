import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // Configura tu URL base del backend
  static const String baseUrl = 'http://localhost:3000/api'; // Cambiar por tu URL
  
  // Usuario actual (guardado en memoria después del login)
  User? _currentUser;
  String? _authToken;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _authToken != null;

  // Headers con autenticación
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // ==================== AUTENTICACIÓN ====================

  /// Login de usuario
  Future<bool> login(String username, String password) async {
  await Future.delayed(Duration(seconds: 1)); // simula red

  if (username == "test@gmail.com" && password == "123456") {
    _authToken = "fake_token";
    _currentUser = User(
      userId: 1,
      username: username,
      passwordHash: "hashed_pass",
      photoUrl: "https://via.placeholder.com/150",
      name: "Usuario Demo",
      age: 25,
      interests: ["Flutter", "Dart"],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return true;
  }

  return false;
}

  /// Registro de nuevo usuario
  Future<bool> register(String name, String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        _currentUser = User.fromJson(data['user']);
        return true;
      }
      return false;
    } catch (e) {
      print('Error en registro: $e');
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _authToken = null;
    _currentUser = null;
  }

  // ==================== USUARIOS ====================

  /// Obtener usuarios potenciales para hacer match
  /// Excluye: usuarios ya con like/dislike, matches existentes
  Future<List<User>> getPotentialMatches() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/potential-matches'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo usuarios: $e');
      return [];
    }
  }

  /// Actualizar perfil del usuario actual
  Future<bool> updateProfile({
    String? name,
    int? age,
    String? photoUrl,
    List<String>? interests,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (age != null) body['age'] = age;
      if (photoUrl != null) body['photo_url'] = photoUrl;
      if (interests != null) body['interests'] = interests;

      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = User.fromJson(data);
        return true;
      }
      return false;
    } catch (e) {
      print('Error actualizando perfil: $e');
      return false;
    }
  }

  // ==================== LIKES/DISLIKES ====================

  /// Procesar swipe (like o dislike)
  /// Retorna true si hay match (solo en caso de like)
  Future<bool> processSwipe(int targetUserId, bool isLike) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/likes'),
        headers: _headers,
        body: jsonEncode({
          'target_user_id': targetUserId,
          'status': isLike ? 'like' : 'dislike',
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Si es un match mutuo, el backend retorna is_match: true
        return data['is_match'] == true;
      }
      return false;
    } catch (e) {
      print('Error procesando swipe: $e');
      return false;
    }
  }

  /// Obtener likes enviados por el usuario
  Future<List<Like>> getSentLikes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/likes/sent'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Like.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo likes: $e');
      return [];
    }
  }

  // ==================== MATCHES ====================

  /// Obtener todos los matches del usuario actual
  Future<List<Match>> getMatches() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/matches'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Match.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo matches: $e');
      return [];
    }
  }

  /// Eliminar un match
  Future<bool> unmatch(int matchId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/matches/$matchId'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error eliminando match: $e');
      return false;
    }
  }

  // ==================== SIMULACIÓN (para desarrollo sin backend) ====================

  /// Datos mock para desarrollo sin backend
  Future<List<User>> getMockUsers() async {
    await Future.delayed(Duration(milliseconds: 500));
    
    return [
      User(
        userId: 1,
        username: 'ana_garcia',
        passwordHash: '',
        name: 'Ana García',
        age: 25,
        photoUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b47c?w=400',
        interests: ['Viajar', 'Fotografía', 'Yoga', 'Cocinar'],
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      User(
        userId: 2,
        username: 'maria_lopez',
        passwordHash: '',
        name: 'María López',
        age: 28,
        photoUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
        interests: ['Arte', 'Senderismo', 'Música', 'Lectura'],
        createdAt: DateTime.now().subtract(Duration(days: 25)),
        updatedAt: DateTime.now(),
      ),
      User(
        userId: 3,
        username: 'carmen_ruiz',
        passwordHash: '',
        name: 'Carmen Ruiz',
        age: 26,
        photoUrl: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400',
        interests: ['Animales', 'Playa', 'Deportes', 'Cine'],
        createdAt: DateTime.now().subtract(Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  Future<List<Match>> getMockMatches() async {
    await Future.delayed(Duration(milliseconds: 300));
    
    return [
      Match(
        matchId: 1,
        user1Id: 0, // Usuario actual
        user2Id: 10,
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        matchedUser: User(
          userId: 10,
          username: 'sofia_martinez',
          passwordHash: '',
          name: 'Sofia Martinez',
          age: 24,
          photoUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
          interests: ['Medicina', 'Deportes'],
          createdAt: DateTime.now().subtract(Duration(days: 15)),
          updatedAt: DateTime.now(),
        ),
        lastMessage: '¡Hola! ¿Qué tal tu día?',
        lastMessageTime: DateTime.now().subtract(Duration(hours: 3)),
      ),
    ];
  }
}