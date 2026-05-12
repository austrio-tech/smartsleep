// ─────────────────────────────────────────────────────────────────────────────
// validators.dart  –  Reusable form field validators.
//
// We use the `form_builder_validators` package which provides composable
// validator functions. A validator is a function that takes the field's
// current value and returns:
//   - null   if the value is valid (no error)
//   - String if the value is invalid (the error message to show)
//
// These are used with flutter_form_builder's FormBuilderTextField and
// other form fields via their `validator` parameter.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:form_builder_validators/form_builder_validators.dart';

/// Pre-configured form validators for common input fields.
///
/// Usage in a FormBuilderTextField:
///   validator: AppValidators.required
///
/// Composing multiple validators:
///   validator: FormBuilderValidators.compose([
///     AppValidators.required,
///     AppValidators.email,
///   ])
class AppValidators {
  /// Fails validation if the field is empty or whitespace-only.
  static final required = FormBuilderValidators.required();

  /// Fails validation if the input is not a valid email address format.
  /// Example: "notanemail" fails, "user@example.com" passes.
  static final email = FormBuilderValidators.email();

  /// Fails validation if the input is not a valid number (integer or decimal).
  static final numeric = FormBuilderValidators.numeric();

  /// Creates a validator that fails if the input is shorter than [length] characters.
  ///
  /// Example: AppValidators.minLength(8) ensures passwords are at least 8 chars.
  static minLength(int length) => FormBuilderValidators.minLength(length);

  /// Creates a validator that fails if the numeric input is less than [value].
  ///
  /// Example: AppValidators.min(0) ensures a number is non-negative.
  static min(num value) => FormBuilderValidators.min(value);

  /// Creates a validator that fails if the numeric input is greater than [value].
  ///
  /// Example: AppValidators.max(120) ensures age doesn't exceed 120.
  static max(num value) => FormBuilderValidators.max(value);
}
