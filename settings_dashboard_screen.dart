import 'package:flutter/material.dart';
import 'school_profile_settings_screen.dart';
import 'academic_settings_screen.dart';
import 'security_settings_screen.dart';
import 'settings_service.dart';

class SettingsDashboardScreen extends StatelessWidget {
  final String schoolId;

  const SettingsDashboardScreen({
    super.key,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'School Profile',
        Icons.business_outlined,
        () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SchoolProfileSettingsScreen(
                  schoolId: schoolId,
                ),
              ),
            ),
      ),
      (
        'Academic Settings',
        Icons.school_outlined,
        () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AcademicSettingsScreen(
                  schoolId: schoolId,
                ),
              ),
            ),
      ),
      (
        'Security',
        Icons.security_outlined,
        () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SecuritySettingsScreen(
                  schoolId: schoolId,
                ),
              ),
            ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final item = items[index];
          return Card(
            child: ListTile(
              leading: Icon(item.$2),
              title: Text(item.$1),
              trailing: const Icon(Icons.chevron_right),
              onTap: item.$3,
            ),
          );
        },
      ),
    );
  }
}
