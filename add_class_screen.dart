import 'package:flutter/material.dart';
import 'class_subject_service.dart';

class AddClassScreen extends StatefulWidget {
  final String schoolId;

  const AddClassScreen({super.key, required this.schoolId});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _section = TextEditingController();
  final _grade = TextEditingController();
  final _service = ClassSubjectService();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _section.dispose();
    _grade.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await _service.createClass(
        schoolId: widget.schoolId,
        name: _name.text,
        section: _section.text,
        gradeLevel: _grade.text,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create class: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Class')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Class name',
                prefixIcon: Icon(Icons.class_outlined),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Class name is required'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _section,
              decoration: const InputDecoration(
                labelText: 'Section (optional)',
                prefixIcon: Icon(Icons.segment),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _grade,
              decoration: const InputDecoration(
                labelText: 'Grade level (optional)',
                prefixIcon: Icon(Icons.school_outlined),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving...' : 'Create Class'),
            ),
          ],
        ),
      ),
    );
  }
}
