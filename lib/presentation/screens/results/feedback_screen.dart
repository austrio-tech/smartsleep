import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartsleep/presentation/widgets/common/primary_button.dart';
import 'package:smartsleep/app/routes.dart';
import 'package:smartsleep/data/providers/analysis_provider.dart';
import 'package:smartsleep/data/providers/sleep_data_provider.dart';
import 'package:smartsleep/core/network/api_exception.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  double _userScore = 70;
  bool _isSubmitting = false;

  String get _classification {
    if (_userScore >= 85) return 'Excellent';
    if (_userScore >= 70) return 'Good';
    if (_userScore >= 50) return 'Fair';
    return 'Poor';
  }

  Color get _scoreColor {
    if (_userScore >= 85) return const Color(0xFF16A34A);
    if (_userScore >= 70) return const Color(0xFF3B82F6);
    if (_userScore >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(analysisRepositoryProvider).submitFeedback(_userScore, _classification);
      // Refresh history to update personalization stage on Home
      ref.invalidate(sleepHistoryProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback received! Your AI model is learning.')),
        );
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
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
      appBar: AppBar(title: const Text('Sleep Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'How did last night\'s sleep actually feel?',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your subjective rating helps personalize your AI scores.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Center(
              child: Column(
                children: [
                  Text(
                    _userScore.toInt().toString(),
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 100,
                      color: _scoreColor,
                    ),
                  ),
                  Text(
                    _classification.toUpperCase(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: _scoreColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: _scoreColor,
                thumbColor: _scoreColor,
                overlayColor: _scoreColor.withValues(alpha: 0.2),
                valueIndicatorColor: _scoreColor,
              ),
              child: Slider(
                value: _userScore,
                min: 0,
                max: 100,
                divisions: 100,
                label: _userScore.toInt().toString(),
                onChanged: (value) => setState(() => _userScore = value),
              ),
            ),
            const SizedBox(height: 48),
            PrimaryButton(
              text: 'Submit Feedback',
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
