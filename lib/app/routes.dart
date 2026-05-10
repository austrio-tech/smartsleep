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

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String profileCompletion = '/profile-completion';
  static const String home = '/home';
  static const String preSleepEntry = '/pre-sleep';
  static const String postSleepEntry = '/post-sleep';
  static const String sleepReport = '/sleep-report';
  static const String sleepFeedback = '/sleep-feedback';
  static const String history = '/history';
  static const String analytics = '/analytics';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    profileCompletion: (context) => const ProfileCompletionScreen(),
    home: (context) => const MainScreen(),
    preSleepEntry: (context) => const PreSleepEntryScreen(),
    postSleepEntry: (context) => const PostSleepEntryScreen(),
    sleepReport: (context) => const SleepReportScreen(),
    sleepFeedback: (context) => const SleepReportScreen(),
    history: (context) => const SleepHistoryScreen(),
    analytics: (context) => const AnalyticsScreen(),
    profile: (context) => const ProfileScreen(),
  };
}
