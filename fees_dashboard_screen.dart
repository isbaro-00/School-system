import 'package:flutter/material.dart';
import 'fee_service.dart';
import 'fee_types_screen.dart';
import 'payments_screen.dart';

class FeesDashboardScreen extends StatelessWidget {
  final String schoolId;

  const FeesDashboardScreen({super.key, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fees & Payments')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Fee Types',
            subtitle: 'Create and manage school fee types',
            page: FeeTypesScreen(schoolId: schoolId),
          ),
          const SizedBox(height: 12),
          _card(
            context,
            icon: Icons.payments_outlined,
            title: 'Payments',
            subtitle: 'View recorded student payments',
            page: PaymentsScreen(schoolId: schoolId),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.receipt_long_outlined),
              title: Text('Student Fees'),
              subtitle: Text(
                'Student fee assignment and outstanding balances '
                'will be connected in the next integration step.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget page,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        ),
      ),
    );
  }
}
