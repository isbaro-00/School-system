import 'package:flutter/material.dart';

import '../features/authentication/account_type_screen.dart';
import '../features/authentication/login_screen.dart';
import '../features/home/dashboard_placeholder.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/splash/splash_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const accountType = '/account-type';
  static const login = '/login';
  static const dashboard = '/dashboard';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        welcome: (_) => const WelcomeScreen(),
        accountType: (_) => const AccountTypeScreen(),
        login: (_) => const LoginScreen(),
        dashboard: (_) => const DashboardPlaceholder(),
      };
}
