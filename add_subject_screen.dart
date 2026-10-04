import 'package:flutter/material.dart';
import '../classes/class_subject_service.dart';

class AddSubjectScreen extends StatefulWidget {
  final String schoolId;

  const AddSubjectScreen({super.key, required this.schoolId});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _description = TextEditingController();
  final _service = ClassSubjectService();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await _service.createSubject(
        schoolId: widget.schoolId,
        name: _name.text,
        code: _code.text,
        description: _description.text,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create subject: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Subject')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Subject name',
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Subject name is required'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _code,
              decoration: const InputDecoration(
                labelText: 'Subject code (optional)',
                prefixIcon: Icon(Icons.code),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: Icon(Icons.description_outlined),
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
              label: Text(_saving ? 'Saving...' : 'Create Subject'),
            ),
          ],
        ),
      ),
    );
  }
}
