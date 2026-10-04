
import 'package:flutter/material.dart';
import '../../core/models/app_user.dart';
import 'base_dashboard.dart';
import 'dashboard_card.dart';

class TeacherDashboard extends StatelessWidget {
  final AppUser user;

  const TeacherDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BaseDashboard(
      user: user,
      title: 'Teacher Dashboard',
      subtitle: 'Your classes, attendance and exams.',
      cards: [
        DashboardCard(
          icon: Icons.class_,
          title: 'My Classes',
          subtitle: 'View assigned classes and students',
        ),
        DashboardCard(
          icon: Icons.fact_check,
          title: 'Attendance',
          subtitle: 'Take and review attendance',
        ),
        DashboardCard(
          icon: Icons.edit_note,
          title: 'Exams',
          subtitle: 'Enter and review student marks',
        ),
        DashboardCard(
          icon: Icons.schedule,
          title: 'Timetable',
          subtitle: 'View your teaching schedule',
        ),
        DashboardCard(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'School announcements',
        ),
      ],
    );
  }
}
