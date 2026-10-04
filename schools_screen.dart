import 'package:flutter/material.dart';
import 'super_admin_service.dart';

class SchoolsScreen extends StatefulWidget {
  const SchoolsScreen({super.key});
  @override
  State<SchoolsScreen> createState() => _SchoolsScreenState();
}

class _SchoolsScreenState extends State<SchoolsScreen> {
  final _service = SuperAdminService();
  late Future<List<Map<String, dynamic>>> _future;
  String _filter = 'all';

  @override
  void initState() { super.initState(); _future = _service.listSchools(); }
  void _reload() => setState(() => _future = _service.listSchools());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schools'), actions: [IconButton(onPressed: _reload, icon: const Icon(Icons.refresh))]),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final all = snapshot.data ?? [];
          final rows = all.where((r) => _filter == 'all' || '${r['status']}'.toLowerCase() == _filter).toList();
          return Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 4), child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('Dhammaan')),
                ButtonSegment(value: 'active', label: Text('Active')),
                ButtonSegment(value: 'inactive', label: Text('Inactive')),
              ], selected: {_filter}, onSelectionChanged: (s) => setState(() => _filter = s.first),
            )),
            Expanded(child: rows.isEmpty ? const Center(child: Text('School lama helin.')) : ListView.separated(
              padding: const EdgeInsets.all(12), itemCount: rows.length, separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) => _schoolCard(rows[index]),
            )),
          ]);
        },
      ),
    );
  }

  Widget _schoolCard(Map<String, dynamic> row) {
    final active = '${row['status']}'.toLowerCase() == 'active';
    return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      Row(children: [
        const CircleAvatar(child: Icon(Icons.school)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${row['name'] ?? 'School'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text('${row['school_code'] ?? '-'} • ${row['school_access_code'] ?? '-'}'),
        ])),
        Chip(label: Text(active ? 'Active' : 'Inactive')),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: OutlinedButton.icon(onPressed: () => _showCodes(row), icon: const Icon(Icons.key), label: const Text('Codes'))),
        const SizedBox(width: 8),
        Expanded(child: FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: active ? Colors.red : Colors.green),
          onPressed: () async {
            try { await _service.setSchoolStatus(schoolId: '${row['id']}', active: !active); _reload(); }
            catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Khalad: $e'))); }
          },
          icon: Icon(active ? Icons.block : Icons.check_circle), label: Text(active ? 'Deactivate' : 'Activate'),
        )),
      ]),
    ])));
  }

  void _showCodes(Map<String, dynamic> row) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text('${row['name']} Codes'),
      content: Text('School Code: ${row['school_code']}\nAccess Code: ${row['school_access_code']}'),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Xir'))],
    ));
  }
}
