import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:smartsleep/presentation/widgets/common/primary_button.dart';
import 'package:smartsleep/data/providers/sleep_data_provider.dart';
import 'package:smartsleep/core/network/api_exception.dart';

class PreSleepEntryScreen extends ConsumerStatefulWidget {
  const PreSleepEntryScreen({super.key});

  @override
  ConsumerState<PreSleepEntryScreen> createState() => _PreSleepEntryScreenState();
}

class _PreSleepEntryScreenState extends ConsumerState<PreSleepEntryScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    setState(() => _isSubmitting = true);
    final values = _formKey.currentState!.value;

    final data = {
      'phase': 'pre',
      'record_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'caffeine_time': values['caffeine_time'] != null
          ? DateFormat('HH:mm:ss').format(values['caffeine_time'] as DateTime)
          : null,
      'caffeine_mg': (values['caffeine_mg'] as double?)?.toInt(),
      'alcohol_units': int.tryParse(values['alcohol_units']?.toString() ?? '0') ?? 0,
      'water_liters': double.tryParse(values['water_liters']?.toString() ?? '0') ?? 0.0,
      'steps': int.tryParse(values['steps']?.toString() ?? '0') ?? 0,
      'activity_intensity': values['activity_intensity'],
      'stress': (values['stress'] as double?)?.toInt() ?? 5,
      'screen_minutes_before_bed':
          int.tryParse(values['screen_minutes_before_bed']?.toString() ?? '0') ?? 0,
    };

    try {
      await ref.read(sleepDataRepositoryProvider).submitRawSleepData(data);
      ref.invalidate(sleepHistoryProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evening habits saved!')),
        );
        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Evening Habits')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Journal Your Day', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Log what you did today so we can score your sleep tonight.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              _Section(
                title: 'Caffeine',
                icon: Icons.coffee_rounded,
                children: [
                  FormBuilderDateTimePicker(
                    name: 'caffeine_time',
                    inputType: InputType.time,
                    decoration: const InputDecoration(
                      labelText: 'Last caffeine intake (optional)',
                      prefixIcon: Icon(Icons.access_time_rounded, size: 20),
                    ),
                    format: DateFormat('HH:mm'),
                  ),
                  const SizedBox(height: 20),
                  Text('Caffeine amount', style: theme.textTheme.labelLarge),
                  FormBuilderSlider(
                    name: 'caffeine_mg',
                    initialValue: 0.0,
                    min: 0.0,
                    max: 800.0,
                    divisions: 16,
                    numberFormat: NumberFormat('###'),
                    decoration: const InputDecoration(
                      suffixText: 'mg',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _Section(
                title: 'Activity',
                icon: Icons.directions_run_rounded,
                children: [
                  FormBuilderTextField(
                    name: 'steps',
                    decoration: const InputDecoration(
                      labelText: 'Steps today',
                      suffixText: 'steps',
                      prefixIcon: Icon(Icons.directions_walk_rounded, size: 20),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: '0',
                    validator: FormBuilderValidators.integer(),
                  ),
                  const SizedBox(height: 20),
                  FormBuilderChoiceChip<String>(
                    name: 'activity_intensity',
                    decoration: const InputDecoration(labelText: 'Activity intensity'),
                    options: const [
                      FormBuilderChipOption(value: 'Low', child: Text('Low')),
                      FormBuilderChipOption(value: 'Medium', child: Text('Medium')),
                      FormBuilderChipOption(value: 'High', child: Text('High')),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _Section(
                title: 'Diet & Hydration',
                icon: Icons.local_drink_rounded,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'alcohol_units',
                          decoration: const InputDecoration(
                            labelText: 'Alcohol',
                            suffixText: 'units',
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: '0',
                          validator: FormBuilderValidators.integer(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'water_liters',
                          decoration: const InputDecoration(
                            labelText: 'Water',
                            suffixText: 'L',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          initialValue: '2.0',
                          validator: FormBuilderValidators.numeric(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _Section(
                title: 'Evening Wind-down',
                icon: Icons.nightlight_round,
                children: [
                  FormBuilderTextField(
                    name: 'screen_minutes_before_bed',
                    decoration: const InputDecoration(
                      labelText: 'Screen time before bed',
                      suffixText: 'min',
                      prefixIcon: Icon(Icons.phone_android_rounded, size: 20),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: '30',
                    validator: FormBuilderValidators.integer(),
                  ),
                  const SizedBox(height: 24),
                  Text('Stress level', style: theme.textTheme.labelLarge),
                  FormBuilderSlider(
                    name: 'stress',
                    initialValue: 5.0,
                    min: 1.0,
                    max: 10.0,
                    divisions: 9,
                    activeColor: theme.colorScheme.primary,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),
              PrimaryButton(
                text: 'Save Evening Habits',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                letterSpacing: 1.2,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}
