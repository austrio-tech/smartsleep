import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/profile_provider.dart';
import '../../../data/models/user.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/providers/api_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSaving = false;
  bool _isResetting = false;
  bool _isResending = false;
  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Auto-refresh profile when the user returns to the app (e.g. after
  /// clicking the confirmation link in their email browser).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(userProfileProvider);
    }
  }

  Future<void> _save(User user) async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    setState(() => _isSaving = true);

    final values = _formKey.currentState!.value;
    final payload = <String, dynamic>{};
    if ((values['full_name'] ?? '').toString().isNotEmpty &&
        values['full_name'] != user.fullName) {
      payload['full_name'] = values['full_name'];
    }
    if (values['age'] != null && values['age'].toString().isNotEmpty) {
      final age = int.tryParse(values['age'].toString());
      if (age != user.age) payload['age'] = age;
    }
    if (values['gender'] != null && values['gender'] != user.gender) {
      payload['gender'] = values['gender'];
    }
    if (values['weight_kg'] != null && values['weight_kg'].toString().isNotEmpty) {
      final w = double.tryParse(values['weight_kg'].toString());
      if (w != user.weightKg) payload['weight_kg'] = w;
    }
    if (values['height_cm'] != null && values['height_cm'].toString().isNotEmpty) {
      final h = double.tryParse(values['height_cm'].toString());
      if (h != user.heightCm) payload['height_cm'] = h;
    }

    if (payload.isEmpty) {
      setState(() { _isSaving = false; _editMode = false; });
      return;
    }

    try {
      await ref.read(profileRepositoryProvider).updateProfile(payload);
      ref.invalidate(userProfileProvider);
      if (mounted) {
        setState(() => _editMode = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated! A confirmation email has been sent.'),
            backgroundColor: Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException ? e.message : 'Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _resendConfirmation() async {
    setState(() => _isResending = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.post(ApiConstants.resendConfirmation);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Confirmation email sent! Check your inbox.'),
            backgroundColor: Color(0xFF6366F1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException ? e.message : 'Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _resetPassword(String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Password'),
        content: Text(
          'A new random password will be generated and sent to\n$email\n\nYou can change it after logging in.',
          style: const TextStyle(color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B3A6B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Send Reset Email', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isResetting = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.post(ApiConstants.resetPassword, data: {'email': email});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent! Check your inbox.'),
            backgroundColor: Color(0xFF6366F1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException ? e.message : 'Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  /// Opens the Change Password dialog (a proper StatefulWidget).
  ///
  /// The dialog owns its own controllers and state, so pressing Back
  /// disposes them cleanly without crashing the parent screen.
  Future<void> _showChangePasswordDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ChangePasswordDialog(
        onSubmit: (currentPwd, newPwd) async {
          final apiClient = ref.read(apiClientProvider);
          await apiClient.post(
            ApiConstants.changePassword,
            data: {
              'current_password': currentPwd,
              'new_password': newPwd,
            },
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password changed successfully!'),
                backgroundColor: Color(0xFF16A34A),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (!_editMode)
            TextButton.icon(
              onPressed: () => setState(() => _editMode = true),
              icon: const Icon(Icons.edit_rounded, color: Colors.white70, size: 18),
              label: const Text('Edit', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
            )
          else
            TextButton(
              onPressed: () => setState(() => _editMode = false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: profileAsync.when(
        data: (user) => _buildBody(context, theme, user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(e is ApiException ? e.message : 'Failed to load profile. Please try again.'),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, User user) {
    final initials = _initials(user);
    final isVerified = user.emailConfirmed == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Avatar ────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        initials,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isVerified ? const Color(0xFF16A34A) : const Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          isVerified ? Icons.verified_rounded : Icons.warning_amber_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  user.fullName ?? user.email.split('@').first,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(user.email, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isVerified ? const Color(0xFF16A34A).withOpacity(0.1) : const Color(0xFFF59E0B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isVerified ? 'Verified' : 'Unverified',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isVerified ? const Color(0xFF16A34A) : const Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isVerified) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309), size: 16),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Your email is not verified yet.',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isResending ? null : _resendConfirmation,
                                icon: _isResending
                                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.send_rounded, size: 14),
                                label: const Text('Resend Email', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFB45309),
                                  side: const BorderSide(color: Color(0xFFF59E0B)),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => ref.invalidate(userProfileProvider),
                                icon: const Icon(Icons.refresh_rounded, size: 14),
                                label: const Text('Refresh Status', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1B3A6B),
                                  side: const BorderSide(color: Color(0xFF1B3A6B)),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Profile Form ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: FormBuilder(
              key: _formKey,
              enabled: _editMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('Personal Information'),
                  const SizedBox(height: 14),
                  FormBuilderTextField(
                    name: 'full_name',
                    initialValue: user.fullName ?? '',
                    decoration: _deco('Full Name', Icons.person_outline_rounded),
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'age',
                        initialValue: user.age?.toString() ?? '',
                        decoration: _deco('Age', Icons.cake_outlined),
                        keyboardType: TextInputType.number,
                        validator: FormBuilderValidators.integer(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FormBuilderDropdown<String>(
                        name: 'gender',
                        initialValue: user.gender,
                        decoration: _deco('Gender', Icons.people_outline_rounded),
                        items: ['Male', 'Female', 'Other']
                            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _SectionLabel('Body Metrics'),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'weight_kg',
                        initialValue: user.weightKg?.toString() ?? '',
                        decoration: _deco('Weight', Icons.monitor_weight_outlined, suffix: 'kg'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: FormBuilderValidators.numeric(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'height_cm',
                        initialValue: user.heightCm?.toString() ?? '',
                        decoration: _deco('Height', Icons.height_rounded, suffix: 'cm'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: FormBuilderValidators.numeric(),
                      ),
                    ),
                  ]),
                  if (_editMode) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : () => _save(user),
                        icon: _isSaving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save_rounded, size: 20),
                        label: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Security ─────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel('Security'),
                const SizedBox(height: 16),

                // ── Change Password (knows current password) ───────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isResetting ? null : _showChangePasswordDialog,
                    icon: const Icon(Icons.lock_open_rounded, size: 20),
                    label: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Reset Password via Email (forgot password) ─────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isResetting ? null : () => _resetPassword(user.email),
                    icon: _isResetting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.lock_reset_rounded, size: 20),
                    label: const Text('Forgot Password? Reset via Email', style: TextStyle(fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: const Color(0xFF6366F1),
                      side: const BorderSide(color: Color(0xFF6366F1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Use "Change Password" if you know your current password. Use "Forgot Password" if you need a new one sent to your email.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Account Info ─────────────────────────────────────────────────
          if (user.createdAt != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 10),
                  Text('Member since ${_formatDate(user.createdAt!)}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // ── Logout ────────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => ref.read(authStateProvider.notifier).logout(),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  InputDecoration _deco(String label, IconData icon, {String? suffix}) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20),
    suffixText: suffix,
    filled: true,
    fillColor: _editMode ? Colors.white : const Color(0xFFF8FAFC),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
    disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  String _initials(User user) {
    final name = user.fullName?.trim() ?? '';
    if (name.isEmpty) return user.email.substring(0, 1).toUpperCase();
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].substring(0, 1).toUpperCase();
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return iso.substring(0, 10);
    }
  }
}

/// Change Password dialog extracted as a StatefulWidget so that controllers,
/// visibility toggles, and loading state are owned and disposed by the widget
/// itself — pressing Back dismisses cleanly without a "setState after dispose" crash.
class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog({required this.onSubmit});

  /// Called with (currentPassword, newPassword) when the form is valid and submitted.
  /// Should throw [ApiException] on failure so the dialog can display the message inline.
  final Future<void> Function(String currentPwd, String newPwd) onSubmit;

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isSubmitting = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _isSubmitting = true; _errorMessage = null; });
    try {
      await widget.onSubmit(_currentCtrl.text, _newCtrl.text);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e is ApiException ? e.message : 'Something went wrong. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: Color(0xFF6366F1)),
          SizedBox(width: 8),
          Flexible(child: Text('Change Password')),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 13, color: Color(0xFFB91C1C)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller: _currentCtrl,
                obscureText: _obscureCurrent,
                enabled: !_isSubmitting,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _newCtrl,
                obscureText: _obscureNew,
                enabled: !_isSubmitting,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 8) return 'Minimum 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                enabled: !_isSubmitting,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) => v != _newCtrl.text ? 'Passwords do not match' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isSubmitting
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Change', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Color(0xFF94A3B8),
      letterSpacing: 1.2,
    ),
  );
}
