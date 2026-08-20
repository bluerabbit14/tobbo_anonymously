import 'package:Tobbo/domain/enums/poll_status.dart';

class SamplePollRecord {
  SamplePollRecord({
    required this.id,
    required this.publicCode,
    required this.question,
    required this.options,
    required this.createdByUserId,
    required this.createdAt,
    this.distanceKm,
    this.expiresAt,
    this.status = PollStatus.open,
    this.shareWithNearby = true,
  });

  final String id;
  final String publicCode;
  final String question;
  final List<SampleOptionRecord> options;
  final String createdByUserId;
  final DateTime createdAt;
  final double? distanceKm;
  final DateTime? expiresAt;
  PollStatus status;
  bool shareWithNearby;

  int get voteCount => options.fold(0, (sum, o) => sum + o.voteCount);
}

class SampleOptionRecord {
  SampleOptionRecord({
    required this.id,
    required this.text,
    required this.sortOrder,
    required this.voteCount,
  });

  final String id;
  final String text;
  final int sortOrder;
  int voteCount;
}

class SampleVoteRecord {
  SampleVoteRecord({
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

class SamplePollDataSource {
  SamplePollDataSource() {
    reset();
  }

  static const currentUserId = 'local-anon';

  late List<SamplePollRecord> polls;
  late List<SampleVoteRecord> votes;

  void reset() {
    final now = DateTime.now().toUtc();
    polls = [
      SamplePollRecord(
        id: 'p1',
        publicCode: '8F3K92',
        question: 'Which phone should I buy?',
        createdByUserId: currentUserId,
        distanceKm: 2.1,
        createdAt: now.subtract(const Duration(hours: 6)),
        options: [
          SampleOptionRecord(id: 'p1-o1', text: 'iPhone', sortOrder: 1, voteCount: 52),
          SampleOptionRecord(id: 'p1-o2', text: 'Samsung', sortOrder: 2, voteCount: 20),
          SampleOptionRecord(id: 'p1-o3', text: 'Pixel', sortOrder: 3, voteCount: 12),
        ],
      ),
      SamplePollRecord(
        id: 'p2',
        publicCode: '4N2P8Q',
        question: 'Should I take this job offer?',
        createdByUserId: 'seed',
        distanceKm: 4.8,
        createdAt: now.subtract(const Duration(hours: 14)),
        options: [
          SampleOptionRecord(id: 'p2-o1', text: 'Yes', sortOrder: 1, voteCount: 18),
          SampleOptionRecord(id: 'p2-o2', text: 'No', sortOrder: 2, voteCount: 12),
          SampleOptionRecord(id: 'p2-o3', text: 'Not sure', sortOrder: 3, voteCount: 12),
        ],
      ),
      SamplePollRecord(
        id: 'p3',
        publicCode: '7H3M1R',
        question: 'Which outfit should I wear tonight?',
        createdByUserId: 'seed',
        distanceKm: 1.2,
        createdAt: now.subtract(const Duration(hours: 3)),
        options: [
          SampleOptionRecord(id: 'p3-o1', text: 'Black dress', sortOrder: 1, voteCount: 28),
          SampleOptionRecord(id: 'p3-o2', text: 'Linen shirt', sortOrder: 2, voteCount: 21),
        ],
      ),
      SamplePollRecord(
        id: 'p4',
        publicCode: 'B3ACH7',
        question: 'Beach or mountains for the weekend?',
        createdByUserId: 'seed',
        distanceKm: 6.4,
        createdAt: now.subtract(const Duration(hours: 20)),
        options: [
          SampleOptionRecord(id: 'p4-o1', text: 'Beach', sortOrder: 1, voteCount: 47),
          SampleOptionRecord(id: 'p4-o2', text: 'Mountains', sortOrder: 2, voteCount: 39),
        ],
      ),
      SamplePollRecord(
        id: 'p5',
        publicCode: 'L0G051',
        question: 'Which logo do you prefer?',
        createdByUserId: currentUserId,
        distanceKm: 3.3,
        createdAt: now.subtract(const Duration(days: 1)),
        options: [
          SampleOptionRecord(id: 'p5-o1', text: 'Wordmark', sortOrder: 1, voteCount: 30),
          SampleOptionRecord(id: 'p5-o2', text: 'Monogram', sortOrder: 2, voteCount: 21),
        ],
      ),
      SamplePollRecord(
        id: 'p6',
        publicCode: 'C10SED',
        question: 'Which cafe should I try?',
        createdByUserId: currentUserId,
        distanceKm: 0.9,
        createdAt: now.subtract(const Duration(days: 8)),
        expiresAt: now.subtract(const Duration(hours: 2)),
        status: PollStatus.expired,
        options: [
          SampleOptionRecord(id: 'p6-o1', text: 'Rue Noir', sortOrder: 1, voteCount: 14),
          SampleOptionRecord(id: 'p6-o2', text: 'Fika House', sortOrder: 2, voteCount: 12),
          SampleOptionRecord(id: 'p6-o3', text: 'Blue Hour', sortOrder: 3, voteCount: 10),
        ],
      ),
    ];
    votes = [
      SampleVoteRecord(
        pollId: 'p4',
        optionId: 'p4-o1',
        userId: currentUserId,
        votedAt: now.subtract(const Duration(hours: 2)),
      ),
    ];
  }

  SamplePollRecord? findByCode(String publicCode) {
    final code = publicCode.toUpperCase();
    for (final poll in polls) {
      if (poll.publicCode.toUpperCase() == code || poll.id.toLowerCase() == publicCode.toLowerCase()) {
        return poll;
      }
    }
    return null;
  }
}
