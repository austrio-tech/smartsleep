// ─────────────────────────────────────────────────────────────────────────────
// main.dart  –  App entry point and root widget.
//
// This file does three things:
//   1. Bootstraps the Flutter framework (main() function).
//   2. Wraps the whole app in a ProviderScope (required by Riverpod).
//   3. Watches authentication state and navigates to the correct screen.
//
// Riverpod is a state management library. Think of "providers" as
// global variables with superpowers — they can be watched, invalidated,
// and automatically rebuilt when their value changes.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/routes.dart';
import 'app/theme.dart';
import 'core/network/api_client.dart';
import 'data/providers/auth_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/auth/login_screen.dart';

// A GlobalKey gives us a reference to the Navigator from anywhere in the app.
// We need this to imperatively push routes (navigate) without a BuildContext.
// `final` here means this variable is set once and never reassigned.
final _navigatorKey = GlobalKey<NavigatorState>();

/// The app entry point — Flutter calls main() when the app starts.
void main() {
  // Ensure Flutter's widget binding is initialised before doing anything else.
  // This is required if you use any Flutter services (like secure storage) before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // ProviderScope is a Riverpod requirement. It creates the container that
    // holds all provider state. The entire app must be wrapped in this.
    const ProviderScope(
      child: SmartSleepApp(),
    ),
  );
}

/// Root widget of the SmartSleep application.
///
/// Uses ConsumerWidget (from Riverpod) instead of plain StatelessWidget
/// so it can watch providers and rebuild when they change.
class SmartSleepApp extends ConsumerWidget {
  const SmartSleepApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the auth state — this widget rebuilds whenever the auth status changes.
    // `ref.watch` is like subscribing to a stream.
    final authState = ref.watch(authStateProvider);

    // Wire the 401 "session expired" callback defined in api_client.dart.
    // When the HTTP client receives a 401, it calls this function to log the user out.
    // We set it here (rather than in api_client.dart) to avoid a circular dependency
    // between the API client and the auth provider.
    onSessionExpiredCallback = () => ref.read(authStateProvider.notifier).logout();

    // Listen to auth state transitions and imperatively navigate the stack.
    // We use ref.listen (not ref.watch) because we want a side effect, not a rebuild.
    // Changing MaterialApp.home doesn't flush existing routes, so we must do it manually.
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      // Ignore if the status hasn't actually changed (e.g., just errorMessage updated)
      if (previous?.status == next.status) return;

      if (next.status == AuthStatus.unauthenticated) {
        // Navigate to login and remove ALL previous routes from the stack
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false, // Remove every route below
        );
      } else if (next.status == AuthStatus.authenticated) {
        // Navigate to home and remove ALL previous routes (clear login stack)
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
      }
    });

    return MaterialApp(
      navigatorKey: _navigatorKey,  // Give the app our stable navigator key
      title: 'SmartSleep',
      debugShowCheckedModeBanner: false, // Hide the "DEBUG" banner in the corner
      theme: AppTheme.lightTheme,        // Apply our custom theme (from theme.dart)
      home: _getHome(authState.status),  // Initial screen based on auth state
      routes: AppRoutes.routes,          // Named route map (from routes.dart)
    );
  }

  /// Determine the initial home screen based on the current authentication status.
  Widget _getHome(AuthStatus status) {
    switch (status) {
      case AuthStatus.initial:
        // App just launched — show the splash screen while checking for a stored token
        return const SplashScreen();
      case AuthStatus.authenticated:
        // Valid token found or login succeeded — go to the main app
        return const MainScreen();
      case AuthStatus.unauthenticated:
      case AuthStatus.authenticating:
      default:
        // No token or login in progress — show the login screen
        return const LoginScreen();
    }
  }
}
