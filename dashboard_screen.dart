import 'package:flutter/material.dart';
import '../../core/models/account_type.dart';

class DashboardScreen extends StatelessWidget {
  final AccountType accountType;
  final String displayName;

  const DashboardScreen({
    super.key,
    required this.accountType,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${accountType.label} Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Welcome, $displayName',
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Dashboard modules will be connected in the next phase.'),
          const SizedBox(height: 24),
          _card(Icons.people, 'Students', 'Manage student records'),
          _card(Icons.payments, 'Fees', 'View fees and payments'),
          _card(Icons.assignment, 'Exams & Results', 'Manage academic results'),
          _card(Icons.notifications, 'Notifications', 'School announcements'),
        ],
      ),
    );
  }

  Widget _card(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
