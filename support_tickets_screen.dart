import 'package:flutter/material.dart';
import 'super_admin_service.dart';

class SupportTicketsScreen extends StatelessWidget {
  const SupportTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SuperAdminService();

    return Scaffold(
      appBar: AppBar(title: const Text('Support Tickets')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.listSupportTickets(),
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
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final row = rows[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.support_agent_outlined),
                  title: Text('${row['subject'] ?? 'Support ticket'}'),
                  subtitle: Text(
                    'Status: ${row['status'] ?? '-'}\n'
                    '${row['message'] ?? row['description'] ?? ''}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
