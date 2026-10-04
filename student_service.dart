
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> listStudents({
    required String schoolId,
  }) async {
    final rows = await client
        .from('students')
        .select('id, admission_number, first_name, last_name, gender, date_of_birth, class_id, status')
        .eq('school_id', schoolId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<Map<String, dynamic>?> getStudent(String id) async {
    final row = await client
        .from('students')
        .select()
        .eq('id', id)
        .maybeSingle();

    return row == null ? null : Map<String, dynamic>.from(row);
  }

  static Future<Map<String, dynamic>> createStudent({
    required String schoolId,
    required String firstName,
    required String lastName,
    required String gender,
    String? dateOfBirth,
    String? classId,
  }) async {
    final row = await client.from('students').insert({
      'school_id': schoolId,
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'gender': gender,
      if (dateOfBirth != null && dateOfBirth.isNotEmpty)
        'date_of_birth': dateOfBirth,
      if (classId != null && classId.isNotEmpty) 'class_id': classId,
    }).select().single();

    return Map<String, dynamic>.from(row);
  }

  static Future<void> updateStudent({
    required String id,
    required Map<String, dynamic> values,
  }) async {
    await client.from('students').update(values).eq('id', id);
  }
}
