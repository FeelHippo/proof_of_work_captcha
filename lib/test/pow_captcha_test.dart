import 'package:flutter_test/flutter_test.dart';
import 'package:proof_of_work_verification/models/challenge_payload_model.dart';

import 'package:proof_of_work_verification/proof_of_work_verification.dart';

void main() {
  test('satisfies proof of concept', () async {
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
    final pow = PoW(challengePayload: challengePayload);
    final solution = await pow.captcha();
    expect(solution.solution, 42);
    expect(solution.id, '6c2cbad0-5626-485d-b9ed-08457a6da44a');
    expect(solution.id, isPositive);
  });
}
