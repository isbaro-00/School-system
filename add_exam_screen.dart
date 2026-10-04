import 'package:flutter/material.dart';
import 'exam_service.dart';

class AddExamScreen extends StatefulWidget {
  final String schoolId;

  const AddExamScreen({super.key, required this.schoolId});

  @override
  State<AddExamScreen> createState() => _AddExamScreenState();
}

class _AddExamScreenState extends State<AddExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _service = ExamService();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _chooseStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _startDate = date);
  }

  Future<void> _chooseEnd() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _endDate = date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date cannot be before start date.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await _service.createExam(
        schoolId: widget.schoolId,
        name: _name.text,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create exam: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _display(DateTime? date) {
    if (date == null) return 'Not selected';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Exam')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Exam name',
                prefixIcon: Icon(Icons.assignment_outlined),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Exam name is required'
                  : null,
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Start date'),
                subtitle: Text(_display(_startDate)),
                trailing: TextButton(
                  onPressed: _chooseStart,
                  child: const Text('Choose'),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.event),
                title: const Text('End date'),
                subtitle: Text(_display(_endDate)),
                trailing: TextButton(
                  onPressed: _chooseEnd,
                  child: const Text('Choose'),
                ),
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
              label: Text(_saving ? 'Saving...' : 'Create Exam'),
            ),
          ],
        ),
      ),
    );
  }
}
