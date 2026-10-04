
import 'package:flutter/material.dart';
import '../../core/models/app_user.dart';
import 'base_dashboard.dart';
import 'dashboard_card.dart';

class StudentDashboard extends StatelessWidget {
  final AppUser user;

  const StudentDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BaseDashboard(
      user: user,
      title: 'Student Dashboard',
      subtitle: 'Your school information in one place.',
      cards: [
        DashboardCard(
          icon: Icons.grade,
          title: 'Results',
          subtitle: 'View exams and report cards',
        ),
        DashboardCard(
          icon: Icons.schedule,
          title: 'Timetable',
          subtitle: 'View your class schedule',
        ),
        DashboardCard(
          icon: Icons.fact_check,
          title: 'Attendance',
          subtitle: 'View your attendance record',
        ),
        DashboardCard(
          icon: Icons.payments,
          title: 'Fees',
          subtitle: 'View fee information',
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
