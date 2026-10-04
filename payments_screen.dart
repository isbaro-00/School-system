import 'package:flutter/material.dart';
import 'fee_service.dart';

class PaymentsScreen extends StatefulWidget {
  final String schoolId;
  final String? studentId;

  const PaymentsScreen({
    super.key,
    required this.schoolId,
    this.studentId,
  });

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final service = FeeService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = service.listPayments(
      schoolId: widget.schoolId,
      studentId: widget.studentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final payments = snapshot.data ?? [];
          if (payments.isEmpty) {
            return const Center(child: Text('No payments found.'));
          }

          return RefreshIndicator(
            onRefresh: () async => setState(_reload),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final item = payments[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.receipt_long_outlined),
                    ),
                    title: Text(
                      '${item['payment_id'] ?? item['id'] ?? 'Payment'}',
                    ),
                    subtitle: Text(
                      'Student: ${item['student_id'] ?? '-'}\n'
                      'Method: ${item['payment_method'] ?? '-'}\n'
                      'Date: ${item['payment_date'] ?? '-'}',
                    ),
                    isThreeLine: true,
                    trailing: Text('${item['amount'] ?? '-'}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
