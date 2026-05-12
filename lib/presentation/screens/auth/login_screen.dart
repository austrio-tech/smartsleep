// ─────────────────────────────────────────────────────────────────────────────
// login_screen.dart  –  Email and password login form.
//
// Uses flutter_form_builder for declarative form management and validation.
// FormBuilder automatically:
//   - Tracks field values
//   - Runs validators when saveAndValidate() is called
//   - Collects all form values into a Map
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../app/routes.dart';
import '../../widgets/common/primary_button.dart';

/// The login screen where existing users enter their credentials.
///
/// Uses [ConsumerStatefulWidget] so it can:
/// - Watch [authStateProvider] to show the loading spinner during login
/// - Call [authStateProvider.notifier].login() to trigger authentication
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // GlobalKey gives us programmatic access to the form (to call saveAndValidate())
  final _formKey = GlobalKey<FormBuilderState>();

  /// Called when the user taps "Sign In".
  ///
  /// 1. Validates all form fields (required, email format, min length)
  /// 2. If valid, calls the auth notifier's login() method
  /// 3. Shows a SnackBar if login fails
  void _login() async {
    // saveAndValidate() runs all validators and saves field values to the form state.
    // Returns false if any validator fails.
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      // `value` is a Map<String, dynamic> with field names as keys
      final values = _formKey.currentState!.value;

      // Trigger the login action in the auth provider
      await ref.read(authStateProvider.notifier).login(
        values['email'],
        values['password'],
      );

      // After login attempt, check the outcome
      final authState = ref.read(authStateProvider);
      if (authState.status == AuthStatus.authenticated) {
        // Login succeeded — navigate to home (removes login from stack)
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else if (authState.errorMessage != null) {
        // Login failed — show the error in a floating snack bar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.errorMessage!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state — widget rebuilds when status changes (e.g., authenticating → unauthenticated)
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        // SingleChildScrollView prevents overflow when the keyboard opens
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // App logo at the top
              Center(
                child: Image.asset('lib/SmartSleepLogo.png', height: 120),
              ),
              const SizedBox(height: 48),

              // Title and subtitle
              Text('Welcome Back', style: theme.textTheme.displayMedium, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                'Sign in to continue your journey towards better rest and recovery.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Form with email and password fields
              FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    // Email field with format validation
                    FormBuilderTextField(
                      name: 'email', // Key used to access value in form state
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'e.g. name@example.com',
                        prefixIcon: Icon(Icons.email_outlined, size: 22),
                      ),
                      // compose() runs validators in sequence — both must pass
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(),
                      ]),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),

                    // Password field — hidden characters with obscureText
                    FormBuilderTextField(
                      name: 'password',
                      obscureText: true, // Hides characters as dots
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: '••••••••',
                        prefixIcon: Icon(Icons.lock_outline, size: 22),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(8),
                      ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Forgot password link (currently navigates nowhere — placeholder)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 32),

              // Submit button — shows spinner while login is in progress
              PrimaryButton(
                text: 'Sign In',
                isLoading: authState.status == AuthStatus.authenticating,
                onPressed: _login,
              ),
              const SizedBox(height: 40),

              // Link to signup screen for new users
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('New to SmartSleep? ', style: theme.textTheme.bodyMedium),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Create Account'),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
