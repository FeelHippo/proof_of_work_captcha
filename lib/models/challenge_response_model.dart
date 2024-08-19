import 'package:equatable/equatable.dart';

class ChallengeResponseModel extends Equatable {
  const ChallengeResponseModel({
    required this.id,
    required this.solution,
    required this.milliseconds,
  });

  final String id;
  final int solution;
  final int milliseconds;

  @override
  List<Object?> get props => <Object?>[
    id,
    solution,
    milliseconds,
  ];
}