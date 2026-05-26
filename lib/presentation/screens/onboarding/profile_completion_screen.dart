import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../app/routes.dart';
import '../../widgets/common/primary_button.dart';
import '../../../data/providers/profile_provider.dart';
import '../../../core/network/api_exception.dart';

class ProfileCompletionScreen extends ConsumerStatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  ConsumerState<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends ConsumerState<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isSubmitting = true);
      final values = _formKey.currentState!.value;
      
      final profileData = {
        'age': int.tryParse(values['age']?.toString() ?? ''),
        'gender': values['gender'],
        'weight_kg': double.tryParse(values['weight_kg']?.toString() ?? ''),
        'height_cm': double.tryParse(values['height_cm']?.toString() ?? ''),
      };

      try {
        await ref.read(profileRepositoryProvider).updateProfile(profileData);
        ref.invalidate(userProfileProvider);
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e is ApiException ? e.message : 'Something went wrong. Please try again.'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personalize your experience',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'These details help us provide accurate sleep analysis and personalized health insights.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: 'age',
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      hintText: 'e.g. 25',
                      prefixIcon: Icon(Icons.cake_outlined, size: 20),
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                      FormBuilderValidators.min(1),
                      FormBuilderValidators.max(120),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  FormBuilderDropdown<String>(
                    name: 'gender',
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                    items: ['Male', 'Female', 'Other']
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'weight_kg',
                          decoration: const InputDecoration(
                            labelText: 'Weight',
                            suffixText: 'kg',
                          ),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                          ]),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'height_cm',
                          decoration: const InputDecoration(
                            labelText: 'Height',
                            suffixText: 'cm',
                          ),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            PrimaryButton(
              text: 'Complete Setup',
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
                child: Text(
                  'Skip for now',
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.secondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
