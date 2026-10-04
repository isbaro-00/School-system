import 'package:flutter/material.dart';
import 'create_school_screen.dart';
import 'school_payments_screen.dart';
import 'schools_screen.dart';
import 'support_tickets_screen.dart';
import 'super_admin_service.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  final _service = SuperAdminService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.listSchools();
  }

  void _reload() => setState(() => _future = _service.listSchools());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('N77 School Management', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          Text('Super Admin', style: TextStyle(fontSize: 11)),
        ]),
        actions: [IconButton(onPressed: _reload, icon: const Icon(Icons.refresh))],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return _ErrorState(message: '${snapshot.error}', onRetry: _reload);
          final schools = snapshot.data ?? [];
          final active = schools.where((s) => '${s['status']}'.toLowerCase() == 'active').length;
          final inactive = schools.length - active;

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Salaan, Super Admin 👋', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Maamul dhammaan schools-ka halkaan.'),
                const SizedBox(height: 18),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.8,
                  children: [
                    _StatCard('Dhammaan Schools', '${schools.length}', Icons.school, Colors.blue),
                    _StatCard('Active Schools', '$active', Icons.check_circle, Colors.green),
                    _StatCard('Inactive Schools', '$inactive', Icons.cancel, Colors.red),
                    _StatCard('Maamul', 'Schools', Icons.admin_panel_settings, Colors.deepPurple),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final created = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const CreateSchoolScreen()));
                      if (created == true) _reload();
                    },
                    icon: const Icon(Icons.add_business),
                    label: const Text('Abuuri School Cusub'),
                  ),
                ),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Schools-ka Ugu Dambeeyay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const SchoolsScreen())); _reload(); }, child: const Text('Dhammaan')),
                ]),
                const SizedBox(height: 6),
                ...schools.take(5).map((school) => _schoolTile(context, school)),
                const SizedBox(height: 12),
                _ActionCard(title: 'Payments / Transactions', icon: Icons.payments_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SchoolPaymentsScreen()))),
                _ActionCard(title: 'Support Tickets', icon: Icons.support_agent_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportTicketsScreen()))),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _schoolTile(BuildContext context, Map<String, dynamic> school) {
    final active = '${school['status']}'.toLowerCase() == 'active';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(child: Icon(active ? Icons.school : Icons.school_outlined)),
        title: Text('${school['name'] ?? 'School'}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${school['school_code'] ?? '-'}\n${school['school_access_code'] ?? '-'}'),
        isThreeLine: true,
        trailing: Chip(label: Text(active ? 'Active' : 'Inactive')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.title, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
      Icon(icon, color: color), const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
      ])),
    ])),
  );
}

class _ActionCard extends StatelessWidget {
  final String title; final IconData icon; final VoidCallback onTap;
  const _ActionCard({required this.title, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(child: ListTile(leading: Icon(icon), title: Text(title), trailing: const Icon(Icons.chevron_right), onTap: onTap));
}

class _ErrorState extends StatelessWidget {
  final String message; final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.error_outline, size: 48), const SizedBox(height: 12), Text(message, textAlign: TextAlign.center), const SizedBox(height: 12), FilledButton(onPressed: onRetry, child: const Text('Mar kale isku day')),
  ])));
}
