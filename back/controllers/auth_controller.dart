import '../services/auth_service.dart';
import '../models/auth_model.dart';

class AuthController {
  final AuthService service;

  AuthController(this.service);

  Future<Auth?> signup(String email, String password) =>
      service.signup(email, password);
  
  Future<Auth?> login(String email, String password) =>
      service.login(email, password);

  Future<void> logout() => service.logout();
}