import 'package:supabase_flutter/supabase_flutter.dart';

class ExamService {
  final SupabaseClient client;

  ExamService({SupabaseClient? client})
      : client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listExams({
    required String schoolId,
  }) async {
    final data = await client
        .from('exams')
        .select('id, exam_code, name, start_date, end_date, status')
        .eq('school_id', schoolId)
        .order('start_date', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> createExam({
    required String schoolId,
    required String name,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final data = await client
        .from('exams')
        .insert({
          'school_id': schoolId,
          'name': name.trim(),
          if (startDate != null) 'start_date': _dateOnly(startDate),
          if (endDate != null) 'end_date': _dateOnly(endDate),
        })
        .select()
        .single();

    return Map<String, dynamic>.from(data);
  }

  Future<List<Map<String, dynamic>>> listExamSubjects({
    required String examId,
  }) async {
    final data = await client
        .from('exam_subjects')
        .select(
          'id, subject_id, total_marks, pass_marks, subjects(id, name, code)',
        )
        .eq('exam_id', examId);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> listStudents({
    required String schoolId,
    required String classId,
  }) async {
    final data = await client
        .from('students')
        .select('id, admission_number, first_name, last_name, class_id, status')
        .eq('school_id', schoolId)
        .eq('class_id', classId)
        .order('first_name');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> listResults({
    required String examId,
    required String subjectId,
    String? studentId,
  }) async {
    var query = client
        .from('results')
        .select(
          'id, exam_id, exam_subject_id, student_id, marks, grade, remarks',
        )
        .eq('exam_id', examId)
        .eq('exam_subject_id', subjectId);

    if (studentId != null) {
      query = query.eq('student_id', studentId);
    }

    final data = await query.order('marks', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> saveResult({
    required String examId,
    required String examSubjectId,
    required String studentId,
    required num marks,
    String? grade,
    String? remarks,
  }) async {
    await client.from('results').upsert(
      {
        'exam_id': examId,
        'exam_subject_id': examSubjectId,
        'student_id': studentId,
        'marks': marks,
        if (grade != null && grade.trim().isNotEmpty) 'grade': grade.trim(),
        if (remarks != null && remarks.trim().isNotEmpty)
          'remarks': remarks.trim(),
      },
      onConflict: 'exam_id,exam_subject_id,student_id',
    );
  }

  String _dateOnly(DateTime date) {
    final d = date.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
