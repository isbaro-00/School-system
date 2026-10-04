import 'package:supabase_flutter/supabase_flutter.dart';

class ParentService {
  final SupabaseClient client;

  ParentService({SupabaseClient? client})
      : client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listParents({
    required String schoolId,
  }) async {
    final data = await client
        .from('parents')
        .select('id, parent_code, first_name, last_name, phone, email, status')
        .eq('school_id', schoolId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> createParent({
    required String schoolId,
    required String firstName,
    required String lastName,
    String? phone,
    String? email,
  }) async {
    final data = await client
        .from('parents')
        .insert({
          'school_id': schoolId,
          'first_name': firstName,
          'last_name': lastName,
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        })
        .select('id, parent_code, first_name, last_name, phone, email, status')
        .single();

    return Map<String, dynamic>.from(data);
  }

  Future<List<Map<String, dynamic>>> listChildren({
    required String parentId,
  }) async {
    final links = await client
        .from('student_parents')
        .select('student_id')
        .eq('parent_id', parentId);

    final ids = (links as List)
        .map((row) => row['student_id'] as String)
        .toList();

    if (ids.isEmpty) return [];

    final students = await client
        .from('students')
        .select(
          'id, admission_number, first_name, last_name, gender, date_of_birth, status, class_id',
        )
        .inFilter('id', ids)
        .order('first_name');

    return List<Map<String, dynamic>>.from(students);
  }

  Future<void> linkChild({
    required String parentId,
    required String studentId,
  }) async {
    await client.from('student_parents').insert({
      'parent_id': parentId,
      'student_id': studentId,
    });
  }
}
