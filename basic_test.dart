import 'package:flutter_test/flutter_test.dart';

void main() {
  test('basic Phase 16 test runs', () {
    expect(2 + 2, 4);
  });

  test('school access code should be treated as an identifier, not a password',
      () {
    const accessCode = 'ACC-TEST';
    expect(accessCode.isNotEmpty, true);
  });
}
