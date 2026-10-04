
import 'package:flutter/material.dart';
import '../../core/models/app_user.dart';
import 'student_service.dart';

class AddStudentScreen extends StatefulWidget {
  final AppUser user;
  const AddStudentScreen({super.key, required this.user});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final first = TextEditingController();
  final last = TextEditingController();
  String gender = 'male';
  DateTime? dob;
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
      final date = dob == null
          ? null
          : '${dob!.year.toString().padLeft(4, '0')}-'
              '${dob!.month.toString().padLeft(2, '0')}-'
              '${dob!.day.toString().padLeft(2, '0')}';

      await StudentService.createStudent(
        schoolId: widget.user.schoolId,
        firstName: first.text,
        lastName: last.text,
        gender: gender,
        dateOfBirth: date,
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save student: $e')),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Student')),
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
          DropdownButtonFormField<String>(
            value: gender,
            decoration: const InputDecoration(labelText: 'Gender'),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
            ],
            onChanged: (v) => setState(() => gender = v ?? 'male'),
          ),
          const SizedBox(height: 14),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            leading: const Icon(Icons.calendar_today),
            title: Text(
              dob == null
                  ? 'Date of birth'
                  : '${dob!.day}/${dob!.month}/${dob!.year}',
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime(1990),
                lastDate: DateTime.now(),
                initialDate: DateTime(2012),
              );
              if (picked != null) setState(() => dob = picked);
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: saving ? null : save,
            child: Text(saving ? 'Saving...' : 'Save Student'),
          ),
        ],
      ),
    );
  }
}
