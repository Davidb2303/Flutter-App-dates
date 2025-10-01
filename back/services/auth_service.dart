import 'package:supabase/supabase.dart';
import '../models/auth_model.dart';

class AuthService {
  final SupabaseClient client;

  AuthService(this.client);

  Future<Auth?> signup(String email, String password) async {
    final response = await client.auth.signUp(email: email, password: password);
    if (response.user != null && response.session != null) {
      return Auth(userId: response.user!.id, token: response.session!.accessToken);
    }
    return null;
  }
  
  Future<Auth?> login(String email, String password) async {
    final response = await client.auth.signInWithPassword(email: email, password: password);
    if (response.user != null && response.session != null) {
      return Auth(userId: response.user!.id, token: response.session!.accessToken);
    }
    return null;
  }

  Future<void> logout() async {
    await client.auth.signOut();
  }
}