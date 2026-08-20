import 'package:Tobbo/domain/entities/poll.dart';
import 'package:Tobbo/domain/entities/poll_option.dart';
import 'package:Tobbo/domain/enums/poll_status.dart';

class AnonymousTokenResponse {
  const AnonymousTokenResponse({
    required this.accessToken,
    required this.expiresAt,
    this.userId,
    this.tokenHash,
  });

  final String accessToken;
  final DateTime expiresAt;
  final String? userId;
  final String? tokenHash;

  factory AnonymousTokenResponse.fromJson(Map<String, dynamic> json) {
    return AnonymousTokenResponse(
      accessToken: json['accessToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String).toUtc(),
      userId: json['userId'] as String?,
      tokenHash: json['tokenHash'] as String?,
    );
  }
}

class CreatePollResponse {
  const CreatePollResponse({
    required this.id,
    required this.publicCode,
    required this.shareUrl,
  });

  final String id;
  final String publicCode;
  final String shareUrl;

  factory CreatePollResponse.fromJson(Map<String, dynamic> json) {
    return CreatePollResponse(
      id: json['id'] as String,
      publicCode: json['publicCode'] as String,
      shareUrl: json['shareUrl'] as String,
    );
  }
}

class PollOptionResponse {
  const PollOptionResponse({required this.id, required this.text, this.voteCount = 0});

  final String id;
  final String text;
  final int voteCount;

  factory PollOptionResponse.fromJson(Map<String, dynamic> json) {
    return PollOptionResponse(
      id: json['id'] as String,
      text: json['text'] as String,
      voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
    );
  }

  PollOption toEntity({int sortOrder = 0}) => PollOption(
        id: id,
        text: text,
        sortOrder: sortOrder,
        voteCount: voteCount,
      );
}

class PollDetailResponse {
  const PollDetailResponse({
    required this.publicCode,
    required this.question,
    required this.options,
    required this.voteCount,
    required this.hasVoted,
    required this.status,
    this.distanceKm,
  });

  final String publicCode;
  final String question;
  final List<PollOptionResponse> options;
  final int voteCount;
  final double? distanceKm;
  final bool hasVoted;
  final PollStatus status;

  factory PollDetailResponse.fromJson(Map<String, dynamic> json) {
    final optionsJson = json['options'] as List<dynamic>? ?? const [];
    return PollDetailResponse(
      publicCode: json['publicCode'] as String,
      question: json['question'] as String,
      options: [
        for (final item in optionsJson) PollOptionResponse.fromJson(item as Map<String, dynamic>),
      ],
      voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      hasVoted: json['hasVoted'] as bool? ?? false,
      status: pollStatusFromApi(json['status'] as String?),
    );
  }

  Poll toEntity({
    Map<String, int>? voteCounts,
    String? votedOptionId,
    String? votedOptionText,
  }) {
    return Poll(
      id: publicCode,
      publicCode: publicCode,
      question: question,
      options: [
        for (var i = 0; i < options.length; i++)
          PollOption(
            id: options[i].id,
            text: options[i].text,
            sortOrder: i + 1,
            voteCount: voteCounts?[options[i].id] ?? options[i].voteCount,
          ),
      ],
      voteCount: voteCount,
      distanceKm: distanceKm,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      createdByUserId: '',
      status: status,
      hasVoted: hasVoted || votedOptionId != null,
      votedOptionId: votedOptionId,
      votedOptionText: votedOptionText,
    );
  }
}

class NearbyPollItemResponse {
  const NearbyPollItemResponse({
    required this.publicCode,
    required this.question,
    required this.voteCount,
    required this.distanceKm,
    required this.createdAt,
  });

  final String publicCode;
  final String question;
  final int voteCount;
  final double distanceKm;
  final DateTime createdAt;

  factory NearbyPollItemResponse.fromJson(Map<String, dynamic> json) {
    return NearbyPollItemResponse(
      publicCode: json['publicCode'] as String,
      question: json['question'] as String,
      voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    );
  }

