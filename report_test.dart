import 'package:flutter_test/flutter_test.dart';

double totalAmounts(List<Map<String, dynamic>> rows) {
  return rows.fold<double>(
    0,
    (sum, row) => sum + (double.tryParse('${row['amount'] ?? 0}') ?? 0),
  );
}

void main() {
  test('payment report total calculates correctly', () {
    final rows = [
      {'amount': 10},
      {'amount': 25.5},
      {'amount': '14.5'},
    ];

    expect(totalAmounts(rows), 50);
  });
}
