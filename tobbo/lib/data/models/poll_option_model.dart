import 'package:Tobbo/domain/entities/poll_option.dart';

class PollOptionModel {
  const PollOptionModel({
    required this.id,
    required this.text,
    required this.sortOrder,
    this.voteCount = 0,
  });

  final String id;
  final String text;
  final int sortOrder;
  final int voteCount;

  PollOption toEntity() => PollOption(
        id: id,
        text: text,
        sortOrder: sortOrder,
        voteCount: voteCount,
      );

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    return PollOptionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'sortOrder': sortOrder,
      };
}
