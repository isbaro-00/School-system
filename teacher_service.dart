
import 'package:supabase_flutter/supabase_flutter.dart';

class TeacherService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> listTeachers({
    required String schoolId,
  }) async {
    final rows = await client
        .from('teachers')
        .select('id, teacher_code, first_name, last_name, phone, email, status')
        .eq('school_id', schoolId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<Map<String, dynamic>?> getTeacher(String id) async {
    final row = await client
        .from('teachers')
        .select()
        .eq('id', id)
        .maybeSingle();

    return row == null ? null : Map<String, dynamic>.from(row);
  }

  static Future<Map<String, dynamic>> createTeacher({
    required String schoolId,
    required String firstName,
    required String lastName,
    String? phone,
    String? email,
  }) async {
    final row = await client.from('teachers').insert({
      'school_id': schoolId,
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
    }).select().single();

    return Map<String, dynamic>.from(row);
  }

  static Future<void> updateTeacher({
    required String id,
    required Map<String, dynamic> values,
  }) async {
    await client.from('teachers').update(values).eq('id', id);
  }
}
