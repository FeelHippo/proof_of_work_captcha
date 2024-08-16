library proof_of_work_verification;

import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:convert/convert.dart';
import 'package:intl/intl.dart';
import 'package:proof_of_work_verification/models/challenge_payload_model.dart';
import 'package:proof_of_work_verification/models/challenge_response_model.dart';

class PoW {
  /// Solve Challenge and return Solution
  Future<ChallengeResponseModel> captcha(
      ChallengePayloadModel challengePayload,
  ) async {

    final Argon2id algorithm = Argon2id(
      memory: challengePayload.algorithm.options.memory,
      parallelism: challengePayload.algorithm.options.parallelism,
      iterations: challengePayload.algorithm.options.iterations,
      hashLength: challengePayload.algorithm.options.hashLength,
    );

    final DateTime startTime = DateTime.now();
    int nounce = challengePayload.min;
    var solution;

    while(nounce < challengePayload.max) {

      final paddedNounce = NumberFormat('000000').format(nounce);
      final Uint8List solutionBytes = utf8.encode(paddedNounce);
      final Uint8List saltBytes = utf8.encode(challengePayload.salt);

      final SecretKey newSecretKey = await algorithm.deriveKey(
        secretKey: SecretKey(solutionBytes),
        nonce: saltBytes,
      );

      final List<int> currentHashBytes = (await newSecretKey.extract()).bytes;
      final String currentHashString = hex.encode(currentHashBytes);

      if (currentHashString == challengePayload.hash) {
        solution = paddedNounce;
      }

      nounce += 1;
    }
    final DateTime endTime = DateTime.now();
    final itTookToComplete = endTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch;

    return ChallengeResponseModel(
      uuidv4: challengePayload.uuidv4,
      solution: solution,
      milliseconds: itTookToComplete,
    );

  }
}
