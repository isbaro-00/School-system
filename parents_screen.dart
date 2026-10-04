import 'package:flutter/material.dart';
import 'parent_service.dart';
import 'add_parent_screen.dart';
import 'parent_profile_screen.dart';

class ParentsScreen extends StatefulWidget {
  final String schoolId;

  const ParentsScreen({super.key, required this.schoolId});

  @override
  State<ParentsScreen> createState() => _ParentsScreenState();
}

class _ParentsScreenState extends State<ParentsScreen> {
  final service = ParentService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = service.listParents(schoolId: widget.schoolId);
  }

  Future<void> _addParent() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddParentScreen(schoolId: widget.schoolId),
      ),
    );

    if (created == true) {
      setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parents')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addParent,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Parent'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }

          final parents = snapshot.data ?? [];

          if (parents.isEmpty) {
            return const Center(
              child: Text('No parents found. Add the first parent.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => setState(_reload),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: parents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final parent = parents[index];
                final name =
                    '${parent['first_name'] ?? ''} ${parent['last_name'] ?? ''}'
                        .trim();

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(name.isEmpty ? 'Unnamed Parent' : name),
                    subtitle: Text(
                      'Code: ${parent['parent_code'] ?? '-'}\n'
                      'Phone: ${parent['phone'] ?? '-'}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ParentProfileScreen(
                            parent: parent,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
