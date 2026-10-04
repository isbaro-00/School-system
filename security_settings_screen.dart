import 'package:flutter/material.dart';

class SecuritySettingsScreen extends StatelessWidget {
  final String schoolId;

  const SecuritySettingsScreen({
    super.key,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('School Access Code'),
              subtitle: const Text(
                'Managed by the school/admin account and protected by backend rules.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('RLS Protection'),
              subtitle: const Text(
                'Database Row Level Security remains responsible for school data isolation.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.key_outlined),
              title: const Text('Password Security'),
              subtitle: const Text(
                'Supabase Auth should handle account passwords. Never store raw passwords in school tables.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
