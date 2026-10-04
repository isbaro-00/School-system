import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';

class DashboardPlaceholder extends StatelessWidget {
  const DashboardPlaceholder({super.key});

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.welcome,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Welcome',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(email, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 24),
          const _DashboardCard(
            icon: Icons.people_alt_rounded,
            title: 'Students',
            value: '0',
          ),
          const SizedBox(height: 12),
          const _DashboardCard(
            icon: Icons.co_present_rounded,
            title: 'Teachers',
            value: '0',
          ),
          const SizedBox(height: 12),
          const _DashboardCard(
            icon: Icons.payments_rounded,
            title: 'Fees',
            value: '0',
          ),
          const SizedBox(height: 12),
          const _DashboardCard(
            icon: Icons.assignment_rounded,
            title: 'Exams',
            value: '0',
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.10),
          child: Icon(icon, color: AppTheme.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
