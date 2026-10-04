import 'package:flutter/material.dart';
import 'fee_service.dart';

class AddFeeTypeScreen extends StatefulWidget {
  final String schoolId;

  const AddFeeTypeScreen({super.key, required this.schoolId});

  @override
  State<AddFeeTypeScreen> createState() => _AddFeeTypeScreenState();
}

class _AddFeeTypeScreenState extends State<AddFeeTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _description = TextEditingController();
  final _frequency = TextEditingController();
  final _service = FeeService();

  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _description.dispose();
    _frequency.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = num.tryParse(_amount.text.trim());
    if (amount == null || amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await _service.createFeeType(
        schoolId: widget.schoolId,
        name: _name.text,
        amount: amount,
        description: _description.text,
        frequency: _frequency.text,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create fee type: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Fee Type')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Fee name',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Fee name is required'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Amount is required'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _frequency,
              decoration: const InputDecoration(
                labelText: 'Frequency (e.g. monthly)',
                prefixIcon: Icon(Icons.repeat),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: Icon(Icons.description_outlined),
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
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving...' : 'Create Fee Type'),
            ),
          ],
        ),
      ),
    );
  }
}
