import 'package:supabase_flutter/supabase_flutter.dart';

class TimetableService {
  final SupabaseClient client;

  TimetableService({SupabaseClient? client})
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

  Future<List<Map<String, dynamic>>> listTimetable({
    required String schoolId,
    String? classId,
  }) async {
    var query = client
        .from('timetable')
        .select(
          'id, class_id, subject_id, teacher_id, day_of_week, start_time, end_time, room, subjects(name, code)',
        )
        .eq('school_id', schoolId);

    if (classId != null && classId.isNotEmpty) {
      query = query.eq('class_id', classId);
    }

    final data = await query.order('day_of_week').order('start_time');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> createTimetableEntry({
    required String schoolId,
    required String classId,
    required String subjectId,
    String? teacherId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    String? room,
  }) async {
    final data = await client
        .from('timetable')
        .insert({
          'school_id': schoolId,
          'class_id': classId,
          'subject_id': subjectId,
          if (teacherId != null && teacherId.isNotEmpty)
            'teacher_id': teacherId,
          'day_of_week': dayOfWeek,
          'start_time': startTime,
          'end_time': endTime,
          if (room != null && room.trim().isNotEmpty) 'room': room.trim(),
        })
        .select()
        .single();

    return Map<String, dynamic>.from(data);
  }

  Future<void> deleteEntry(String id) async {
    await client.from('timetable').delete().eq('id', id);
  }
}
