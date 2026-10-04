import 'package:flutter/material.dart';
import 'attendance_service.dart';
import 'take_attendance_screen.dart';

class AttendanceDashboardScreen extends StatefulWidget {
  final String schoolId;

  const AttendanceDashboardScreen({
    super.key,
    required this.schoolId,
  });

  @override
  State<AttendanceDashboardScreen> createState() =>
      _AttendanceDashboardScreenState();
}

class _AttendanceDashboardScreenState
    extends State<AttendanceDashboardScreen> {
  final service = AttendanceService();
  late Future<List<Map<String, dynamic>>> _classes;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _classes = service.listClasses(schoolId: widget.schoolId);
  }

  Future<void> _openClass(Map<String, dynamic> classData) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TakeAttendanceScreen(
          schoolId: widget.schoolId,
          classData: classData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _classes,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final classes = snapshot.data ?? [];
          if (classes.isEmpty) {
            return const Center(child: Text('No classes found.'));
          }

          return RefreshIndicator(
            onRefresh: () async => setState(_reload),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: classes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final item = classes[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.fact_check_outlined),
                    ),
                    title: Text('${item['name'] ?? 'Class'}'),
                    subtitle: Text(
                      'Section: ${item['section'] ?? '-'}\n'
                      'Grade: ${item['grade_level'] ?? '-'}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openClass(item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
