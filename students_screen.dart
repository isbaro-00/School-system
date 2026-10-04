
import 'package:flutter/material.dart';
import '../../core/models/app_user.dart';
import 'student_service.dart';
import 'add_student_screen.dart';
import 'student_profile_screen.dart';

class StudentsScreen extends StatefulWidget {
  final AppUser user;
  const StudentsScreen({super.key, required this.user});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  late Future<List<Map<String, dynamic>>> future;

  @override
  void initState() {
    super.initState();
    future = StudentService.listStudents(schoolId: widget.user.schoolId);
  }

  void reload() {
    setState(() {
      future = StudentService.listStudents(schoolId: widget.user.schoolId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => AddStudentScreen(user: widget.user),
            ),
          );
          if (added == true) reload();
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Student'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Could not load students.\n${snapshot.error}'),
              ),
            );
          }

          final students = snapshot.data ?? [];
          if (students.isEmpty) {
            return const Center(
              child: Text('No students found for this school.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => reload(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: students.length,
              itemBuilder: (_, index) {
                final s = students[index];
                final name =
                    '${s['first_name'] ?? ''} ${s['last_name'] ?? ''}'.trim();

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(name.isEmpty ? 'Student' : name),
                    subtitle: Text(
                      'Admission: ${s['admission_number'] ?? '-'}\n'
                      'Status: ${s['status'] ?? '-'}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentProfileScreen(
                            studentId: s['id'].toString(),
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
