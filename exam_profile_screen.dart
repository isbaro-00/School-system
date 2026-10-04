import 'package:flutter/material.dart';
import 'exam_service.dart';
import 'enter_marks_screen.dart';

class ExamProfileScreen extends StatefulWidget {
  final Map<String, dynamic> exam;
  final String schoolId;

  const ExamProfileScreen({
    super.key,
    required this.exam,
    required this.schoolId,
  });

  @override
  State<ExamProfileScreen> createState() => _ExamProfileScreenState();
}

class _ExamProfileScreenState extends State<ExamProfileScreen> {
  final service = ExamService();
  late Future<List<Map<String, dynamic>>> _subjects;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _subjects = service.listExamSubjects(
      examId: widget.exam['id'] as String,
    );
  }

  @override
  Widget build(BuildContext context) {
    final exam = widget.exam;

    return Scaffold(
      appBar: AppBar(title: Text('${exam['name'] ?? 'Exam'}')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _subjects,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final subjects = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('Exam Code'),
                      subtitle: Text('${exam['exam_code'] ?? '-'}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Start'),
                      subtitle: Text('${exam['start_date'] ?? '-'}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.event),
                      title: const Text('End'),
                      subtitle: Text('${exam['end_date'] ?? '-'}'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Exam Subjects',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              if (subjects.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No subjects assigned to this exam yet.'),
                  ),
                )
              else
                ...subjects.map((row) {
                  final subject =
                      row['subjects'] as Map<String, dynamic>? ?? {};

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.menu_book_outlined),
                      title: Text('${subject['name'] ?? 'Subject'}'),
                      subtitle: Text(
                        'Total: ${row['total_marks'] ?? '-'} | '
                        'Pass: ${row['pass_marks'] ?? '-'}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EnterMarksScreen(
                              schoolId: widget.schoolId,
                              examId: exam['id'] as String,
                              examSubjectId: row['id'] as String,
                              subjectName: '${subject['name'] ?? 'Subject'}',
                              totalMarks:
                                  (row['total_marks'] as num?) ?? 100,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
