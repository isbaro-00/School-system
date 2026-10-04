
import 'package:flutter/material.dart';
import '../../core/models/app_user.dart';
import 'admin_dashboard.dart';
import '../super_admin/super_admin_dashboard_screen.dart';
import 'student_dashboard.dart';
import 'teacher_dashboard.dart';
import 'parent_dashboard.dart';

class DashboardRouter extends StatelessWidget {
  final AppUser user;

  const DashboardRouter({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    switch (user.role.toLowerCase()) {
      case 'super_admin':
        return const SuperAdminDashboardScreen();
      case 'school_admin':
      case 'principal':
      case 'accountant':
        return AdminDashboard(user: user);
      case 'teacher':
        return TeacherDashboard(user: user);
      case 'student':
        return StudentDashboard(user: user);
      case 'parent':
        return ParentDashboard(user: user);
      default:
        return Scaffold(
          appBar: AppBar(title: const Text('Dashboard')),
          body: Center(
            child: Text('Unknown role: ${user.role}'),
          ),
        );
    }
  }
}
