
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

class SessionService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<AppUser?> currentAppUser() async {
    final authUser = client.auth.currentUser;
    if (authUser == null) return null;

    final row = await client
        .from('users')
        .select('id, school_id, role, name, full_name, auth_user_id')
        .eq('auth_user_id', authUser.id)
        .maybeSingle();

    if (row == null) return null;
    return AppUser.fromMap(Map<String, dynamic>.from(row));
  }

  static Future<void> signOut() => client.auth.signOut();
}
