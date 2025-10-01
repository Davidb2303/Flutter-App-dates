import '../services/match_service.dart';
import '../models/match_model.dart';

class MatchController {
  final MatchService service;

  MatchController(this.service);

  Future<void> createMatch(String userId1, String userId2) =>
      service.addMatch(Match(userId1: userId1, userId2: userId2));

  Future<List<Match>> getMatches() => service.getMatches();
}