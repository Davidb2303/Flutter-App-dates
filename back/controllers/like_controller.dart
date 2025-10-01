import '../services/like_service.dart';
import '../models/like_model.dart';

class LikeController {
  final LikeService service;

  LikeController(this.service);

  Future<void> likeUser(String userId, String likedUserId) =>
      service.addLike(Like(userId: userId, likedUserId: likedUserId));

  Future<List<Like>> getLikes() => service.getLikes();
}