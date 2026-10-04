import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://yeqpkotyeqvajxanlzpj.supabase.co',
  );
  const key = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  if (url.isEmpty || key.isEmpty) {
    runApp(const ConfigurationErrorApp());
    return;
  }

  await Supabase.initialize(url: url, publishableKey: key);
  runApp(const SchoolManagementApp());
}

class ConfigurationErrorApp extends StatelessWidget {
  const ConfigurationErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Supabase configuration is missing.\n\n'
              'Run Flutter with SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      ),
    );
  }
}
