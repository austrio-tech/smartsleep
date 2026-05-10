import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:smartsleep/app/routes.dart';
import 'package:smartsleep/presentation/widgets/common/primary_button.dart';
import 'package:smartsleep/data/providers/sleep_data_provider.dart';
import 'package:smartsleep/data/providers/analysis_provider.dart';

class PostSleepEntryScreen extends ConsumerStatefulWidget {
  const PostSleepEntryScreen({super.key});

  @override
  ConsumerState<PostSleepEntryScreen> createState() => _PostSleepEntryScreenState();
}

class _PostSleepEntryScreenState extends ConsumerState<PostSleepEntryScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stage = ref.read(loggingStageProvider);
      if (stage != LoggingStage.waitingForPostSleep) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log your evening habits first.')),
        );
        Navigator.pop(context);
      }
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final values = _formKey.currentState!.value;
    final activeRecord = ref.read(activeSleepRecordProvider);

    if (activeRecord == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    final data = {
      'phase': 'post',
      'record_date': activeRecord.date,
      'sleep_time': values['sleep_time'] != null
          ? DateFormat('HH:mm:ss').format(values['sleep_time'] as DateTime)
          : null,
      'wake_time': values['wake_time'] != null
          ? DateFormat('HH:mm:ss').format(values['wake_time'] as DateTime)
          : null,
      'sleep_latency_minutes':
          int.tryParse(values['sleep_latency_minutes']?.toString() ?? '0') ?? 0,
      'awakenings': int.tryParse(values['awakenings']?.toString() ?? '0') ?? 0,
      'naps': int.tryParse(values['naps']?.toString() ?? '0') ?? 0,
      'hr_rest': int.tryParse(values['hr_rest']?.toString() ?? '') ,
      'hrv': int.tryParse(values['hrv']?.toString() ?? ''),
      'body_temp': double.tryParse(values['body_temp']?.toString() ?? ''),
      'resp_rate': int.tryParse(values['resp_rate']?.toString() ?? ''),
      'mood': (values['mood'] as double?)?.toInt() ?? 5,
      'room_temp': (values['room_temp'] as double?),
      'noise_db': (values['noise_db'] as double?)?.toInt(),
      'light_lux': (values['light_lux'] as double?)?.toInt(),
    };

    // Strip nulls so backend doesn't try to set optional fields to null
    data.removeWhere((_, v) => v == null);

    try {
      await ref.read(sleepDataRepositoryProvider).submitRawSleepData(data);
      ref.invalidate(sleepHistoryProvider);
      ref.invalidate(latestAnalysisProvider);
      ref.invalidate(recommendationsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Morning data saved! Generating analysis...')),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.sleepReport);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
      appBar: AppBar(
        title: const Text('Morning Check-in'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How was your sleep?', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Logging your sleep metrics helps us refine your recovery insights.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              _FormSection(
                title: 'Sleep Timing',
                icon: Icons.access_time_rounded,
                children: [
                  FormBuilderDateTimePicker(
                    name: 'sleep_time',
                    inputType: InputType.time,
                    decoration: const InputDecoration(
                      labelText: 'Went to Bed',
                      prefixIcon: Icon(Icons.bedtime_outlined, size: 20),
                    ),
                    format: DateFormat('HH:mm'),
                  ),
                  const SizedBox(height: 20),
                  FormBuilderDateTimePicker(
                    name: 'wake_time',
                    inputType: InputType.time,
                    decoration: const InputDecoration(
                      labelText: 'Woke Up',
                      prefixIcon: Icon(Icons.wb_sunny_outlined, size: 20),
                    ),
                    format: DateFormat('HH:mm'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'sleep_latency_minutes',
                          decoration: const InputDecoration(
                            labelText: 'Time to fall asleep',
                            suffixText: 'min',
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: '10',
                          validator: FormBuilderValidators.integer(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'awakenings',
                          decoration: const InputDecoration(
                            labelText: 'Awakenings',
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: '0',
                          validator: FormBuilderValidators.integer(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FormBuilderTextField(
                    name: 'naps',
                    decoration: const InputDecoration(
                      labelText: 'Naps yesterday',
                      suffixText: 'naps',
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: '0',
                    validator: FormBuilderValidators.integer(),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _FormSection(
                title: 'Biometrics',
                icon: Icons.monitor_heart_outlined,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'hr_rest',
                          decoration: const InputDecoration(
                            labelText: 'Resting HR',
                            suffixText: 'bpm',
                          ),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.integer(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'hrv',
                          decoration: const InputDecoration(
                            labelText: 'HRV',
                            suffixText: 'ms',
                          ),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.integer(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'body_temp',
                          decoration: const InputDecoration(
                            labelText: 'Body Temp',
                            suffixText: '°C',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: FormBuilderValidators.numeric(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'resp_rate',
                          decoration: const InputDecoration(
                            labelText: 'Resp. Rate',
                            suffixText: '/min',
                          ),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.integer(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _FormSection(
                title: 'Mood',
                icon: Icons.mood_rounded,
                children: [
                  Text('Morning mood', style: theme.textTheme.labelLarge),
                  FormBuilderSlider(
                    name: 'mood',
                    initialValue: 7.0,
                    min: 1.0,
                    max: 10.0,
                    divisions: 9,
                    activeColor: Colors.blue,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _FormSection(
                title: 'Bedroom Environment',
                icon: Icons.home_work_outlined,
                children: [
                  Text('Room temperature', style: theme.textTheme.labelLarge),
                  FormBuilderSlider(
                    name: 'room_temp',
                    initialValue: 20.0,
                    min: 10.0,
                    max: 35.0,
                    divisions: 50,
                    numberFormat: NumberFormat('##.#'),
                    activeColor: theme.colorScheme.secondary,
                    decoration: const InputDecoration(
                      suffixText: '°C',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Noise level', style: theme.textTheme.labelLarge),
                  FormBuilderSlider(
                    name: 'noise_db',
                    initialValue: 30.0,
                    min: 30.0,
                    max: 100.0,
                    divisions: 70,
                    numberFormat: NumberFormat('###'),
                    activeColor: theme.colorScheme.primary,
                    decoration: const InputDecoration(
                      suffixText: 'dB',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Light level', style: theme.textTheme.labelLarge),
                  FormBuilderSlider(
                    name: 'light_lux',
                    initialValue: 5.0,
                    min: 0.0,
                    max: 300.0,
                    divisions: 60,
                    numberFormat: NumberFormat('###'),
                    activeColor: Colors.amber,
                    decoration: const InputDecoration(
                      suffixText: 'lux',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),
              PrimaryButton(
                text: 'Generate Sleep Analysis',
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

class _FormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _FormSection({
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
