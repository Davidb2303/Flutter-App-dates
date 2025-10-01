import 'package:shelf/shelf.dart';
import '../controllers/like_controller.dart';

LikeController? _controller;

void initLikeRoutes(LikeController controller) {
  _controller = controller;
}

Future<Response> likeHandler(Request request) async {
  if (_controller == null) return Response.internalServerError(body: 'Controller not initialized');
  if (request.method == 'POST') {
    await _controller!.likeUser('1', '2');
    return Response.ok('User 1 liked User 2');
  }
  if (request.method == 'GET') {
    final likes = await _controller!.getLikes();
    return Response.ok(likes.map((l) => l.toJson()).toList().toString());
  }
  return Response.notFound('Not Found');
}