import 'package:supabase_flutter/supabase_flutter.dart';

class ReportService {
  final SupabaseClient client;

  ReportService({SupabaseClient? client})
      : client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> studentSummary({
    required String schoolId,
  }) async {
    final data = await client
        .from('students')
        .select(
          'id, admission_number, first_name, last_name, gender, status, class_id',
        )
        .eq('school_id', schoolId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> attendanceSummary({
    required String schoolId,
    DateTime? from,
    DateTime? to,
  }) async {
    var query = client
        .from('attendance')
        .select(
          'student_id, attendance_date, status, class_id',
        )
        .eq('school_id', schoolId);

    if (from != null) {
      query = query.gte(
        'attendance_date',
        from.toIso8601String().split('T').first,
      );
    }

    if (to != null) {
      query = query.lte(
        'attendance_date',
        to.toIso8601String().split('T').first,
      );
    }

    final data = await query.order('attendance_date', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> paymentSummary({
    required String schoolId,
    DateTime? from,
    DateTime? to,
  }) async {
    var query = client
        .from('payments')
        .select(
          'id, payment_id, student_id, amount, payment_date, payment_method, status',
        )
        .eq('school_id', schoolId);

    if (from != null) {
      query = query.gte(
        'payment_date',
        from.toIso8601String().split('T').first,
      );
    }

    if (to != null) {
      query = query.lte(
        'payment_date',
        to.toIso8601String().split('T').first,
      );
    }

    final data = await query.order('payment_date', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> resultsSummary({
    required String schoolId,
  }) async {
    final data = await client
        .from('results')
        .select(
          'id, student_id, exam_id, exam_subject_id, marks, grade',
        )
        .eq('school_id', schoolId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
}
