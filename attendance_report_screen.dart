import 'package:flutter/material.dart';
import 'report_service.dart';

class AttendanceReportScreen extends StatefulWidget {
  final String schoolId;

  const AttendanceReportScreen({
    super.key,
    required this.schoolId,
  });

  @override
  State<AttendanceReportScreen> createState() =>
      _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  final service = ReportService();
  DateTime? _from;
  DateTime? _to;

  Future<void> _pickFrom() async {
    final value = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _from ?? DateTime.now(),
    );
    if (value != null) setState(() => _from = value);
  }

  Future<void> _pickTo() async {
    final value = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _to ?? DateTime.now(),
    );
    if (value != null) setState(() => _to = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Report')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickFrom,
                    child: Text(
                      _from == null
                          ? 'From'
                          : '${_from!.year}-${_from!.month}-${_from!.day}',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickTo,
                    child: Text(
                      _to == null
                          ? 'To'
                          : '${_to!.year}-${_to!.month}-${_to!.day}',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: service.attendanceSummary(
                schoolId: widget.schoolId,
                from: _from,
                to: _to,
              ),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final rows = snapshot.data ?? [];
                final present =
                    rows.where((r) => r['status'] == 'present').length;
                final absent =
                    rows.where((r) => r['status'] == 'absent').length;
                final late =
                    rows.where((r) => r['status'] == 'late').length;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  children: [
                    Row(
                      children: [
                        Expanded(child: _Box('Present', present)),
                        const SizedBox(width: 8),
                        Expanded(child: _Box('Absent', absent)),
                        const SizedBox(width: 8),
                        Expanded(child: _Box('Late', late)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...rows.map(
                      (row) => ListTile(
                        leading: const Icon(Icons.event_available_outlined),
                        title: Text('${row['status'] ?? '-'}'),
                        subtitle: Text(
                          'Student: ${row['student_id'] ?? '-'}\n'
                          'Date: ${row['attendance_date'] ?? '-'}',
                        ),
                        isThreeLine: true,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  final String label;
  final int value;

  const _Box(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text('$value', style: Theme.of(context).textTheme.titleLarge),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
