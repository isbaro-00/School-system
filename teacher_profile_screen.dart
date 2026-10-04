
import 'package:flutter/material.dart';
import 'teacher_service.dart';

class TeacherProfileScreen extends StatelessWidget {
  final String teacherId;
  const TeacherProfileScreen({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Profile')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: TeacherService.getTeacher(teacherId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Could not load profile: ${snapshot.error}'));
          }

          final t = snapshot.data;
          if (t == null) return const Center(child: Text('Teacher not found.'));

          final name =
              '${t['first_name'] ?? ''} ${t['last_name'] ?? ''}'.trim();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const CircleAvatar(
                radius: 45,
                child: Icon(Icons.person, size: 45),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              _row('Teacher Code', t['teacher_code']),
              _row('Phone', t['phone']),
              _row('Email', t['email']),
              _row('Status', t['status']),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String title, dynamic value) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value?.toString() ?? '-'),
      ),
    );
  }
}
