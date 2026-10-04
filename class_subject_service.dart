import 'package:supabase_flutter/supabase_flutter.dart';

class ClassSubjectService {
  final SupabaseClient client;

  ClassSubjectService({SupabaseClient? client})
      : client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listClasses({
    required String schoolId,
  }) async {
    final data = await client
        .from('classes')
        .select('id, name, section, grade_level, academic_year_id, status')
        .eq('school_id', schoolId)
        .order('name');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> createClass({
    required String schoolId,
    required String name,
    String? section,
    String? gradeLevel,
    String? academicYearId,
  }) async {
    final data = await client
        .from('classes')
        .insert({
          'school_id': schoolId,
          'name': name.trim(),
          if (section != null && section.trim().isNotEmpty)
            'section': section.trim(),
          if (gradeLevel != null && gradeLevel.trim().isNotEmpty)
            'grade_level': gradeLevel.trim(),
          if (academicYearId != null && academicYearId.isNotEmpty)
            'academic_year_id': academicYearId,
        })
        .select()
        .single();

    return Map<String, dynamic>.from(data);
  }

  Future<List<Map<String, dynamic>>> listSubjects({
    required String schoolId,
  }) async {
    final data = await client
        .from('subjects')
        .select('id, name, code, description, status')
        .eq('school_id', schoolId)
        .order('name');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> createSubject({
    required String schoolId,
    required String name,
    String? code,
    String? description,
  }) async {
    final data = await client
        .from('subjects')
        .insert({
          'school_id': schoolId,
          'name': name.trim(),
          if (code != null && code.trim().isNotEmpty) 'code': code.trim(),
          if (description != null && description.trim().isNotEmpty)
            'description': description.trim(),
        })
        .select()
        .single();

    return Map<String, dynamic>.from(data);
  }

  Future<List<Map<String, dynamic>>> listClassSubjects({
    required String classId,
  }) async {
    final data = await client
        .from('class_subjects')
        .select('id, subject_id, teacher_id, subjects(id, name, code)')
        .eq('class_id', classId);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> assignSubjectToClass({
    required String classId,
    required String subjectId,
    String? teacherId,
  }) async {
    await client.from('class_subjects').insert({
      'class_id': classId,
      'subject_id': subjectId,
      if (teacherId != null && teacherId.isNotEmpty) 'teacher_id': teacherId,
    });
  }
}
