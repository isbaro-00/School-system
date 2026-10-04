import 'package:flutter/material.dart';
import 'attendance_service.dart';

class TakeAttendanceScreen extends StatefulWidget {
  final String schoolId;
  final Map<String, dynamic> classData;

  const TakeAttendanceScreen({
    super.key,
    required this.schoolId,
    required this.classData,
  });

  @override
  State<TakeAttendanceScreen> createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {
  final service = AttendanceService();

  DateTime _date = DateTime.now();
  bool _loading = true;
  bool _saving = false;

  List<Map<String, dynamic>> _students = [];
  final Map<String, String> _status = {};
  final Map<String, String> _remarks = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _keyDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final classId = widget.classData['id'] as String;

      final students = await service.listStudents(
        schoolId: widget.schoolId,
        classId: classId,
      );

      final existing = await service.getAttendanceForDate(
        schoolId: widget.schoolId,
        classId: classId,
        date: _date,
      );

      final byStudent = {
        for (final row in existing) row['student_id'] as String: row,
      };

      _students = students;

      for (final student in students) {
        final id = student['id'] as String;
        final row = byStudent[id];

        _status[id] = row?['status']?.toString() ?? 'present';
        _remarks[id] = row?['remarks']?.toString() ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load attendance: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _date = picked);
      await _load();
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    try {
      final classId = widget.classData['id'] as String;

      for (final student in _students) {
        final id = student['id'] as String;

        await service.saveAttendance(
          schoolId: widget.schoolId,
          classId: classId,
          studentId: id,
          date: _date,
          status: _status[id] ?? 'present',
          remarks: _remarks[id],
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance saved successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save attendance: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      case 'excused':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final className = widget.classData['name'] ?? 'Class';

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance — $className'),
        actions: [
          IconButton(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Choose date',
          ),
        ],
      ),
      floatingActionButton: _students.isEmpty || _loading
          ? null
          : FloatingActionButton.extended(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_saving ? 'Saving...' : 'Save'),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? const Center(
                  child: Text('No students are assigned to this class.'),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Attendance Date'),
                        subtitle: Text(_keyDate(_date)),
                        trailing: TextButton(
                          onPressed: _pickDate,
                          child: const Text('Change'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._students.map(_studentTile),
                  ],
                ),
    );
  }

  Widget _studentTile(Map<String, dynamic> student) {
    final id = student['id'] as String;
    final name =
        '${student['first_name'] ?? ''} ${student['last_name'] ?? ''}'.trim();
    final status = _status[id] ?? 'present';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                child: Text(
                  name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
                ),
              ),
              title: Text(name.isEmpty ? 'Student' : name),
              subtitle: Text(
                'Admission: ${student['admission_number'] ?? '-'}',
              ),
            ),
            DropdownButtonFormField<String>(
              value: status,
              decoration: InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(
                  Icons.circle,
                  color: _statusColor(status),
                  size: 16,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'present',
                  child: Text('Present'),
                ),
                DropdownMenuItem(
                  value: 'absent',
                  child: Text('Absent'),
                ),
                DropdownMenuItem(
                  value: 'late',
                  child: Text('Late'),
                ),
                DropdownMenuItem(
                  value: 'excused',
                  child: Text('Excused'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _status[id] = value);
                }
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _remarks[id],
              decoration: const InputDecoration(
                labelText: 'Remarks (optional)',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              onChanged: (value) => _remarks[id] = value,
            ),
          ],
        ),
      ),
    );
  }
}
