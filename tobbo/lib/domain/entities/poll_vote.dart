class PollVote {
  const PollVote({
    required this.pollId,
    required this.optionId,
    required this.userId,
    required this.votedAt,
  });

  final String pollId;
  final String optionId;
  final String userId;
  final DateTime votedAt;
}
