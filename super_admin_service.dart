import 'package:supabase_flutter/supabase_flutter.dart';

class SuperAdminService {
  final SupabaseClient client;

  SuperAdminService({SupabaseClient? client})
      : client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listSchools() async {
    final data = await client
        .from('schools')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> createSchool({
    required String name,
    required String adminName,
    required String email,
    required String phone,
    required String location,
    required String subscriptionPlan,
    required DateTime subscriptionStart,
    required DateTime subscriptionEnd,
  }) async {
    final result = await client.rpc('platform_create_school', params: {
      'p_name': name.trim(),
      'p_admin_name': adminName.trim(),
      'p_email': email.trim(),
      'p_phone': phone.trim(),
      'p_location': location.trim(),
      'p_subscription_plan': subscriptionPlan,
      'p_subscription_start': _dateOnly(subscriptionStart),
      'p_subscription_end': _dateOnly(subscriptionEnd),
    });

    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }
    throw Exception('Invalid server response.');
  }

  String _dateOnly(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  Future<Map<String, dynamic>> createSchoolWithAdmin({
    required String name,
    required String adminName,
    required String email,
    required String password,
    required String phone,
    required String location,
    required String subscriptionPlan,
    required DateTime subscriptionStart,
    required DateTime subscriptionEnd,
  }) async {
    final session = client.auth.currentSession;
    if (session == null) throw Exception('Super Admin login is required.');

    final response = await client.functions.invoke(
      'create-school-admin',
      body: {
        'name': name.trim(),
        'admin_name': adminName.trim(),
        'email': email.trim(),
        'password': password,
        'phone': phone.trim(),
        'location': location.trim(),
        'subscription_plan': subscriptionPlan,
        'subscription_start': _dateOnly(subscriptionStart),
        'subscription_end': _dateOnly(subscriptionEnd),
      },
    );

    final data = response.data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('Invalid server response.');
  }

  Future<void> setSchoolStatus({
    required String schoolId,
    required bool active,
  }) async {
    await client
        .from('schools')
        .update({'status': active ? 'active' : 'inactive'})
        .eq('id', schoolId);
  }

  Future<void> updateSchool({
    required String schoolId,
    required Map<String, dynamic> values,
  }) async {
    await client.from('schools').update(values).eq('id', schoolId);
  }

  Future<List<Map<String, dynamic>>> listSchoolPayments() async {
    final data = await client
        .from('school_payments')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> listSupportTickets() async {
    final data = await client
        .from('support_tickets')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }
}
