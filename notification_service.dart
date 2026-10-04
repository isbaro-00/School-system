import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient client;

  NotificationService({SupabaseClient? client})
      : client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listNotifications({
    required String schoolId,
    String? userId,
  }) async {
    var query = client
        .from('notifications')
        .select('id, title, message, type, created_at, school_id')
        .eq('school_id', schoolId)
        .order('created_at', ascending: false);

    final data = await query;
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> listMyNotifications({
    required String userId,
  }) async {
    final data = await client
        .from('user_notifications')
        .select(
          'id, notification_id, is_read, read_at, notifications(id, title, message, type, created_at)',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> createNotification({
    required String schoolId,
    required String title,
    required String message,
    String type = 'announcement',
  }) async {
    final data = await client
        .from('notifications')
        .insert({
          'school_id': schoolId,
          'title': title.trim(),
          'message': message.trim(),
          'type': type,
        })
        .select()
        .single();

    return Map<String, dynamic>.from(data);
  }

  Future<void> markAsRead({
    required String userNotificationId,
  }) async {
    await client
        .from('user_notifications')
        .update({
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userNotificationId);
  }

  Future<void> deleteNotification(String id) async {
    await client.from('notifications').delete().eq('id', id);
  }
}
