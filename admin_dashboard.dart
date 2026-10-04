
import 'package:flutter/material.dart';
import '../../core/models/app_user.dart';
import 'base_dashboard.dart';
import 'dashboard_card.dart';

class AdminDashboard extends StatelessWidget {
  final AppUser user;

  const AdminDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BaseDashboard(
      user: user,
      title: 'Admin Dashboard',
      subtitle: 'Manage your school from one place.',
      cards: [
        DashboardCard(
          icon: Icons.people,
          title: 'Students',
          subtitle: 'Add, edit and view student records',
        ),
        DashboardCard(
          icon: Icons.badge,
          title: 'Teachers',
          subtitle: 'Manage teachers and assignments',
        ),
        DashboardCard(
          icon: Icons.payments,
          title: 'Fees',
          subtitle: 'Fee structures, payments and outstanding balances',
        ),
        DashboardCard(
          icon: Icons.assignment,
          title: 'Exams & Results',
          subtitle: 'Create exams and manage results',
        ),
        DashboardCard(
          icon: Icons.calendar_month,
          title: 'Attendance',
          subtitle: 'School attendance overview',
        ),
        DashboardCard(
          icon: Icons.schedule,
          title: 'Timetable',
          subtitle: 'Classes and weekly schedules',
        ),
        DashboardCard(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Announcements for your school',
        ),
        DashboardCard(
          icon: Icons.bar_chart,
          title: 'Reports',
          subtitle: 'School reports and summaries',
        ),
      ],
    );
  }
}
