library proof_of_work_verification;

import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:convert/convert.dart';
import 'package:proof_of_work_verification/constants/numeric.dart';
import 'package:proof_of_work_verification/constants/string.dart';
import 'package:proof_of_work_verification/models/challenge_payload_model.dart';
import 'package:proof_of_work_verification/models/challenge_response_model.dart';

class PoW {
  /// Solve Challenge and return Solution
  Future<ChallengeResponseModel> captcha(
      ChallengePayloadModel challengePayload,
  ) async {

    final Argon2id algorithm = Argon2id(
      memory: challengePayload.algorithm.memoryCost,
      parallelism: challengePayload.algorithm.parallelism,
      iterations: challengePayload.algorithm.iterations,
      hashLength: challengePayload.algorithm.hashLength,
    );

    final DateTime startTime = DateTime.now();
    int nounce = NumericConstants.min;
    var solution;

    while(nounce < challengePayload.range) {

      final Uint8List solutionBytes =
        utf8.encode('$nounce${StringConstants.modifier}');
      final Uint8List saltBytes = utf8.encode(challengePayload.salt);

      final SecretKey newSecretKey = await algorithm.deriveKey(
        secretKey: SecretKey(solutionBytes),
        nonce: saltBytes,
      );

      final List<int> currentHashBytes = (await newSecretKey.extract()).bytes;
      final String currentHashString = hex.encode(currentHashBytes);

      if (currentHashString == challengePayload.hash) {
        solution = nounce;
      }

      nounce += 1;
    }
    final DateTime endTime = DateTime.now();
    final itTookToComplete =
        endTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch;

    return ChallengeResponseModel(
      uuidv4: challengePayload.id,
      solution: solution,
      milliseconds: itTookToComplete,
    );

  }
}
