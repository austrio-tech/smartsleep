import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/routes.dart';
import 'app/theme.dart';
import 'core/network/api_client.dart';
import 'data/providers/auth_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/auth/login_screen.dart';

// Persists across rebuilds so the navigator reference stays stable.
final _navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: SmartSleepApp(),
    ),
  );
}

class SmartSleepApp extends ConsumerWidget {
  const SmartSleepApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // Wire 401 session-expiry callback to logout (avoids circular provider deps)
    onSessionExpiredCallback = () => ref.read(authStateProvider.notifier).logout();

    // Listen for auth transitions and imperatively clear the nav stack.
    // This is necessary because changing MaterialApp.home does NOT flush
    // routes that were already pushed onto the Navigator.
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (previous?.status == next.status) return;

      if (next.status == AuthStatus.unauthenticated) {
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      } else if (next.status == AuthStatus.authenticated) {
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
      }
    });

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'SmartSleep',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _getHome(authState.status),
      routes: AppRoutes.routes,
    );
  }

  Widget _getHome(AuthStatus status) {
    switch (status) {
      case AuthStatus.initial:
        return const SplashScreen();
      case AuthStatus.authenticated:
        return const MainScreen();
      case AuthStatus.unauthenticated:
      case AuthStatus.authenticating:
      default:
        return const LoginScreen();
    }
  }
}
