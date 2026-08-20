import 'package:Tobbo/domain/entities/poll_option.dart';
import 'package:Tobbo/domain/enums/poll_status.dart';

class Poll {
  const Poll({
    required this.id,
    required this.publicCode,
    required this.question,
    required this.options,
    required this.createdAt,
    required this.createdByUserId,
    this.voteCount = 0,
    this.distanceKm,
    this.expiresAt,
    this.status = PollStatus.open,
    this.shareWithNearby = true,
    this.hasVoted = false,
    this.votedOptionId,
    this.votedOptionText,
  });

  final String id;
  final String publicCode;
  final String question;
  final List<PollOption> options;
  final int voteCount;
  final double? distanceKm;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final PollStatus status;
  final String createdByUserId;
  final bool shareWithNearby;
  final bool hasVoted;
  final String? votedOptionId;
  final String? votedOptionText;

  bool get isClosed => status == PollStatus.expired;
}
