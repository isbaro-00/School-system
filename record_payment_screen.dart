import 'package:flutter/material.dart';
import 'fee_service.dart';

class RecordPaymentScreen extends StatefulWidget {
  final String schoolId;
  final String studentId;
  final String studentFeeId;

  const RecordPaymentScreen({
    super.key,
    required this.schoolId,
    required this.studentId,
    required this.studentFeeId,
  });

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _method = TextEditingController();
  final _service = FeeService();

  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _method.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = num.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid payment amount.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final payment = await _service.recordPayment(
        schoolId: widget.schoolId,
        studentId: widget.studentId,
        studentFeeId: widget.studentFeeId,
        amount: amount,
        paymentMethod: _method.text.trim(),
        reference: _reference.text,
        paymentDate: DateTime.now(),
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Payment Recorded'),
          content: Text(
            'Payment ID: ${payment['payment_id'] ?? payment['id'] ?? '-'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not record payment: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Payment')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Payment amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Amount is required'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _method,
              decoration: const InputDecoration(
                labelText: 'Payment method',
                hintText: 'e.g. Cash, EVC, Bank',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Payment method is required'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _reference,
              decoration: const InputDecoration(
                labelText: 'Reference (optional)',
                prefixIcon: Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(_saving ? 'Saving...' : 'Record Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
