import 'package:flutter/material.dart';
import '../presentation/home_dashboard/home_dashboard.dart';
import '../presentation/interactive_map_screen/interactive_map_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/hazard_reporting_screen/hazard_reporting_screen.dart';
import '../presentation/analytics_dashboard_screen/analytics_dashboard_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String homeDashboard = '/home-dashboard';
  static const String interactiveMap = '/interactive-map-screen';
  static const String login = '/login-screen';
  static const String hazardReporting = '/hazard-reporting-screen';
  static const String analyticsDashboard = '/analytics-dashboard-screen';
  static const String registration = '/registration-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    homeDashboard: (context) => const HomeDashboard(),
    interactiveMap: (context) => const InteractiveMapScreen(),
    login: (context) => const LoginScreen(),
    hazardReporting: (context) => const HazardReportingScreen(),
    analyticsDashboard: (context) => const AnalyticsDashboardScreen(),
    registration: (context) => const RegistrationScreen(),
    // TODO: Add your other routes here
  };
}
