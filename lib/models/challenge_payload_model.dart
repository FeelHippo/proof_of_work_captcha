import 'package:equatable/equatable.dart';

class ChallengePayloadModel extends Equatable {
  const ChallengePayloadModel({
    required this.uuidv4,
    required this.min,
    required this.max,
    required this.salt,
    required this.hash,
    required this.algorithm,
  });

  final String uuidv4;
  final int min;
  final int max;
  final String salt;
  final String hash;
  final Algorithm algorithm;

  @override
  List<Object?> get props => <Object?>[
    uuidv4,
    min,
    max,
    salt,
    hash,
    algorithm,
  ];
}

class Algorithm extends Equatable {
  const Algorithm({
    required this.type,
    required this.options,
  });

  final String type;
  final Options options;

  @override
  List<Object?> get props => <Object?>[
    type,
    options,
  ];
}

class Options extends Equatable {
  const Options({
    required this.memory,
    required this.parallelism,
    required this.iterations,
    required this.hashLength,
  });

  final int memory;
  final int parallelism;
  final int iterations;
  final int hashLength;

  @override
  List<Object?> get props => <Object?>[
    memory,
    parallelism,
    iterations,
    hashLength,
  ];
}