import 'package:flutter/material.dart';
import 'timetable_service.dart';
import 'add_timetable_screen.dart';

class TimetableDashboardScreen extends StatefulWidget {
  final String schoolId;

  const TimetableDashboardScreen({super.key, required this.schoolId});

  @override
  State<TimetableDashboardScreen> createState() =>
      _TimetableDashboardScreenState();
}

class _TimetableDashboardScreenState extends State<TimetableDashboardScreen> {
  final service = TimetableService();
  late Future<List<Map<String, dynamic>>> _classes;

  String? _selectedClassId;

  @override
  void initState() {
    super.initState();
    _reloadClasses();
  }

  void _reloadClasses() {
    _classes = service.listClasses(schoolId: widget.schoolId);
  }

  Future<void> _openAdd() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTimetableScreen(
          schoolId: widget.schoolId,
          classId: _selectedClassId,
        ),
      ),
    );

    if (result == true) setState(() {});
  }

  String _dayName(dynamic value) {
    final day = value is int ? value : int.tryParse('$value') ?? 0;
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return day >= 0 && day < days.length ? days[day] : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timetable')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add Period'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _classes,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final classes = snapshot.data ?? [];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: DropdownButtonFormField<String?>(
                  value: _selectedClassId,
                  decoration: const InputDecoration(
                    labelText: 'Filter by class',
                    prefixIcon: Icon(Icons.class_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All Classes'),
                    ),
                    ...classes.map(
                      (item) => DropdownMenuItem<String?>(
                        value: item['id'] as String,
                        child: Text(
                          '${item['name'] ?? 'Class'}'
                          '${item['section'] != null ? ' - ${item['section']}' : ''}',
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedClassId = value);
                  },
                ),
              ),
              Expanded(
                child: _TimetableList(
                  service: service,
                  schoolId: widget.schoolId,
                  classId: _selectedClassId,
                  dayName: _dayName,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TimetableList extends StatelessWidget {
  final TimetableService service;
  final String schoolId;
  final String? classId;
  final String Function(dynamic) dayName;

  const _TimetableList({
    required this.service,
    required this.schoolId,
    required this.classId,
    required this.dayName,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: service.listTimetable(
        schoolId: schoolId,
        classId: classId,
      ),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final rows = snapshot.data ?? [];
        if (rows.isEmpty) {
          return const Center(child: Text('No timetable entries found.'));
        }

        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final row = rows[index];
              final subject =
                  row['subjects'] as Map<String, dynamic>? ?? {};

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.schedule_outlined),
                  ),
                  title: Text('${subject['name'] ?? 'Subject'}'),
                  subtitle: Text(
                    '${dayName(row['day_of_week'])}\n'
                    '${row['start_time'] ?? '-'} - ${row['end_time'] ?? '-'}'
                    '${row['room'] != null ? '\nRoom: ${row['room']}' : ''}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        await service.deleteEntry(row['id'] as String);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Timetable entry deleted.'),
                            ),
                          );
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
