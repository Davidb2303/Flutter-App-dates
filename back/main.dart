import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:supabase/supabase.dart';
  
import 'routes/auth_routes.dart';
import 'routes/user_routes.dart';
import 'routes/like_routes.dart';
import 'routes/match_routes.dart';

import 'controllers/auth_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/like_controller.dart';
import 'controllers/match_controller.dart';

import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/like_service.dart';
import 'services/match_service.dart';

// TODO: Replace with your Supabase project URL and anon key
const supabaseUrl = 'https://uxguaegvtwglaybrshxj.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV4Z3VhZWd2dHdnbGF5YnJzaHhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwODAxMjQsImV4cCI6MjA3NDY1NjEyNH0.GbZiZpfzWnLjvY-QQSJNrwrf0f6Rr_7DIQncIbWHewY';

void main() async {
  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  final authService = AuthService(supabase);
  final userService = UserService(supabase);
  final likeService = LikeService(supabase);
  final matchService = MatchService(supabase);

  final authController = AuthController(authService);
  final userController = UserController(userService);
  final likeController = LikeController(likeService);
  final matchController = MatchController(matchService);

  initAuthRoutes(authController);
  initUserRoutes(userController);
  initLikeRoutes(likeController);
  initMatchRoutes(matchController);

  final handler = Cascade()
    .add(authHandler)
    .add(userHandler)
    .add(likeHandler)
    .add(matchHandler)
    .handler;

  final server = await io.serve(handler, 'localhost', 8080);
  print('Server listening on port ${server.port}');
}