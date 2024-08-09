import 'dart:convert';
import 'package:cryptography/cryptography.dart';

const String SALT = 'YOtX2//7NoD/owm8RZ8llw=='; // shouldn't this be stored in app?
void main() async {

  // Represents hash string from MPS
  const String hash = 'asdb;auidbhpi3h29ubpisbcpiuwb2pckjbp2iwubcpiuscbpsbpcia';
  // Represents UTF-8 encoded hash
  List<int> hashBytes = utf8.encode(hash);

  // Represents UTF-8 encoded nonce
  List<int> saltBytes = utf8.encode(SALT);

  // Define algorithm -- should align with BE
  final Argon2id algorithm = Argon2id(
    memory: 10*1000, // 10 MB
    parallelism: 2, // Use maximum two CPU cores.
    iterations: 1, // For more security, you should usually raise memory parameter, not iterations.
    hashLength: 32,
  );

  // Calculate output of Argon2id algorithm
  final SecretKey newSecretKey = await algorithm.deriveKey(
    nonce: saltBytes,
    secretKey: SecretKey(hashBytes),
  );
  print('new Secret Key: $newSecretKey'); // SecretKeyData(...)

  // newSecretKey converted into bytes
  final SecretKeyData secretKeyData = await newSecretKey.extract();
  final computedChallenge = secretKeyData.bytes.toList();
  print('bytes: $computedChallenge');
  print('bytes: ${computedChallenge.runtimeType}');

  // stringify bytes to return validation value
  final decodedBytes = String.fromCharCodes(computedChallenge);
  print('decodedBytes: $decodedBytes'); // Ã(nÕ...

}

