import 'package:flutter/foundation.dart';
import 'package:Tobbo/data/datasources/sample_poll_datasource.dart';
import 'package:Tobbo/domain/entities/poll.dart';
import 'package:Tobbo/domain/entities/poll_option.dart';
import 'package:Tobbo/domain/entities/poll_vote.dart';
import 'package:Tobbo/domain/enums/poll_status.dart';
import 'package:Tobbo/domain/repositories/poll_repository.dart';

class PollRepositoryImpl extends ChangeNotifier implements PollRepository {
  PollRepositoryImpl(this._source);

  final SamplePollDataSource _source;
  int _createdCount = 0;

  @override
  Future<Poll> createPoll({
    required String question,
    required List<String> options,
    required bool shareWithNearby,
  }) async {
    _createdCount++;
    final id = 'p-local-$_createdCount';
    final poll = SamplePollRecord(
      id: id,
      publicCode: _codeFor(id),
      question: question.trim(),
      createdByUserId: SamplePollDataSource.currentUserId,
      createdAt: DateTime.now().toUtc(),
      distanceKm: shareWithNearby ? 0.2 : null,
      shareWithNearby: shareWithNearby,
      options: [
        for (var i = 0; i < options.length; i++)
          SampleOptionRecord(
            id: '$id-o${i + 1}',
            text: options[i].trim(),
            sortOrder: i + 1,
            voteCount: 0,
          ),
      ],
    );
    _source.polls.insert(0, poll);
    notifyListeners();
    return _toEntity(poll);
  }

  @override
  Future<List<Poll>> getNearbyPolls({required double radiusKm}) async {
    return _source.polls
        .where((p) => p.shareWithNearby && p.distanceKm != null && p.distanceKm! <= radiusKm)
        .map(_toEntity)
        .toList()
      ..sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
  }

  @override
  Future<Poll> getPoll(String publicCode) async {
    final poll = _source.findByCode(publicCode);
    if (poll == null) {
      throw StateError("We couldn't load this question.");
    }
    return _toEntity(poll);
  }

  @override
  Future<PollVote> vote({
    required String publicCode,
    required String optionId,
  }) async {
    final poll = _source.findByCode(publicCode);
    if (poll == null) {
      throw StateError("We couldn't load this question.");
    }
    if (poll.status == PollStatus.expired) {
      throw StateError('This question has closed.');
    }
    if (_voteFor(poll.id) != null) {
      throw StateError("You've already voted.");
    }
    SampleOptionRecord? option;
    for (final item in poll.options) {
      if (item.id == optionId) option = item;
    }
    if (option == null) {
      throw StateError("That option isn't available.");
    }
    option.voteCount++;
    final vote = SampleVoteRecord(
      pollId: poll.id,
      optionId: optionId,
      userId: SamplePollDataSource.currentUserId,
      votedAt: DateTime.now().toUtc(),
    );
    _source.votes.add(vote);
    notifyListeners();
    return PollVote(
      pollId: vote.pollId,
      optionId: vote.optionId,
      userId: vote.userId,
      votedAt: vote.votedAt,
    );
  }

  @override
  Future<List<Poll>> getMyPolls() async {
    return _source.polls
        .where((p) => p.createdByUserId == SamplePollDataSource.currentUserId)
        .map(_toEntity)
        .toList();
  }

  @override
  Future<List<Poll>> getMyVotes() async {
    final mine = _source.votes.where((v) => v.userId == SamplePollDataSource.currentUserId);
    return [
      for (final vote in mine)
        _toEntity(_source.polls.firstWhere((p) => p.id == vote.pollId)),
    ];
  }

  @override
  Future<void> clearLocalData() async {
    _source.reset();
    _createdCount = 0;
    notifyListeners();
  }

  SampleVoteRecord? _voteFor(String pollId) {
    for (final vote in _source.votes) {
      if (vote.pollId == pollId && vote.userId == SamplePollDataSource.currentUserId) {
        return vote;
      }
    }
    return null;
  }

  Poll _toEntity(SamplePollRecord poll) {
    final vote = _voteFor(poll.id);
    String? votedText;
    if (vote != null) {
      votedText = poll.options.firstWhere((o) => o.id == vote.optionId).text;
    }
    return Poll(
      id: poll.id,
      publicCode: poll.publicCode,
      question: poll.question,
      options: [
        for (final option in poll.options)
          PollOption(
            id: option.id,
            text: option.text,
            sortOrder: option.sortOrder,
            voteCount: option.voteCount,
          ),
      ],
      voteCount: poll.voteCount,
      distanceKm: poll.distanceKm,
      createdAt: poll.createdAt,
      expiresAt: poll.expiresAt,
      status: poll.status,
      createdByUserId: poll.createdByUserId,
      shareWithNearby: poll.shareWithNearby,
      hasVoted: vote != null,
      votedOptionId: vote?.optionId,
      votedOptionText: votedText,
    );
  }

  String _codeFor(String id) {
    return id.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase().padRight(6, 'X').substring(0, 6);
  }
}
