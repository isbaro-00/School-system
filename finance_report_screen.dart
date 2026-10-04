import 'package:flutter/material.dart';
import 'report_service.dart';

class FinanceReportScreen extends StatefulWidget {
  final String schoolId;

  const FinanceReportScreen({
    super.key,
    required this.schoolId,
  });

  @override
  State<FinanceReportScreen> createState() => _FinanceReportScreenState();
}

class _FinanceReportScreenState extends State<FinanceReportScreen> {
  final service = ReportService();
  DateTime? _from;
  DateTime? _to;

  double _amount(List<Map<String, dynamic>> rows) {
    return rows.fold<double>(
      0,
      (sum, row) =>
          sum + (double.tryParse('${row['amount'] ?? 0}') ?? 0),
    );
  }

  Future<void> _pick(bool from) async {
    final value = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (value != null) {
      setState(() {
        if (from) {
          _from = value;
        } else {
          _to = value;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finance Report')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pick(true),
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
                    onPressed: () => _pick(false),
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
              future: service.paymentSummary(
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
                final total = _amount(rows);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text('Total Payments'),
                            const SizedBox(height: 6),
                            Text(
                              total.toStringAsFixed(2),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...rows.map(
                      (row) => ListTile(
                        leading: const Icon(Icons.receipt_long_outlined),
                        title: Text('${row['payment_id'] ?? row['id'] ?? '-'}'),
                        subtitle: Text(
                          'Amount: ${row['amount'] ?? 0}\n'
                          'Date: ${row['payment_date'] ?? '-'}',
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
