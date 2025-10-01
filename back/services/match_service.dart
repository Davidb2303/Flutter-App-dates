import 'package:supabase/supabase.dart';
import '../models/match_model.dart';

class MatchService {
  final SupabaseClient client;

  MatchService(this.client);

  Future<void> addMatch(Match match) async {
    await client.from('matches').insert(match.toJson());
    // Si necesitas el resultado, puedes capturarlo:
    // final result = await client.from('matches').insert(match.toJson());
  }

  Future<List<Match>> getMatches() async {
    final result = await client.from('matches').select();
    // result es List<dynamic>
    return result.map((json) => Match.fromJson(json as Map<String, dynamic>)).toList();
  }
}