import 'package:flutter_test/flutter_test.dart';

import 'package:proof_of_work_verification/proof_of_work_verification.dart';

void main() {
  test('satisfies proof of concept', () {
    final pow = PoW();
    expect(pow.proofOfConcept(), true);
  });
}
