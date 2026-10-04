import 'package:flutter/material.dart';
import 'notification_service.dart';

class MyNotificationsScreen extends StatefulWidget {
  final String userId;

  const MyNotificationsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<MyNotificationsScreen> createState() =>
      _MyNotificationsScreenState();
}

class _MyNotificationsScreenState extends State<MyNotificationsScreen> {
  final service = NotificationService();

  Future<void> _markRead(String id) async {
    await service.markAsRead(userNotificationId: id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Notifications')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.listMyNotifications(userId: widget.userId),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final rows = snapshot.data ?? [];
          if (rows.isEmpty) {
            return const Center(
              child: Text('You have no notifications.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final row = rows[index];
              final notification =
                  row['notifications'] as Map<String, dynamic>? ?? {};
              final isRead = row['is_read'] == true;

              return Card(
                child: ListTile(
                  leading: Icon(
                    isRead
                        ? Icons.notifications_none
                        : Icons.notifications_active,
                  ),
                  title: Text(
                    '${notification['title'] ?? ''}',
                    style: TextStyle(
                      fontWeight:
                          isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('${notification['message'] ?? ''}'),
                  trailing: isRead
                      ? null
                      : TextButton(
                          onPressed: () => _markRead(row['id'] as String),
                          child: const Text('Read'),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
