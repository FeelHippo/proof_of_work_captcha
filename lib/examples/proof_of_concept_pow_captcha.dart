import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:convert/convert.dart';
import 'package:proof_of_work_verification/constants/string.dart';

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
Future<void> main() async {
  // The following will be returned by MPS
  const String id = '6c2cbad0-5626-485d-b9ed-08457a6da44a';
  const int range = 100;
  const String salt = '1234abcd';
  // hash == salt + random number => argon2id()
  const hash = '8ea09bf4f6ac1e0b60d3b70e5692821b';

  // Define algorithm -- should align with BE
  final Argon2id algorithm = Argon2id(
    memory: 1024,
    parallelism: 1, // Use maximum two CPU cores.
    iterations: 1, // For more security, you should usually raise memory parameter, not iterations.
    hashLength: 16,
  );

  final DateTime startTime = DateTime.now();
  // init PoW Captcha
  int nounce = 0;
  // run max - min n of iterations
  while(nounce < range) {

    // Represents UTF-8 encoded nounce
    final Uint8List solutionBytes =
      utf8.encode('$nounce${StringConstants.modifier}');
    // Represents UTF-8 encoded salt
    final Uint8List saltBytes = utf8.encode(salt);

    // Calculate output of Argon2id algorithm
    final SecretKey newSecretKey = await algorithm.deriveKey(
      secretKey: SecretKey(solutionBytes),
      nonce: saltBytes, // this is provided by the server
    );

    // newSecretKey converted into bytes
    final List<int> currentHashBytes = (await newSecretKey.extract()).bytes;
    // convert into hex
    final String currentHashString = hex.encode(currentHashBytes);

    if (currentHashString == hash) {
      print('Success: return $nounce');
      break;
    }

    nounce += 1;
  }
  final DateTime endTime = DateTime.now();
  final took = endTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch;
  print('Took: $took milliseconds');

}