  Poll toEntity() {
    return Poll(
      id: publicCode,
      publicCode: publicCode,
      question: question,
      options: const [],
      voteCount: voteCount,
      distanceKm: distanceKm,
      createdAt: createdAt,
      createdByUserId: '',
    );
  }
}

class PollResultOptionResponse {
  const PollResultOptionResponse({
    required this.id,
    required this.text,
    required this.voteCount,
    required this.percentage,
  });

  final String id;
  final String text;
  final int voteCount;
  final double percentage;

  factory PollResultOptionResponse.fromJson(Map<String, dynamic> json) {
    return PollResultOptionResponse(
      id: json['id'] as String,
      text: json['text'] as String,
      voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
    );
  }

  PollOption toEntity({int sortOrder = 0}) => PollOption(
        id: id,
        text: text,
        sortOrder: sortOrder,
        voteCount: voteCount,
      );
}

class PollResultsResponse {
  const PollResultsResponse({
    required this.question,
    required this.totalVotes,
    required this.options,
    this.myVoteOptionId,
  });

  final String question;
  final int totalVotes;
  final List<PollResultOptionResponse> options;
  final String? myVoteOptionId;

  factory PollResultsResponse.fromJson(Map<String, dynamic> json) {
    final optionsJson = json['options'] as List<dynamic>? ?? const [];
    return PollResultsResponse(
      question: json['question'] as String,
      totalVotes: (json['totalVotes'] as num?)?.toInt() ?? 0,
      options: [
        for (final item in optionsJson)
          PollResultOptionResponse.fromJson(item as Map<String, dynamic>),
      ],
      myVoteOptionId: json['myVoteOptionId'] as String?,
    );
  }

  Poll toEntity(String publicCode) {
    String? votedText;
    if (myVoteOptionId != null) {
      for (final option in options) {
        if (option.id == myVoteOptionId) {
          votedText = option.text;
          break;
        }
      }
    }
    return Poll(
      id: publicCode,
      publicCode: publicCode,
      question: question,
      options: [
        for (var i = 0; i < options.length; i++) options[i].toEntity(sortOrder: i + 1),
      ],
      voteCount: totalVotes,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      createdByUserId: '',
      hasVoted: myVoteOptionId != null,
      votedOptionId: myVoteOptionId,
      votedOptionText: votedText,
    );
  }
}

class MyPollItemResponse {
  const MyPollItemResponse({
    required this.publicCode,
    required this.question,
    required this.voteCount,
    required this.createdAt,
  });

  final String publicCode;
  final String question;
  final int voteCount;
  final DateTime createdAt;

  factory MyPollItemResponse.fromJson(Map<String, dynamic> json) {
    return MyPollItemResponse(
      publicCode: json['publicCode'] as String,
      question: json['question'] as String,
      voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    );
  }

  Poll toEntity() {
    return Poll(
      id: publicCode,
      publicCode: publicCode,
      question: question,
      options: const [],
      voteCount: voteCount,
      createdAt: createdAt,
      createdByUserId: '',
    );
  }
}

class MyVoteItemResponse {
  const MyVoteItemResponse({
    required this.publicCode,
    required this.question,
    required this.selectedOption,
    required this.createdAt,
  });

  final String publicCode;
  final String question;
  final String selectedOption;
  final DateTime createdAt;

  factory MyVoteItemResponse.fromJson(Map<String, dynamic> json) {
    return MyVoteItemResponse(
      publicCode: json['publicCode'] as String,
      question: json['question'] as String,
      selectedOption: json['selectedOption'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    );
  }

  Poll toEntity() {
    return Poll(
      id: publicCode,
      publicCode: publicCode,
      question: question,
      options: const [],
      createdAt: createdAt,
      createdByUserId: '',
      hasVoted: true,
      votedOptionText: selectedOption,
    );
  }
}

PollStatus pollStatusFromApi(String? value) {
  switch (value?.toLowerCase()) {
    case 'closed':
    case 'expired':
      return PollStatus.expired;
    default:
      return PollStatus.open;
  }
}
