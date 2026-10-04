import 'package:flutter/material.dart';
import 'timetable_service.dart';

class AddTimetableScreen extends StatefulWidget {
  final String schoolId;
  final String? classId;

  const AddTimetableScreen({
    super.key,
    required this.schoolId,
    this.classId,
  });

  @override
  State<AddTimetableScreen> createState() => _AddTimetableScreenState();
}

class _AddTimetableScreenState extends State<AddTimetableScreen> {
  final service = TimetableService();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _classes = [];
  String? _selectedClass;
  final _subjectId = TextEditingController();
  final _teacherId = TextEditingController();
  final _startTime = TextEditingController();
  final _endTime = TextEditingController();
  final _room = TextEditingController();

  int _dayOfWeek = 1;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedClass = widget.classId;
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      _classes = await service.listClasses(schoolId: widget.schoolId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load classes: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a class.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await service.createTimetableEntry(
        schoolId: widget.schoolId,
        classId: _selectedClass!,
        subjectId: _subjectId.text.trim(),
        teacherId: _teacherId.text.trim(),
        dayOfWeek: _dayOfWeek,
        startTime: _startTime.text.trim(),
        endTime: _endTime.text.trim(),
        room: _room.text,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create timetable entry: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _subjectId.dispose();
    _teacherId.dispose();
    _startTime.dispose();
    _endTime.dispose();
    _room.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const dayNames = {
      0: 'Sunday',
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Add Timetable Period')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedClass,
                    decoration: const InputDecoration(
                      labelText: 'Class',
                      prefixIcon: Icon(Icons.class_outlined),
                    ),
                    items: _classes
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item['id'] as String,
                            child: Text(
                              '${item['name'] ?? 'Class'}'
                              '${item['section'] != null ? ' - ${item['section']}' : ''}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedClass = value),
                    validator: (v) =>
                        v == null ? 'Class is required' : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    value: _dayOfWeek,
                    decoration: const InputDecoration(
                      labelText: 'Day',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    items: dayNames.entries
                        .map(
                          (e) => DropdownMenuItem<int>(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _dayOfWeek = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _subjectId,
                    decoration: const InputDecoration(
                      labelText: 'Subject ID',
                      prefixIcon: Icon(Icons.menu_book_outlined),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Subject ID is required'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _teacherId,
                    decoration: const InputDecoration(
                      labelText: 'Teacher ID (optional)',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _startTime,
                    decoration: const InputDecoration(
                      labelText: 'Start time',
                      hintText: '08:00:00',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Start time is required'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _endTime,
                    decoration: const InputDecoration(
                      labelText: 'End time',
                      hintText: '09:00:00',
                      prefixIcon: Icon(Icons.access_time_filled),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'End time is required'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _room,
                    decoration: const InputDecoration(
                      labelText: 'Room (optional)',
                      prefixIcon: Icon(Icons.meeting_room_outlined),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'Saving...' : 'Save Period'),
                  ),
                ],
              ),
            ),
    );
  }
}
