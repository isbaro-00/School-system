import 'package:flutter/material.dart';
import 'report_service.dart';

class ResultsReportScreen extends StatelessWidget {
  final String schoolId;

  const ResultsReportScreen({
    super.key,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context) {
    final service = ReportService();

    return Scaffold(
      appBar: AppBar(title: const Text('Results Report')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.resultsSummary(schoolId: schoolId),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final rows = snapshot.data ?? [];

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, index) {
              final row = rows[index];
              return ListTile(
                leading: const Icon(Icons.assessment_outlined),
                title: Text('Grade: ${row['grade'] ?? '-'}'),
                subtitle: Text(
                  'Student: ${row['student_id'] ?? '-'}\n'
                  'Marks: ${row['marks'] ?? '-'}',
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
