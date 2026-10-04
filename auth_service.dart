
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  static SupabaseClient get client => SupabaseService.client;

  static Future<Map<String, dynamic>> resolveAccount({
    required String schoolAccessCode,
    required String accountType,
    required String identifier,
  }) async {
    final response = await client.functions.invoke(
      'resolve-account',
      body: {
        'school_access_code': schoolAccessCode.trim(),
        'account_type': accountType,
        'identifier': identifier.trim(),
      },
    );

    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }

    throw Exception('Invalid server response.');
  }

  static Future<Map<String, dynamic>> setupAccount({
    required String schoolAccessCode,
    required String accountType,
    required String identifier,
    required String password,
  }) async {
    final response = await client.functions.invoke(
      'setup-account',
      body: {
        'school_access_code': schoolAccessCode.trim(),
        'account_type': accountType,
        'identifier': identifier.trim(),
        'password': password,
      },
    );

    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }

    throw Exception('Invalid server response.');
  }

  static Future<AuthResponse> signIn({
    required String authLoginEmail,
    required String password,
  }) {
    return client.auth.signInWithPassword(
      email: authLoginEmail,
      password: password,
    );
  }

  static Future<void> signOut() => client.auth.signOut();
}
