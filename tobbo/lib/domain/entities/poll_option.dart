class PollOption {
  const PollOption({
    required this.id,
    required this.text,
    required this.sortOrder,
    this.voteCount = 0,
  });

  final String id;
  final String text;
  final int sortOrder;
  final int voteCount;

  double percentageOf(int total) {
    if (total <= 0) return 0;
    return (voteCount * 100 / total).roundToDouble();
  }
}
