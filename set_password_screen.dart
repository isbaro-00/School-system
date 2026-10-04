import 'package:flutter/material.dart';
import '../../core/models/account_type.dart';
import '../../core/services/auth_service.dart';
import 'dashboard_screen.dart';

class SetPasswordScreen extends StatefulWidget {
  final AccountType accountType;
  final String schoolAccessCode;
  final String identifier;
  final Map<String, dynamic> verificationData;

  const SetPasswordScreen({
    super.key,
    required this.accountType,
    required this.schoolAccessCode,
    required this.identifier,
    required this.verificationData,
  });

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool obscure = true;
  bool loading = false;

  Future<void> continueNext() async {
    if (password.text.length < 8) {
      _error('Password must be at least 8 characters.');
      return;
    }
    if (password.text != confirm.text) {
      _error('Passwords do not match.');
      return;
    }

    setState(() => loading = true);
    try {
      final activated = widget.verificationData['activated'] == true;
      String? email = widget.verificationData['auth_login_email']?.toString();

      if (!activated) {
        final result = await AuthService.setupAccount(
          schoolAccessCode: widget.schoolAccessCode,
          accountType: widget.accountType.apiValue,
          identifier: widget.identifier,
          password: password.text,
        );
        email = result['auth_login_email']?.toString();
      }

      if (email == null || email.isEmpty) {
        throw Exception('Authentication email was not returned.');
      }

      await AuthService.signIn(
        authLoginEmail: email,
        password: password.text,
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            accountType: widget.accountType,
            displayName:
                (widget.verificationData['display_name'] ?? 'User').toString(),
          ),
        ),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _error(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create your password',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your password is saved through the secure Supabase Auth flow.',
            ),
            const SizedBox(height: 24),
            TextField(
              controller: password,
              obscureText: obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => obscure = !obscure),
                  icon: Icon(
                    obscure ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: confirm,
              obscureText: obscure,
              decoration: const InputDecoration(
                labelText: 'Confirm password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: continueNext,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
