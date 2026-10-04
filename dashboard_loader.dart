
import 'package:flutter/material.dart';
import '../../core/services/session_service.dart';
import 'dashboard_router.dart';

class DashboardLoader extends StatelessWidget {
  const DashboardLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SessionService.currentAppUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text('Your account profile could not be loaded.'),
            ),
          );
        }

        return DashboardRouter(user: user);
      },
    );
  }
}
