library proof_of_work_verification;

import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:convert/convert.dart';
import 'package:proof_of_work_verification/constants/numeric.dart';
import 'package:proof_of_work_verification/constants/string.dart';
import 'package:proof_of_work_verification/models/challenge_payload_model.dart';
import 'package:proof_of_work_verification/models/challenge_response_model.dart';

abstract class Challenge {
  Challenge({ required this.challengePayload });
  ChallengePayloadModel challengePayload;
  Future<ChallengeResponseModel> captcha();
}

class PoW extends Challenge {
  PoW({required super.challengePayload});

  /// Solve Proof of Work challenge and return Solution
  @override
  Future<ChallengeResponseModel> captcha() async {

    final payload = challengePayload;

    final Argon2id algorithm = Argon2id(
      memory: payload.algorithm.memoryCost,
      parallelism: payload.algorithm.parallelism,
      iterations: payload.algorithm.iterations,
      hashLength: payload.algorithm.hashLength,
    );

    final DateTime startTime = DateTime.now();
    int nounce = NumericConstants.min;
    int solution = 0;

    while(nounce < payload.range) {

      final Uint8List solutionBytes =
        utf8.encode('$nounce${StringConstants.modifier}');
      final Uint8List saltBytes = utf8.encode(payload.salt);

      final SecretKey newSecretKey = await algorithm.deriveKey(
        secretKey: SecretKey(solutionBytes),
        nonce: saltBytes,
      );

      final List<int> currentHashBytes = (await newSecretKey.extract()).bytes;
      final String currentHashString = hex.encode(currentHashBytes);

      if (currentHashString == payload.hash) {
        solution = nounce;
      }

      nounce += 1;
    }
    final DateTime endTime = DateTime.now();
    final int itTookToComplete =
        endTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch;

    return ChallengeResponseModel(
      id: payload.id,
      solution: solution,
      milliseconds: itTookToComplete,
    );

  }
}
