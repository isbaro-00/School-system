import 'package:flutter/material.dart';
import '../../core/models/account_type.dart';
import '../../core/services/supabase_service.dart';
import 'set_password_screen.dart';

class AccountIdentifierScreen extends StatefulWidget {
  final AccountType accountType;
  final String schoolAccessCode;

  const AccountIdentifierScreen({
    super.key,
    required this.accountType,
    required this.schoolAccessCode,
  });

  @override
  State<AccountIdentifierScreen> createState() =>
      _AccountIdentifierScreenState();
}

class _AccountIdentifierScreenState extends State<AccountIdentifierScreen> {
  final controller = TextEditingController();
  bool loading = false;

  String get hint {
    switch (widget.accountType) {
      case AccountType.student:
        return 'STU-2026-00001';
      case AccountType.teacher:
        return 'TCH-2026-00001';
      case AccountType.parent:
        return 'PAR-00001';
      case AccountType.schoolAdmin:
        return 'Admin email or phone';
    }
  }

  String get label {
    switch (widget.accountType) {
      case AccountType.student:
        return 'Admission Number';
      case AccountType.teacher:
        return 'Teacher Code';
      case AccountType.parent:
        return 'Parent Code';
      case AccountType.schoolAdmin:
        return 'Email or Phone';
    }
  }

  Future<void> verify() async {
    if (controller.text.trim().isEmpty) return;

    setState(() => loading = true);
    try {
      final result = await SupabaseService.verifySchoolAndAccount(
        schoolAccessCode: widget.schoolAccessCode,
        accountType: widget.accountType.apiValue,
        identifier: controller.text.trim(),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SetPasswordScreen(
            accountType: widget.accountType,
            schoolAccessCode: widget.schoolAccessCode,
            identifier: controller.text.trim(),
            verificationData: result,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification failed. Check the School Access Code and your identifier.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify account')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Enter the $label registered by your school.'),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                prefixIcon: const Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: loading ? null : verify,
                child: Text(loading ? 'Checking...' : 'Verify'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
