import 'package:Tobbo/domain/entities/poll.dart';
import 'package:Tobbo/domain/entities/poll_vote.dart';

abstract class PollRepository {
  Future<Poll> createPoll({
    required String question,
    required List<String> options,
    required bool shareWithNearby,
  });

  Future<List<Poll>> getNearbyPolls({required double radiusKm});

  Future<Poll> getPoll(String publicCode);

  Future<PollVote> vote({
    required String publicCode,
    required String optionId,
  });

  Future<List<Poll>> getMyPolls();

  Future<List<Poll>> getMyVotes();

  Future<void> clearLocalData();
}
