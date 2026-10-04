import 'package:flutter/material.dart';
import 'super_admin_service.dart';

class CreateSchoolScreen extends StatefulWidget {
  const CreateSchoolScreen({super.key});

  @override
  State<CreateSchoolScreen> createState() => _CreateSchoolScreenState();
}

class _CreateSchoolScreenState extends State<CreateSchoolScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _admin = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _location = TextEditingController();
  final _service = SuperAdminService();
  String _plan = 'Standard';
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 365));
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _admin.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final school = await _service.createSchoolWithAdmin(
        name: _name.text,
        adminName: _admin.text,
        email: _email.text,
        password: _password.text,
        phone: _phone.text,
        location: _location.text,
        subscriptionPlan: _plan,
        subscriptionStart: _start,
        subscriptionEnd: _end,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('School Cusub Waa La Abuuray'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('School-ka u dir codes-kan:'),
              const SizedBox(height: 14),
              Text('School Code: ${school['school_code']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Access Code: ${school['school_access_code']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Status: ${school['status'] ?? 'active'}'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('School lama abuuri karin: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate(bool start) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: start ? _start : _end,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _start = picked;
        if (_end.isBefore(picked)) _end = picked.add(const Duration(days: 365));
      } else {
        _end = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Abuuri School Cusub')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(_name, 'Magaca School-ka', Icons.school_outlined),
            _field(_admin, 'Magaca Maamulka', Icons.person_outline),
            _field(_email, 'Email', Icons.email_outlined, keyboard: TextInputType.emailAddress),
            _field(_phone, 'Telefoonka', Icons.phone_outlined, keyboard: TextInputType.phone),
            _field(_password, 'Password-ka School Admin', Icons.lock_outline, keyboard: TextInputType.visiblePassword, obscure: true),
            _field(_location, 'Goobta / Location', Icons.location_on_outlined),
            DropdownButtonFormField<String>(
              value: _plan,
              decoration: const InputDecoration(labelText: 'Subscription Plan', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'Standard', child: Text('Standard')),
                DropdownMenuItem(value: 'Premium', child: Text('Premium')),
                DropdownMenuItem(value: 'Enterprise', child: Text('Enterprise')),
              ],
              onChanged: (v) => setState(() => _plan = v ?? 'Standard'),
            ),
            const SizedBox(height: 12),
            _dateTile('Taariikhda Bilaabashada', _start, () => _pickDate(true)),
            _dateTile('Taariikhda Dhammaadka', _end, () => _pickDate(false)),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add_business),
                label: Text(_saving ? 'Saving...' : 'Save School'),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Marka la save-gareeyo, School Code iyo Access Code si automatic ah ayaa loo sameynayaa.'),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {TextInputType? keyboard, bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        obscureText: obscure,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Fadlan geli $label' : null,
      ),
    );
  }

  Widget _dateTile(String label, DateTime value, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_month_outlined),
        title: Text(label),
        subtitle: Text('${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}'),
        trailing: const Icon(Icons.edit_calendar_outlined),
        onTap: onTap,
      ),
    );
  }
}
