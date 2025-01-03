import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:convert/convert.dart';
import 'package:proof_of_work_verification/constants/string.dart';
import 'package:proof_of_work_verification/models/challenge_payload_model.dart';

// Expect a payload such as
// {
//  "id": "6c2cbad0-5626-485d-b9ed-08457a6da44a",
//  "action": "whatever_you_put_in_request",
//  "prefix": "1234abcd",
//  "range": 100,
//  "algorithm": {
//    "name": "argon2id",
//    "memory_cost": 1024,
//    "hash_length": 16,
//    "parallelism": 1,
//    "iterations": 1
//  },
//  "hash": "8ea09bf4f6ac1e0b60d3b70e5692821b"
// }

const challengePayload = ChallengePayloadModel(
    id: "6c2cbad0-5626-485d-b9ed-08457a6da44a",
    action: "whatever_you_put_in_request",
    range: 100,
    salt: "1234abcd",
    hash: "8ea09bf4f6ac1e0b60d3b70e5692821b",
    algorithm: Algorithm(
        name: "argon2id",
        memoryCost: 1024,
        parallelism: 1,
        iterations: 1,
        hashLength: 16,
    ),
);

Future<void> main() async {

  // Define algorithm -- should align with BE
  final Argon2id algorithm = Argon2id(
    memory: challengePayload.algorithm.memoryCost,
    parallelism: challengePayload.algorithm.parallelism, // Use maximum two CPU cores.
    iterations: challengePayload.algorithm.iterations, // For more security, you should usually raise memory parameter, not iterations.
    hashLength: challengePayload.algorithm.hashLength,
  );

  final DateTime startTime = DateTime.now();
  // init PoW Captcha
  await Isolate.run<int>(({ int nounce = 0 }) async {
    // run max - min n of iterations
    while(nounce < challengePayload.range) {

      // Represents UTF-8 encoded nounce
      final Uint8List solutionBytes =
        utf8.encode('$nounce${StringConstants.modifier}');
      // Represents UTF-8 encoded salt
      final Uint8List saltBytes = utf8.encode(challengePayload.salt);

      // Calculate output of Argon2id algorithm
      final SecretKey newSecretKey = await algorithm.deriveKey(
        secretKey: SecretKey(solutionBytes),
        nonce: saltBytes, // this is provided by the server
      );

      // newSecretKey converted into bytes
      final List<int> currentHashBytes = (await newSecretKey.extract()).bytes;
      // convert into hex
      final String currentHashString = hex.encode(currentHashBytes);

      if (currentHashString == challengePayload.hash) {
        print('Success: return $nounce');
        break;
      }

      nounce += 1;
    }
    return nounce;
  });
  final DateTime endTime = DateTime.now();
  final took = endTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch;
  print('Took: $took milliseconds');

}

