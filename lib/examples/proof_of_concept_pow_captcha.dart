import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:cryptography/cryptography.dart';
import 'package:convert/convert.dart';

NumberFormat formatter = NumberFormat('000000');

// Expect a payload such as
// {
//    id: uuidv4
//    min: int, (always 0 i guess)
//    max: int,
//    prefix: str, (aka salt)
//    challenge: str (aka hex-coded hash)
//    algorithm: {
//      type: 'argon2id',
//      options: {
//        memory: int,
//        parallelism: int,
//        iterations: int,
//        hashLength: int
//      }
//    }
// }
Future<void> main() async {
  // The following will be returned by MPS
  const String id = 'challenge1';
  const int min = 0;
  const int max = 1000;
  const String salt = 'xgJFAXupU5ksJBrQevW9Tw==';
  // hash == salt + random number => argon2id()
  const hash =
      '2f4e60914b44ff085e6f879b3ed8c8762e0b8b6c658e8501bbb974fe5dd56a9f';

  // Define algorithm -- should align with BE
  final Argon2id algorithm = Argon2id(
    memory: 10*1000, // 10 MB
    parallelism: 1, // Use maximum two CPU cores.
    iterations: 1, // For more security, you should usually raise memory parameter, not iterations.
    hashLength: 32,
  );

  final DateTime startTime = DateTime.now();
  // init PoW Captcha
  int nounce = min;
  // run max - min n of iterations
  while(nounce < max) {

    // format nounce to add padding zeroes
    final paddedNounce = formatter.format(nounce);
    // Represents UTF-8 encoded nounce
    final Uint8List solutionBytes = utf8.encode(paddedNounce);
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
      print('Success: return $paddedNounce');
      break;
    }

    nounce += 1;
  }
  final DateTime endTime = DateTime.now();
  final took = endTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch;
  print('Took: $took milliseconds');

}

