import 'package:shelf/shelf.dart';
import '../controllers/match_controller.dart';

MatchController? _controller;

void initMatchRoutes(MatchController controller) {
  _controller = controller;
}

Future<Response> matchHandler(Request request) async {
  if (_controller == null) return Response.internalServerError(body: 'Controller not initialized');
  if (request.method == 'POST') {
    await _controller!.createMatch('1', '2');
    return Response.ok('Match created between User 1 and User 2');
  }
  if (request.method == 'GET') {
    final matches = await _controller!.getMatches();
    return Response.ok(matches.map((m) => m.toJson()).toList().toString());
  }
  return Response.notFound('Not Found');
}