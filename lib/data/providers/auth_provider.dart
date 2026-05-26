// ─────────────────────────────────────────────────────────────────────────────
// auth_provider.dart  –  Authentication state management using Riverpod.
//
// This file defines:
//   1. AuthStatus enum      — the four possible authentication states
//   2. AuthState class      — holds the current status and any error message
//   3. AuthNotifier class   — the state machine that handles login/logout/signup
//   4. authStateProvider    — the Riverpod provider that exposes AuthNotifier
//
// Riverpod StateNotifierProvider is like a ChangeNotifier with a typed state.
// Any widget that calls `ref.watch(authStateProvider)` will rebuild whenever
// the authentication status changes.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../../core/network/api_exception.dart';
import 'api_provider.dart';

/// Provides an [AuthRepository] instance to the app.
///
/// This is a simple Provider (not a StateNotifier) — it just creates and
/// returns the object, making it available to other providers and widgets.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Watch both sub-providers. If either changes, this provider rebuilds too.
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(apiClient, storage);
});

/// The four possible authentication states the app can be in.
enum AuthStatus {
  initial,         // App just launched — checking for a stored token
  authenticated,   // User is logged in and has a valid token
  unauthenticated, // User is logged out or has no token
  authenticating,  // Login or signup request is in progress
}

/// Immutable snapshot of the current authentication state.
///
/// Immutable means once created, the object cannot be changed.
/// Instead of mutating, we create a new AuthState and set it as the new state.
class AuthState {
  final AuthStatus status;
  final String? errorMessage; // Set when login fails, null otherwise

  AuthState({required this.status, this.errorMessage});

  // Named constructors for convenient creation of common states
  factory AuthState.initial()         => AuthState(status: AuthStatus.initial);
  factory AuthState.unauthenticated() => AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.authenticated()   => AuthState(status: AuthStatus.authenticated);
  factory AuthState.authenticating()  => AuthState(status: AuthStatus.authenticating);
}

/// State machine that manages user authentication.
///
/// StateNotifier is the Riverpod class for managing state with side effects.
/// It holds an [AuthState] and provides methods to change it.
/// The `state =` setter automatically notifies all listeners.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  /// Initialises with the [AuthStatus.initial] state and immediately
  /// checks if the user is already logged in (has a stored token).
  AuthNotifier(this._repository) : super(AuthState.initial()) {
    _checkAuthStatus();
  }

  /// Checks for a stored JWT token to determine if the user is already logged in.
  ///
  /// Called automatically when the app starts. The 2-second delay ensures
  /// the splash screen (logo animation) has time to complete.
  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash screen visibility
    final isLoggedIn = await _repository.isLoggedIn();
    if (isLoggedIn) {
      state = AuthState.authenticated();
    } else {
      state = AuthState.unauthenticated();
    }
  }

  /// Attempts to log in with the given credentials.
  ///
  /// Sets state to [AuthStatus.authenticating] immediately (shows loading spinner),
  /// then transitions to [AuthStatus.authenticated] on success or back to
  /// [AuthStatus.unauthenticated] with an error message on failure.
  Future<void> login(String email, String password) async {
    state = AuthState.authenticating(); // Show loading indicator
    try {
      await _repository.login(email, password);
      state = AuthState.authenticated(); // Success → go to home
    } catch (e) {
      // Store the error message so the UI can display it in a SnackBar
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e is ApiException ? e.message : 'Something went wrong. Please try again.',
      );
    }
  }

  /// Attempts to create a new account with the provided user data.
  ///
  /// After signup, the user is transitioned to [AuthStatus.unauthenticated]
  /// rather than authenticated — they must log in with their new credentials.
  Future<void> signup(Map<String, dynamic> userData) async {
    state = AuthState.authenticating();
    try {
      await _repository.signup(userData);
      state = AuthState.unauthenticated(); // Redirect to login after signup
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e is ApiException ? e.message : 'Something went wrong. Please try again.',
      );
    }
  }

  /// Logs out the current user by clearing the stored token.
  Future<void> logout() async {
    await _repository.logout(); // Deletes token from secure storage
    state = AuthState.unauthenticated();
  }
}

/// The global Riverpod provider for authentication state.
///
/// Any widget can watch this provider:
///   final authState = ref.watch(authStateProvider);
///   final notifier = ref.read(authStateProvider.notifier);
///
/// `ref.watch` returns the current [AuthState] and rebuilds the widget on change.
/// `ref.read(...notifier)` returns the [AuthNotifier] for calling login/logout.
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
