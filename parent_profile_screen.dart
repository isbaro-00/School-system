import 'package:flutter/material.dart';
import 'parent_service.dart';

class ParentProfileScreen extends StatefulWidget {
  final Map<String, dynamic> parent;

  const ParentProfileScreen({super.key, required this.parent});

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  final _service = ParentService();
  late Future<List<Map<String, dynamic>>> _children;

  @override
  void initState() {
    super.initState();
    _children = _service.listChildren(
      parentId: widget.parent['id'] as String,
    );
  }

  @override
  Widget build(BuildContext context) {
    final parent = widget.parent;
    final name =
        '${parent['first_name'] ?? ''} ${parent['last_name'] ?? ''}'.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Parent Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 36,
            child: Text(
              name.isEmpty ? 'P' : name.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              name.isEmpty ? 'Parent' : name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Parent Code'),
                  subtitle: Text('${parent['parent_code'] ?? '-'}'),
                ),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Phone'),
                  subtitle: Text('${parent['phone'] ?? '-'}'),
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text('${parent['email'] ?? '-'}'),
                ),
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined),
                  title: const Text('Status'),
                  subtitle: Text('${parent['status'] ?? '-'}'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Children',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _children,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Text('Error loading children: ${snapshot.error}');
              }

              final children = snapshot.data ?? [];

              if (children.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No children linked to this parent yet.'),
                  ),
                );
              }

              return Column(
                children: children.map((child) {
                  final childName =
                      '${child['first_name'] ?? ''} ${child['last_name'] ?? ''}'
                          .trim();

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.school_outlined),
                      title: Text(childName),
                      subtitle: Text(
                        'Admission: ${child['admission_number'] ?? '-'}',
                      ),
                      trailing: Text('${child['status'] ?? '-'}'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
