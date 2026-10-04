import 'package:flutter/material.dart';
import '../../core/models/account_type.dart';
import 'school_access_screen.dart';

class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final types = [
      AccountType.schoolAdmin,
      AccountType.student,
      AccountType.parent,
      AccountType.teacher,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Choose account')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Who are you?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Choose your account type to continue.'),
          const SizedBox(height: 24),
          ...types.map(
            (type) => Card(
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                leading: CircleAvatar(
                  child: Icon(_icon(type)),
                ),
                title: Text(
                  type.label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(_description(type)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SchoolAccessScreen(accountType: type),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon(AccountType type) {
    switch (type) {
      case AccountType.schoolAdmin:
        return Icons.admin_panel_settings;
      case AccountType.student:
        return Icons.school;
      case AccountType.parent:
        return Icons.family_restroom;
      case AccountType.teacher:
        return Icons.person;
    }
  }

  String _description(AccountType type) {
    switch (type) {
      case AccountType.schoolAdmin:
        return 'School administrator and staff access';
      case AccountType.student:
        return 'Student portal';
      case AccountType.parent:
        return 'Parent portal';
      case AccountType.teacher:
        return 'Teacher portal';
    }
  }
}
