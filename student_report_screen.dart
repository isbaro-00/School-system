import 'package:flutter/material.dart';
import 'report_service.dart';

class StudentReportScreen extends StatelessWidget {
  final String schoolId;

  const StudentReportScreen({
    super.key,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context) {
    final service = ReportService();

    return Scaffold(
      appBar: AppBar(title: const Text('Students Report')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.studentSummary(schoolId: schoolId),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final rows = snapshot.data ?? [];
          final active = rows.where((r) => r['status'] == 'active').length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(child: _StatCard(label: 'Total', value: '${rows.length}')),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(label: 'Active', value: '$active')),
                ],
              ),
              const SizedBox(height: 18),
              ...rows.map(
                (row) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text(
                      '${row['first_name'] ?? ''} ${row['last_name'] ?? ''}',
                    ),
                    subtitle: Text(
                      'Admission: ${row['admission_number'] ?? '-'}\n'
                      'Status: ${row['status'] ?? '-'}',
                    ),
                    isThreeLine: true,
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}
