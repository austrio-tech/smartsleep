// ─────────────────────────────────────────────────────────────────────────────
// signup_screen.dart  –  New user registration form.
//
// Collects: name, email, age, gender, password, confirm password.
// Client-side validation: field formats, password length, password match.
// On success: navigates to the login screen (the user must sign in after registering).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../app/routes.dart';
import '../../widgets/common/primary_button.dart';

/// Registration screen for new SmartSleep users.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  // Track password visibility state — toggled by the eye icon button
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;

  /// Called when the user taps "Sign Up".
  ///
  /// Validates the form, checks passwords match, strips UI-only fields (confirm_password),
  /// then calls the auth provider's signup method.
  void _signup() async {
    // Return early if any validation fails
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    // Get a mutable copy of form values
    final values = Map<String, dynamic>.from(_formKey.currentState!.value);

    // Passwords must match — this can't be done with a standard validator
    // because the validator for one field doesn't have access to another field.
    if (values['password'] != values['confirm_password']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Build the API payload — only include fields the backend expects.
    // `confirm_password` is a UI-only field; the API doesn't need it.
    final payload = {
      'email':     values['email'],
      'password':  values['password'],
      'full_name': values['full_name'],
      // Only include age if the user actually typed something
      if (values['age'] != null && values['age'].toString().isNotEmpty)
        'age': int.tryParse(values['age'].toString()),
      if (values['gender'] != null) 'gender': values['gender'],
    };

    // Trigger signup via the auth provider
    await ref.read(authStateProvider.notifier).signup(payload);

    final authState = ref.read(authStateProvider);
    if (!mounted) return; // Guard against calling setState after dispose

    if (authState.errorMessage != null) {
      // Signup failed (e.g., email already in use)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.errorMessage!),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      // Signup succeeded — redirect to login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created! Please sign in.'),
          backgroundColor: const Color(0xFF16A34A), // Success green
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context), // Go back to login screen
        ),
        title: const Text('Create Account',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Image.asset('lib/SmartSleepLogo.png', height: 80)),
              const SizedBox(height: 28),

              FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    // Full name field
                    FormBuilderTextField(
                      name: 'full_name',
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'e.g. John Doe',
                        prefixIcon: Icon(Icons.person_outline_rounded, size: 22),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(2),
                      ]),
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words, // Auto-capitalise first letter
                    ),
                    const SizedBox(height: 16),

                    // Email field
                    FormBuilderTextField(
                      name: 'email',
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'e.g. name@example.com',
                        prefixIcon: Icon(Icons.email_outlined, size: 22),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(),
                      ]),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Age and gender side by side
                    Row(
                      children: [
                        Expanded(
                          child: FormBuilderTextField(
                            name: 'age',
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              hintText: '25',
                              prefixIcon: Icon(Icons.cake_outlined, size: 22),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FormBuilderDropdown<String>(
                            name: 'gender',
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              prefixIcon: Icon(Icons.people_outline_rounded, size: 22),
                            ),
                            items: ['Male', 'Female', 'Other']
                                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Password field with toggle visibility button
                    FormBuilderTextField(
                      name: 'password',
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Min. 8 characters',
                        prefixIcon: const Icon(Icons.lock_outline, size: 22),
                        // Eye icon button toggles password visibility
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(8),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // Confirm password field (UI-only — not sent to API)
                    FormBuilderTextField(
                      name: 'confirm_password',
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter password',
                        prefixIcon: const Icon(Icons.lock_outline, size: 22),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: FormBuilderValidators.required(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit button — shows loading spinner during API call
              PrimaryButton(
                text: 'Sign Up',
                isLoading: authState.status == AuthStatus.authenticating,
                onPressed: _signup,
              ),
              const SizedBox(height: 24),

              // Link back to login screen for existing users
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: theme.textTheme.bodyMedium),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Terms and privacy policy notice
              Center(
                child: Text(
                  'By signing up, you agree to our Terms of Service\nand Privacy Policy.',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
