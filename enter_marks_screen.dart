import 'package:flutter/material.dart';
import 'exam_service.dart';

class EnterMarksScreen extends StatefulWidget {
  final String schoolId;
  final String examId;
  final String examSubjectId;
  final String subjectName;
  final num totalMarks;

  const EnterMarksScreen({
    super.key,
    required this.schoolId,
    required this.examId,
    required this.examSubjectId,
    required this.subjectName,
    required this.totalMarks,
  });

  @override
  State<EnterMarksScreen> createState() => _EnterMarksScreenState();
}

class _EnterMarksScreenState extends State<EnterMarksScreen> {
  final service = ExamService();

  bool _loading = true;
  bool _saving = false;
  List<Map<String, dynamic>> _students = [];
  final Map<String, TextEditingController> _marks = {};
  final Map<String, TextEditingController> _remarks = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      // This screen needs a class context to know which students should
      // receive marks. For now, it reads existing result rows and shows
      // a clear message if no student list has been supplied.
      final results = await service.listResults(
        examId: widget.examId,
        subjectId: widget.examSubjectId,
      );

      _students = results.map((row) {
        final studentId = row['student_id'] as String;
        _marks[studentId] ??=
            TextEditingController(text: '${row['marks'] ?? ''}');
        _remarks[studentId] ??=
            TextEditingController(text: '${row['remarks'] ?? ''}');
        return {
          'id': studentId,
          'student_id': studentId,
          'marks': row['marks'],
          'grade': row['grade'],
        };
      }).toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load results: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _grade(num mark) {
    final percent = (mark / widget.totalMarks) * 100;
    if (percent >= 80) return 'A';
    if (percent >= 70) return 'B';
    if (percent >= 60) return 'C';
    if (percent >= 50) return 'D';
    return 'F';
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    try {
      for (final student in _students) {
        final studentId = student['student_id'] as String;
        final marks = num.tryParse(_marks[studentId]?.text.trim() ?? '');

        if (marks == null || marks < 0 || marks > widget.totalMarks) {
          throw Exception(
            'Invalid marks for student $studentId. '
            'Marks must be between 0 and ${widget.totalMarks}.',
          );
        }

        await service.saveResult(
          examId: widget.examId,
          examSubjectId: widget.examSubjectId,
          studentId: studentId,
          marks: marks,
          grade: _grade(marks),
          remarks: _remarks[studentId]?.text,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Results saved successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save results: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    for (final controller in _marks.values) {
      controller.dispose();
    }
    for (final controller in _remarks.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Marks — ${widget.subjectName}')),
      floatingActionButton: _students.isEmpty || _loading
          ? null
          : FloatingActionButton.extended(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(_saving ? 'Saving...' : 'Save Results'),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No existing result rows were found.\n\n'
                      'The next integration should supply students from '
                      'the selected class before entering marks.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: _students.length,
                  itemBuilder: (_, index) {
                    final student = _students[index];
                    final id = student['student_id'] as String;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const CircleAvatar(
                                child: Icon(Icons.person_outline),
                              ),
                              title: Text('Student: $id'),
                            ),
                            TextField(
                              controller: _marks[id],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                labelText:
                                    'Marks / ${widget.totalMarks}',
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _remarks[id],
                              decoration: const InputDecoration(
                                labelText: 'Remarks (optional)',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
