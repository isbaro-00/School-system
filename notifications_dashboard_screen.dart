import 'package:flutter/material.dart';
import 'notification_service.dart';
import 'create_notification_screen.dart';

class NotificationsDashboardScreen extends StatefulWidget {
  final String schoolId;

  const NotificationsDashboardScreen({
    super.key,
    required this.schoolId,
  });

  @override
  State<NotificationsDashboardScreen> createState() =>
      _NotificationsDashboardScreenState();
}

class _NotificationsDashboardScreenState
    extends State<NotificationsDashboardScreen> {
  final service = NotificationService();

  String _typeLabel(String? type) {
    switch (type) {
      case 'fee':
        return 'Fee';
      case 'exam':
        return 'Exam';
      case 'attendance':
        return 'Attendance';
      case 'system':
        return 'System';
      default:
        return 'Announcement';
    }
  }

  Future<void> _refresh() async => setState(() {});

  Future<void> _create() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateNotificationScreen(
          schoolId: widget.schoolId,
        ),
      ),
    );
    if (created == true) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add_alert_outlined),
        label: const Text('Create'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.listNotifications(schoolId: widget.schoolId),
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
              child: Text('No notifications found.'),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final row = rows[index];

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.notifications_none),
                    ),
                    title: Text('${row['title'] ?? ''}'),
                    subtitle: Text(
                      '${_typeLabel(row['type']?.toString())}\n'
                      '${row['message'] ?? ''}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'delete') {
                          await service.deleteNotification(
                            row['id'] as String,
                          );
                          if (mounted) setState(() {});
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
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
