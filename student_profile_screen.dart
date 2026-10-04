
import 'package:flutter/material.dart';
import 'student_service.dart';

class StudentProfileScreen extends StatelessWidget {
  final String studentId;
  const StudentProfileScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Profile')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: StudentService.getStudent(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Could not load profile: ${snapshot.error}'));
          }

          final s = snapshot.data;
          if (s == null) return const Center(child: Text('Student not found.'));

          final name =
              '${s['first_name'] ?? ''} ${s['last_name'] ?? ''}'.trim();

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
              _row('Admission Number', s['admission_number']),
              _row('Gender', s['gender']),
              _row('Date of Birth', s['date_of_birth']),
              _row('Status', s['status']),
              _row('Class ID', s['class_id']),
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
