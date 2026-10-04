import 'package:flutter/material.dart';
import 'timetable_service.dart';

class StudentTimetableScreen extends StatelessWidget {
  final String schoolId;
  final String classId;

  const StudentTimetableScreen({
    super.key,
    required this.schoolId,
    required this.classId,
  });

  String _dayName(dynamic value) {
    final day = value is int ? value : int.tryParse('$value') ?? 0;
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return day >= 0 && day < days.length ? days[day] : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final service = TimetableService();

    return Scaffold(
      appBar: AppBar(title: const Text('My Timetable')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.listTimetable(
          schoolId: schoolId,
          classId: classId,
        ),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final rows = snapshot.data ?? [];
          if (rows.isEmpty) {
            return const Center(child: Text('No timetable found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final row = rows[index];
              final subject =
                  row['subjects'] as Map<String, dynamic>? ?? {};

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text('${subject['name'] ?? 'Subject'}'),
                  subtitle: Text(
                    '${_dayName(row['day_of_week'])}\n'
                    '${row['start_time'] ?? '-'} - ${row['end_time'] ?? '-'}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
