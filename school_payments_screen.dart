import 'package:flutter/material.dart';
import 'super_admin_service.dart';

class SchoolPaymentsScreen extends StatelessWidget {
  const SchoolPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SuperAdminService();

    return Scaffold(
      appBar: AppBar(title: const Text('School Payments')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.listSchoolPayments(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final rows = snapshot.data ?? [];

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, index) {
              final row = rows[index];
              return ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: Text(
                  '${row['payment_id'] ?? row['id'] ?? 'Payment'}',
                ),
                subtitle: Text(
                  'School: ${row['school_id'] ?? '-'}\n'
                  'Amount: ${row['amount'] ?? '-'}\n'
                  'Status: ${row['status'] ?? '-'}',
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
