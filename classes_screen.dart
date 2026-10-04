import 'package:flutter/material.dart';
import 'class_subject_service.dart';
import 'add_class_screen.dart';
import 'class_profile_screen.dart';

class ClassesScreen extends StatefulWidget {
  final String schoolId;

  const ClassesScreen({super.key, required this.schoolId});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final service = ClassSubjectService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = service.listClasses(schoolId: widget.schoolId);
  }

  Future<void> _addClass() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddClassScreen(schoolId: widget.schoolId),
      ),
    );
    if (result == true) setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addClass,
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
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
                final section = item['section'];
                final grade = item['grade_level'];

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.class_outlined),
                    ),
                    title: Text('${item['name'] ?? 'Class'}'),
                    subtitle: Text(
                      'Section: ${section ?? '-'}\nGrade: ${grade ?? '-'}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClassProfileScreen(classData: item),
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
