import 'package:flutter/material.dart';
import '../../core/models/account_type.dart';
import 'account_identifier_screen.dart';

class SchoolAccessScreen extends StatefulWidget {
  final AccountType accountType;

  const SchoolAccessScreen({super.key, required this.accountType});

  @override
  State<SchoolAccessScreen> createState() => _SchoolAccessScreenState();
}

class _SchoolAccessScreenState extends State<SchoolAccessScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void next() {
    final code = controller.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your School Access Code.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccountIdentifierScreen(
          accountType: widget.accountType,
          schoolAccessCode: code,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.accountType.label)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'School Access Code',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the private code given to you by your school. '
              'This code identifies the school; it does not give access by itself.',
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'School Access Code',
                hintText: 'ACC-XXXXXXXX',
                prefixIcon: Icon(Icons.key),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: next,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
