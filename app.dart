import 'package:flutter/material.dart';
import 'theme.dart';
import '../features/splash/splash_screen.dart';

class SchoolManagementApp extends StatelessWidget {
  const SchoolManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
