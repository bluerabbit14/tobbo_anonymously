import 'package:Tobbo/data/models/poll_option_model.dart';
import 'package:Tobbo/domain/entities/poll.dart';
import 'package:Tobbo/domain/enums/poll_status.dart';

class PollModel {
  const PollModel({
    required this.id,
    required this.publicCode,
    required this.question,
    required this.options,
    required this.createdAt,
    this.voteCount = 0,
    this.distanceKm,
    this.expiresAt,
    this.isExpired = false,
    this.createdByUserId = '',
    this.shareWithNearby = true,
    this.hasVoted = false,
    this.votedOptionId,
    this.votedOptionText,
  });

  final String id;
  final String publicCode;
  final String question;
  final List<PollOptionModel> options;
  final int voteCount;
  final double? distanceKm;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isExpired;
  final String createdByUserId;
  final bool shareWithNearby;
  final bool hasVoted;
  final String? votedOptionId;
  final String? votedOptionText;

  Poll toEntity() {
    return Poll(
      id: id,
      publicCode: publicCode,
      question: question,
      options: options.map((option) => option.toEntity()).toList(),
      voteCount: voteCount,
      distanceKm: distanceKm,
      createdAt: createdAt,
      expiresAt: expiresAt,
      status: isExpired ? PollStatus.expired : PollStatus.open,
      createdByUserId: createdByUserId,
      shareWithNearby: shareWithNearby,
      hasVoted: hasVoted,
      votedOptionId: votedOptionId,
      votedOptionText: votedOptionText,
    );
  }
}
