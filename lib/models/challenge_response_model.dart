import 'package:equatable/equatable.dart';

class ChallengeResponseModel extends Equatable {
  const ChallengeResponseModel({
    required this.uuidv4,
    required this.solution,
    required this.milliseconds,
  });

  final String uuidv4;
  final String solution;
  final int milliseconds;

  @override
  List<Object?> get props => <Object?>[
    uuidv4,
    solution,
    milliseconds,
  ];
}