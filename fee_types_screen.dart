import 'package:flutter/material.dart';
import 'fee_service.dart';
import 'add_fee_type_screen.dart';

class FeeTypesScreen extends StatefulWidget {
  final String schoolId;

  const FeeTypesScreen({super.key, required this.schoolId});

  @override
  State<FeeTypesScreen> createState() => _FeeTypesScreenState();
}

class _FeeTypesScreenState extends State<FeeTypesScreen> {
  final service = FeeService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = service.listFeeTypes(schoolId: widget.schoolId);
  }

  Future<void> _add() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddFeeTypeScreen(schoolId: widget.schoolId),
      ),
    );
    if (result == true) setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fee Types')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Add Fee Type'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No fee types found.'));
          }

          return RefreshIndicator(
            onRefresh: () async => setState(_reload),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final item = items[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.attach_money),
                    ),
                    title: Text('${item['name'] ?? 'Fee'}'),
                    subtitle: Text(
                      'Amount: ${item['amount'] ?? '-'}\n'
                      'Frequency: ${item['frequency'] ?? '-'}',
                    ),
                    isThreeLine: true,
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
