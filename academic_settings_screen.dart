import 'package:flutter/material.dart';
import 'settings_service.dart';

class AcademicSettingsScreen extends StatefulWidget {
  final String schoolId;

  const AcademicSettingsScreen({
    super.key,
    required this.schoolId,
  });

  @override
  State<AcademicSettingsScreen> createState() =>
      _AcademicSettingsScreenState();
}

class _AcademicSettingsScreenState extends State<AcademicSettingsScreen> {
  final service = SettingsService();
  final _academicYear = TextEditingController();
  final _term = TextEditingController();
  final _grading = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await service.getSchoolSettings(
        schoolId: widget.schoolId,
      );
      if (data != null) {
        _academicYear.text = '${data['academic_year'] ?? ''}';
        _term.text = '${data['current_term'] ?? ''}';
        _grading.text = '${data['grading_system'] ?? ''}';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load settings: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await service.saveSchoolSettings(
        schoolId: widget.schoolId,
        values: {
          'academic_year': _academicYear.text.trim(),
          'current_term': _term.text.trim(),
          'grading_system': _grading.text.trim(),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Academic settings saved.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _academicYear.dispose();
    _term.dispose();
    _grading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academic Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextField(
                  controller: _academicYear,
                  decoration: const InputDecoration(
                    labelText: 'Academic year',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _term,
                  decoration: const InputDecoration(
                    labelText: 'Current term',
                    prefixIcon: Icon(Icons.date_range_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _grading,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Grading system',
                    hintText: 'Example: A=80, B=70, C=60...',
                    prefixIcon: Icon(Icons.grade_outlined),
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'Saving...' : 'Save'),
                ),
              ],
            ),
    );
  }
}
