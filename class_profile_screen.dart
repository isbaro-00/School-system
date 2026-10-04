import 'package:flutter/material.dart';
import 'class_subject_service.dart';

class ClassProfileScreen extends StatefulWidget {
  final Map<String, dynamic> classData;

  const ClassProfileScreen({super.key, required this.classData});

  @override
  State<ClassProfileScreen> createState() => _ClassProfileScreenState();
}

class _ClassProfileScreenState extends State<ClassProfileScreen> {
  final service = ClassSubjectService();
  late Future<List<Map<String, dynamic>>> _subjects;

  @override
  void initState() {
    super.initState();
    _subjects = service.listClassSubjects(
      classId: widget.classData['id'] as String,
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.classData;

    return Scaffold(
      appBar: AppBar(title: Text('${item['name'] ?? 'Class'}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.class_outlined),
                  title: const Text('Class'),
                  subtitle: Text('${item['name'] ?? '-'}'),
                ),
                ListTile(
                  leading: const Icon(Icons.segment),
                  title: const Text('Section'),
                  subtitle: Text('${item['section'] ?? '-'}'),
                ),
                ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: const Text('Grade'),
                  subtitle: Text('${item['grade_level'] ?? '-'}'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Assigned Subjects',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _subjects,
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final subjects = snapshot.data ?? [];
              if (subjects.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No subjects assigned yet.'),
                  ),
                );
              }

              return Column(
                children: subjects.map((row) {
                  final subject =
                      row['subjects'] as Map<String, dynamic>? ?? {};
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.menu_book_outlined),
                      title: Text('${subject['name'] ?? 'Subject'}'),
                      subtitle: Text('Code: ${subject['code'] ?? '-'}'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
