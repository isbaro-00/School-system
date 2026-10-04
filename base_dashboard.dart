
import 'package:flutter/material.dart';
import '../../core/models/app_user.dart';
import '../../core/services/session_service.dart';
import 'dashboard_card.dart';

class BaseDashboard extends StatelessWidget {
  final AppUser user;
  final String title;
  final String subtitle;
  final List<DashboardCard> cards;

  const BaseDashboard({
    super.key,
    required this.user,
    required this.title,
    required this.subtitle,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await SessionService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Welcome, ${user.displayName}',
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(subtitle),
          const SizedBox(height: 22),
          ...cards.map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: card,
              )),
        ],
      ),
    );
  }
}
