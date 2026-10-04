import 'package:flutter/material.dart';
import 'attendance_service.dart';

class StudentAttendanceScreen extends StatefulWidget {
  final String schoolId;
  final String studentId;
  final String studentName;

  const StudentAttendanceScreen({
    super.key,
    required this.schoolId,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  final service = AttendanceService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = service.attendanceHistory(
      schoolId: widget.schoolId,
      studentId: widget.studentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.studentName} Attendance')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final rows = snapshot.data ?? [];
          if (rows.isEmpty) {
            return const Center(child: Text('No attendance records found.'));
          }

          int present = 0;
          int absent = 0;
          int late = 0;
          int excused = 0;

          for (final row in rows) {
            switch (row['status']) {
              case 'present':
                present++;
                break;
              case 'absent':
                absent++;
                break;
              case 'late':
                late++;
                break;
              case 'excused':
                excused++;
                break;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 18,
                    runSpacing: 10,
                    children: [
                      Text('Present: $present'),
                      Text('Absent: $absent'),
                      Text('Late: $late'),
                      Text('Excused: $excused'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...rows.map(
                (row) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.event_note_outlined),
                    title: Text('${row['attendance_date'] ?? '-'}'),
                    subtitle: Text('${row['remarks'] ?? ''}'),
                    trailing: Text('${row['status'] ?? '-'}'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
