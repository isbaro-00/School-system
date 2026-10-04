import 'package:flutter/material.dart';
import 'report_service.dart';
import 'student_report_screen.dart';
import 'attendance_report_screen.dart';
import 'finance_report_screen.dart';
import 'results_report_screen.dart';

class ReportsDashboardScreen extends StatelessWidget {
  final String schoolId;

  const ReportsDashboardScreen({
    super.key,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context) {
    final reports = [
      (
        'Students Report',
        Icons.people_alt_outlined,
        () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentReportScreen(schoolId: schoolId),
              ),
            ),
      ),
      (
        'Attendance Report',
        Icons.fact_check_outlined,
        () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AttendanceReportScreen(schoolId: schoolId),
              ),
            ),
      ),
      (
        'Finance Report',
        Icons.payments_outlined,
        () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FinanceReportScreen(schoolId: schoolId),
              ),
            ),
      ),
      (
        'Results Report',
        Icons.school_outlined,
        () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResultsReportScreen(schoolId: schoolId),
              ),
            ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,
        ),
        itemBuilder: (_, index) {
          final item = reports[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: item.$3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.$2, size: 38),
                    const SizedBox(height: 12),
                    Text(
                      item.$1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
