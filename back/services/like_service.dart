import 'package:supabase/supabase.dart';
import '../models/like_model.dart';

class LikeService {
  final SupabaseClient client;

  LikeService(this.client);

  Future<void> addLike(Like like) async {
    await client.from('likes').insert(like.toJson());
    
  }

  Future<List<Like>> getLikes() async {
    final result = await client.from('likes').select();
    
    return result.map((json) => Like.fromJson(json as Map<String, dynamic>)).toList();
  }
}