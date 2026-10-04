import 'package:flutter/material.dart';
import 'exam_service.dart';
import 'add_exam_screen.dart';
import 'exam_profile_screen.dart';

class ExamsDashboardScreen extends StatefulWidget {
  final String schoolId;

  const ExamsDashboardScreen({super.key, required this.schoolId});

  @override
  State<ExamsDashboardScreen> createState() => _ExamsDashboardScreenState();
}

class _ExamsDashboardScreenState extends State<ExamsDashboardScreen> {
  final service = ExamService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = service.listExams(schoolId: widget.schoolId);
  }

  Future<void> _addExam() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddExamScreen(schoolId: widget.schoolId),
      ),
    );

    if (result == true) setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exams & Results')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExam,
        icon: const Icon(Icons.add),
        label: const Text('Create Exam'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final exams = snapshot.data ?? [];

          if (exams.isEmpty) {
            return const Center(child: Text('No exams found.'));
          }

          return RefreshIndicator(
            onRefresh: () async => setState(_reload),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: exams.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final exam = exams[index];

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.assignment_outlined),
                    ),
                    title: Text('${exam['name'] ?? 'Exam'}'),
                    subtitle: Text(
                      'Code: ${exam['exam_code'] ?? '-'}\n'
                      'Date: ${exam['start_date'] ?? '-'}'
                      '${exam['end_date'] != null ? ' → ${exam['end_date']}' : ''}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExamProfileScreen(
                            exam: exam,
                            schoolId: widget.schoolId,
                          ),
                        ),
                      );
                    },
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
