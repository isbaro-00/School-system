import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsService {
  final SupabaseClient client;

  SettingsService({SupabaseClient? client})
      : client = client ?? Supabase.instance.client;

  Future<Map<String, dynamic>?> getSchoolSettings({
    required String schoolId,
  }) async {
    final data = await client
        .from('school_settings')
        .select()
        .eq('school_id', schoolId)
        .maybeSingle();

    return data == null ? null : Map<String, dynamic>.from(data);
  }

  Future<void> saveSchoolSettings({
    required String schoolId,
    required Map<String, dynamic> values,
  }) async {
    await client.from('school_settings').upsert({
      'school_id': schoolId,
      ...values,
    });
  }

  Future<Map<String, dynamic>?> getSchool({
    required String schoolId,
  }) async {
    final data = await client
        .from('schools')
        .select()
        .eq('id', schoolId)
        .maybeSingle();

    return data == null ? null : Map<String, dynamic>.from(data);
  }
}
