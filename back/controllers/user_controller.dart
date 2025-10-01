import '../services/user_service.dart';
import '../models/user_model.dart';

class UserController {
  final UserService service;

  UserController(this.service);

  Future<void> createUser(String id, String name, String email) =>
      service.addUser(User(id: id, name: name, email: email));

  Future<List<User>> getUsers() => service.getUsers();
}