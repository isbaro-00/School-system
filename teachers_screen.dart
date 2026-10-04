
import 'package:flutter/material.dart';
import '../../core/models/app_user.dart';
import 'teacher_service.dart';
import 'add_teacher_screen.dart';
import 'teacher_profile_screen.dart';

class TeachersScreen extends StatefulWidget {
  final AppUser user;
  const TeachersScreen({super.key, required this.user});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  late Future<List<Map<String, dynamic>>> future;

  @override
  void initState() {
    super.initState();
    future = TeacherService.listTeachers(schoolId: widget.user.schoolId);
  }

  void reload() {
    setState(() {
      future = TeacherService.listTeachers(schoolId: widget.user.schoolId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teachers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => AddTeacherScreen(user: widget.user),
            ),
          );
          if (added == true) reload();
        },
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Teacher'),
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
                child: Text('Could not load teachers.\n${snapshot.error}'),
              ),
            );
          }

          final teachers = snapshot.data ?? [];
          if (teachers.isEmpty) {
            return const Center(child: Text('No teachers found for this school.'));
          }

          return RefreshIndicator(
            onRefresh: () async => reload(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: teachers.length,
              itemBuilder: (_, index) {
                final t = teachers[index];
                final name =
                    '${t['first_name'] ?? ''} ${t['last_name'] ?? ''}'.trim();

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(name.isEmpty ? 'Teacher' : name),
                    subtitle: Text(
                      'Code: ${t['teacher_code'] ?? '-'}\n'
                      'Status: ${t['status'] ?? '-'}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeacherProfileScreen(
                            teacherId: t['id'].toString(),
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
