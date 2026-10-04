
import 'package:flutter/material.dart';
import '../../core/models/app_user.dart';
import 'base_dashboard.dart';
import 'dashboard_card.dart';

class ParentDashboard extends StatelessWidget {
  final AppUser user;

  const ParentDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BaseDashboard(
      user: user,
      title: 'Parent Dashboard',
      subtitle: 'Monitor your children’s school information.',
      cards: [
        DashboardCard(
          icon: Icons.child_care,
          title: 'My Children',
          subtitle: 'Switch between your registered children',
        ),
        DashboardCard(
          icon: Icons.payments,
          title: 'Fees',
          subtitle: 'View fees and payment status',
        ),
        DashboardCard(
          icon: Icons.grade,
          title: 'Results',
          subtitle: 'View your children’s results',
        ),
        DashboardCard(
          icon: Icons.fact_check,
          title: 'Attendance',
          subtitle: 'Monitor attendance',
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
