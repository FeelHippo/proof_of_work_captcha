import 'package:equatable/equatable.dart';

class ChallengePayloadModel extends Equatable {
  const ChallengePayloadModel({
    required this.id,
    required this.action, // from request
    required this.range,
    required this.salt, // aka prefix
    required this.hash,
    required this.algorithm,
  });

  final String id;
  final String action;
  final int range;
  final String salt;
  final String hash;
  final Algorithm algorithm;

  @override
  List<Object?> get props => <Object?>[
    id,
    range,
    salt,
    hash,
    algorithm,
  ];
}

class Algorithm extends Equatable {
  const Algorithm({
    required this.name,
    required this.memoryCost,
    required this.parallelism,
    required this.iterations,
    required this.hashLength,
  });

  final String name;
  final int memoryCost;
  final int parallelism;
  final int iterations;
  final int hashLength;

  @override
  List<Object?> get props => <Object?>[
    name,
    memoryCost,
    parallelism,
    iterations,
    hashLength,
  ];
}