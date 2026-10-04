import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceService {
  final SupabaseClient client;

  AttendanceService({SupabaseClient? client})
      : client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listClasses({
    required String schoolId,
  }) async {
    final data = await client
        .from('classes')
        .select('id, name, section, grade_level')
        .eq('school_id', schoolId)
        .order('name');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> listStudents({
    required String schoolId,
    required String classId,
  }) async {
    final data = await client
        .from('students')
        .select(
          'id, admission_number, first_name, last_name, gender, class_id, status',
        )
        .eq('school_id', schoolId)
        .eq('class_id', classId)
        .order('first_name');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getAttendanceForDate({
    required String schoolId,
    required String classId,
    required DateTime date,
  }) async {
    final day = _dateOnly(date);

    final data = await client
        .from('attendance')
        .select(
          'id, student_id, attendance_date, status, remarks',
        )
        .eq('school_id', schoolId)
        .eq('class_id', classId)
        .eq('attendance_date', day);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> saveAttendance({
    required String schoolId,
    required String classId,
    required String studentId,
    required DateTime date,
    required String status,
    String? remarks,
  }) async {
    final day = _dateOnly(date);

    await client.from('attendance').upsert(
      {
        'school_id': schoolId,
        'class_id': classId,
        'student_id': studentId,
        'attendance_date': day,
        'status': status,
        if (remarks != null && remarks.trim().isNotEmpty)
          'remarks': remarks.trim(),
      },
      onConflict: 'student_id,attendance_date',
    );
  }

  Future<List<Map<String, dynamic>>> attendanceHistory({
    required String schoolId,
    required String studentId,
    DateTime? from,
    DateTime? to,
  }) async {
    var query = client
        .from('attendance')
        .select(
          'id, class_id, attendance_date, status, remarks',
        )
        .eq('school_id', schoolId)
        .eq('student_id', studentId);

    if (from != null) {
      query = query.gte('attendance_date', _dateOnly(from));
    }
    if (to != null) {
      query = query.lte('attendance_date', _dateOnly(to));
    }

    final data = await query.order('attendance_date', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  String _dateOnly(DateTime date) {
    final d = date.toLocal();
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$month-$day';
  }
}
