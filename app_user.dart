
class AppUser {
  final String id;
  final String schoolId;
  final String role;
  final String displayName;
  final String? authUserId;

  const AppUser({
    required this.id,
    required this.schoolId,
    required this.role,
    required this.displayName,
    this.authUserId,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'].toString(),
      schoolId: map['school_id'].toString(),
      role: (map['role'] ?? '').toString(),
      displayName: (map['name'] ?? map['full_name'] ?? 'User').toString(),
      authUserId: map['auth_user_id']?.toString(),
    );
  }
}
