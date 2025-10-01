import 'package:shelf/shelf.dart';
import '../controllers/user_controller.dart';

UserController? _controller;

void initUserRoutes(UserController controller) {
  _controller = controller;
}

Future<Response> userHandler(Request request) async {
  if (_controller == null) return Response.internalServerError(body: 'Controller not initialized');
  if (request.method == 'POST') {
    await _controller!.createUser('1', 'Alice', 'alice@email.com');
    return Response.ok('User Alice created');
  }
  if (request.method == 'GET') {
    final users = await _controller!.getUsers();
    return Response.ok(users.map((u) => u.toJson()).toList().toString());
  }
  return Response.notFound('Not Found');
}