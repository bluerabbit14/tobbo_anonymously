import 'package:flutter/foundation.dart';
import 'package:Tobbo/core/error/api_exception.dart';
import 'package:Tobbo/data/services/api_service.dart';
import 'package:Tobbo/data/services/location_service.dart';
import 'package:Tobbo/domain/entities/poll.dart';
import 'package:Tobbo/domain/entities/poll_vote.dart';
import 'package:Tobbo/domain/enums/poll_status.dart';
import 'package:Tobbo/domain/repositories/poll_repository.dart';
import 'package:Tobbo/domain/repositories/session_repository.dart';

class PollRepositoryImpl extends ChangeNotifier implements PollRepository {
  PollRepositoryImpl({
    required ApiService api,
    required LocationService location,
    required SessionRepository sessions,
  })  : _api = api,
        _location = location,
        _sessions = sessions;

  final ApiService _api;
  final LocationService _location;
  final SessionRepository _sessions;

  Future<List<Poll>>? _nearbyFuture;
  double? _nearbyRadiusKm;

  void invalidateNearbyCache() {
    _nearbyFuture = null;
    _nearbyRadiusKm = null;
  }

  @override
  Future<Poll> createPoll({
    required String question,
    required List<String> options,
    required bool shareWithNearby,
  }) async {
    await _sessions.ensureSession();
    double? latitude;
    double? longitude;
    if (shareWithNearby) {
      final point = await _location.getCurrentPosition();
      if (point == null) {
        throw const ApiException(
          'Location is needed to share with people nearby.',
          code: 'ALLOW_NEARBY_REQUIRES_LOCATION',
        );
      }
      latitude = point.latitude;
      longitude = point.longitude;
    }

    final created = await _api.createPoll(
      question: question.trim(),
      options: options.map((option) => option.trim()).toList(),
      allowNearby: shareWithNearby,
      latitude: latitude,
      longitude: longitude,
    );
    notifyListeners();
    return Poll(
      id: created.id,
      publicCode: created.publicCode,
      question: question.trim(),
      options: const [],
      createdAt: DateTime.now().toUtc(),
      createdByUserId: '',
      shareWithNearby: shareWithNearby,
    );
  }

  @override
  Future<List<Poll>> getNearbyPolls({required double radiusKm}) {
    if (_nearbyFuture != null && _nearbyRadiusKm == radiusKm) {
      return _nearbyFuture!;
    }
    final future = _loadNearby(radiusKm: radiusKm);
    _nearbyFuture = future;
    _nearbyRadiusKm = radiusKm;
    future.then<void>(
      (_) {},
      onError: (_) {
        if (identical(_nearbyFuture, future)) {
          invalidateNearbyCache();
        }
      },
    );
    return future;
  }

  Future<List<Poll>> _loadNearby({required double radiusKm}) async {
    await _sessions.ensureSession();
    final point = await _location.getCurrentPosition();
    if (point == null) {
      if (_nearbyRadiusKm == radiusKm) {
        invalidateNearbyCache();
      }
      return const [];
    }
    final items = await _api.getNearbyPolls(
      latitude: point.latitude,
      longitude: point.longitude,
      radiusKm: radiusKm,
    );
    return [for (final item in items) item.toEntity()];
  }

  @override
  Future<Poll> getPoll(String publicCode) async {
    await _sessions.ensureSession();
    final point = await _location.getIfPermitted();
    final detail = await _api.getPoll(
      publicCode: publicCode,
      latitude: point?.latitude,
      longitude: point?.longitude,
    );
    if (!detail.hasVoted && detail.status != PollStatus.expired) {
      return detail.toEntity();
    }

    final results = await _api.getResults(publicCode);
    String? votedText;
    if (results.myVoteOptionId != null) {
      for (final option in results.options) {
        if (option.id == results.myVoteOptionId) {
          votedText = option.text;
          break;
        }
      }
    }
    return detail.toEntity(
      voteCounts: {
        for (final option in results.options) option.id: option.voteCount,
      },
      votedOptionId: results.myVoteOptionId,
      votedOptionText: votedText,
    );
  }

  @override
  Future<Poll> getResults(String publicCode) async {
    await _sessions.ensureSession();
    final results = await _api.getResults(publicCode);
    return results.toEntity(publicCode);
  }

  @override
  Future<PollVote> vote({
    required String publicCode,
    required String optionId,
  }) async {
    await _sessions.ensureSession();
    await _api.vote(publicCode: publicCode, optionId: optionId);
    notifyListeners();
    return PollVote(
      pollId: publicCode,
      optionId: optionId,
      userId: '',
      votedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<List<Poll>> getMyPolls() async {
    await _sessions.ensureSession();
    final items = await _api.getMyPolls();
    return [for (final item in items) item.toEntity()];
  }

  @override
  Future<List<Poll>> getMyVotes() async {
    await _sessions.ensureSession();
    final items = await _api.getMyVotes();
    return [for (final item in items) item.toEntity()];
  }

  @override
  Future<void> clearLocalData() async {
    invalidateNearbyCache();
    await _sessions.clearSession();
    notifyListeners();
  }
}
