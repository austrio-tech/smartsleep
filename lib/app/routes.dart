// ─────────────────────────────────────────────────────────────────────────────
// routes.dart  –  Centralised named route definitions.
//
// Instead of scattering route strings throughout the codebase, we define them
// all here as constants. This means:
//   - No typo risk (the compiler checks that the constant exists)
//   - Easy to refactor (change the string in one place)
//   - Clear documentation of every screen the app has
//
// Usage:
//   Navigator.pushNamed(context, AppRoutes.login);
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/signup_screen.dart';
import '../presentation/screens/onboarding/profile_completion_screen.dart';
import '../presentation/screens/main_screen.dart';
import '../presentation/screens/data_entry/pre_sleep_entry_screen.dart';
import '../presentation/screens/data_entry/post_sleep_entry_screen.dart';
import '../presentation/screens/results/sleep_report_screen.dart';
import '../presentation/screens/results/feedback_screen.dart';
import '../presentation/screens/history/sleep_history_screen.dart';
import '../presentation/screens/analytics/analytics_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';

/// Central registry of all named routes in the SmartSleep app.
///
/// Named routes let us navigate with strings instead of widget constructors:
///   Navigator.pushNamed(context, AppRoutes.home)  ← clean
///   Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()))  ← verbose
class AppRoutes {
  // Route name constants — these are the URL-like path strings used for navigation.
  // The leading '/' is a Flutter convention for named routes.
  static const String splash          = '/splash';
  static const String login           = '/login';
  static const String signup          = '/signup';
  static const String profileCompletion = '/profile-completion'; // Onboarding after signup
  static const String home            = '/home';     // Main screen (bottom nav)
  static const String preSleepEntry   = '/pre-sleep';  // Evening habits form
  static const String postSleepEntry  = '/post-sleep'; // Morning sleep data form
  static const String sleepReport     = '/sleep-report';  // Analysis results
  static const String sleepFeedback   = '/sleep-feedback'; // User rating screen
  static const String history         = '/history';     // Sleep log history list
  static const String analytics       = '/analytics';   // Charts and trends
  static const String profile         = '/profile';     // Profile editor

  /// Returns a Map of route names → builder functions.
  ///
  /// This map is passed to MaterialApp.routes. When Navigator.pushNamed()
  /// is called, Flutter looks up the name in this map and builds the widget.
  ///
  /// `get` makes this a computed getter — the map is created fresh each call.
  static Map<String, WidgetBuilder> get routes => {
    splash:            (context) => const SplashScreen(),
    login:             (context) => const LoginScreen(),
    signup:            (context) => const SignupScreen(),
    profileCompletion: (context) => const ProfileCompletionScreen(),
    home:              (context) => const MainScreen(),
    preSleepEntry:     (context) => const PreSleepEntryScreen(),
    postSleepEntry:    (context) => const PostSleepEntryScreen(),
    sleepReport:       (context) => const SleepReportScreen(),
    sleepFeedback:     (context) => const SleepReportScreen(), // Reuses the report screen
    history:           (context) => const SleepHistoryScreen(),
    analytics:         (context) => const AnalyticsScreen(),
    profile:           (context) => const ProfileScreen(),
  };
}
