import 'package:flutter/material.dart';
import 'notification_service.dart';

class CreateNotificationScreen extends StatefulWidget {
  final String schoolId;

  const CreateNotificationScreen({
    super.key,
    required this.schoolId,
  });

  @override
  State<CreateNotificationScreen> createState() =>
      _CreateNotificationScreenState();
}

class _CreateNotificationScreenState
    extends State<CreateNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _message = TextEditingController();
  final service = NotificationService();

  String _type = 'announcement';
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      await service.createNotification(
        schoolId: widget.schoolId,
        title: _title.text,
        message: _message.text,
        type: _type,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create notification: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Notification')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Title is required'
                      : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Notification type',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'announcement',
                  child: Text('Announcement'),
                ),
                DropdownMenuItem(
                  value: 'fee',
                  child: Text('Fee'),
                ),
                DropdownMenuItem(
                  value: 'exam',
                  child: Text('Exam'),
                ),
                DropdownMenuItem(
                  value: 'attendance',
                  child: Text('Attendance'),
                ),
                DropdownMenuItem(
                  value: 'system',
                  child: Text('System'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _message,
              maxLines: 7,
              decoration: const InputDecoration(
                labelText: 'Message',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.message_outlined),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Message is required'
                      : null,
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
                  : const Icon(Icons.send_outlined),
              label: Text(_saving ? 'Saving...' : 'Create Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
