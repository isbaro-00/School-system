
import 'package:flutter/material.dart';
import '../../core/models/app_user.dart';
import 'teacher_service.dart';

class AddTeacherScreen extends StatefulWidget {
  final AppUser user;
  const AddTeacherScreen({super.key, required this.user});

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final first = TextEditingController();
  final last = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  bool saving = false;

  Future<void> save() async {
    if (first.text.trim().isEmpty || last.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First name and last name are required.')),
      );
      return;
    }

    setState(() => saving = true);
    try {
      await TeacherService.createTeacher(
        schoolId: widget.user.schoolId,
        firstName: first.text,
        lastName: last.text,
        phone: phone.text,
        email: email.text,
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save teacher: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    first.dispose();
    last.dispose();
    phone.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Teacher')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: first,
            decoration: const InputDecoration(
              labelText: 'First name',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: last,
            decoration: const InputDecoration(
              labelText: 'Last name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone',
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: saving ? null : save,
            child: Text(saving ? 'Saving...' : 'Save Teacher'),
          ),
        ],
      ),
    );
  }
}
