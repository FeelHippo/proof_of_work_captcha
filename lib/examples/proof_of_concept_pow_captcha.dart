import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:cryptography/cryptography.dart';
import 'package:collection/collection.dart';

NumberFormat formatter = NumberFormat('000000');
Function equals = const ListEquality().equals;

// Expect a payload such as
// {
//   min:0,
//   max: 200000,
//   prefix: 'randomabc',
//   hash: 'fPn4sPgkFAuBJo3M3UzcGss3dJysxLJdPdvojRF20ZE=',
// }
Future<void> main() async {
  // The following will be returned by MPS
  const String id = 'challenge1';
  const int min = 0;
  const int max = 1000;
  const List<int> salt = [
    166, 107, 123,  44,  47,
    165,  41,  57, 220, 167,
    153,  27, 131, 234,  91,
    60
  ];
  // hash == salt + random number => argon2id()
  const hash = [
    225, 125, 161, 128, 236, 227,  23,   9,
    223, 175, 182, 252, 217,  19, 175, 122,
    55,  24,  96,  82, 202,  65, 229,  36,
    180, 212, 252, 145, 176,  34, 101, 160
  ];

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
    print('current Nounce: $paddedNounce');
    // Represents UTF-8 encoded nounce
    final Uint8List challengeBytes = utf8.encode(paddedNounce);

    // Calculate output of Argon2id algorithm
    final SecretKey newSecretKey = await algorithm.deriveKey(
      secretKey: SecretKey(challengeBytes),
      nonce: salt, // this is provided by the server
    );
    print('new Secret Key: $newSecretKey'); // SecretKeyData(...)

    // newSecretKey converted into bytes
    final List<int> secretKeyData = await newSecretKey.extractBytes();
    print('secretKeyData: $secretKeyData');
    print('hashBytes: $hash');

    if (equals(secretKeyData, hash)) {
      print('Success: return $nounce');
      break;
    }

    nounce += 1;
  }
  final DateTime endTime = DateTime.now();
  final took = endTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch;
  print('Took: $took milliseconds');

}

