import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../controllers/auth_controller.dart';

AuthController? _controller;

void initAuthRoutes(AuthController controller) {
  _controller = controller;
}

Future<Response> signupHandler(Request request) async {
  if (_controller == null) {
    return Response.internalServerError(body: 'Controller not initialized');
  }
  if (request.method == 'POST') {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    // Validación básica
    if (data['email'] == null || data['password'] == null) {
      return Response.badRequest(body: 'Email and password required');
    }

    try {
      final auth = await _controller!.signup(data['email'], data['password']);
      if (auth != null) {
        return Response.ok(jsonEncode(auth.toJson()), headers: {'content-type': 'application/json'});
      }
      return Response.forbidden('No se pudo registrar');
    } catch (e) {
      return Response.forbidden(e.toString());
    }
  }
  return Response.notFound('Not Found');
}