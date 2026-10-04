import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<Map<String, dynamic>> verifySchoolAndAccount({
    required String schoolAccessCode,
    required String accountType,
    required String identifier,
  }) async {
    final response = await client.functions.invoke(
      'verify-school-account',
      body: {
        'school_access_code': schoolAccessCode.trim(),
        'account_type': accountType,
        'identifier': identifier.trim(),
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('Invalid server response.');
  }
}
