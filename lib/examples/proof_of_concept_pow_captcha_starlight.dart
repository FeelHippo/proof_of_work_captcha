import 'dart:convert';
import 'dart:typed_data';
import 'package:argon2/argon2.dart';
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
  var parameters = Argon2Parameters(
    Argon2Parameters.ARGON2_id,
    challengePayload.salt.toBytesLatin1(),
    iterations: challengePayload.algorithm.iterations,
    memory: challengePayload.algorithm.memoryCost,
  );
  print('~~~ parameters $parameters');

  var argon2 = Argon2BytesGenerator();
  argon2.init(parameters);

  final DateTime startTime = DateTime.now();
  // init PoW Captcha
  int nounce = 0;
  // run max - min n of iterations
  while(nounce < challengePayload.range) {

    // Represents UTF-8 encoded nounce
    final Uint8List solutionBytes =
      parameters.converter.convert('$nounce${StringConstants.modifier}');

    // Calculate output of Argon2id algorithm
    var result = Uint8List(challengePayload.algorithm.hashLength);
    argon2.generateBytes(solutionBytes, result, 0, result.length);

    var resultHex = hex.encode(result);

    print('~~~ $resultHex');

    if (resultHex == challengePayload.hash) {
      print('Success: return $nounce');
      break;
    }

    nounce += 1;
  }

  final DateTime endTime = DateTime.now();
  final took = endTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch;
  print('Took: $took milliseconds');

}

