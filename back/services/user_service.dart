import 'package:supabase/supabase.dart';
import '../models/user_model.dart' as models;

class UserService {
  final SupabaseClient client;

  UserService(this.client);

  Future<List<models.User>> getUsers() async {
    final result = await client.from('users').select();
    // result es List<dynamic>
    return result.map((json) => models.User.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> addUser(models.User user) async {
    await client.from('users').insert(user.toJson());
    // Si necesitas el resultado, puedes capturarlo:
    // final result = await client.from('users').insert(user.toJson());
  }
}