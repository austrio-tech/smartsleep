import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/routes.dart';
import '../../widgets/common/primary_button.dart';
import '../../../data/providers/analysis_provider.dart';
import '../../../data/providers/sleep_data_provider.dart';
import '../../../data/models/derived_sleep_data.dart';
import '../../../data/models/recommendation.dart';
import '../../../core/network/api_exception.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

String _formatHours(double hours) {
  final h = hours.toInt();
  final m = ((hours - h) * 60).toInt();
  return '${h}h ${m}m';
}

Color _scoreColor(int score) {
  if (score >= 85) return const Color(0xFF16A34A);
  if (score >= 70) return const Color(0xFF2563EB);
  if (score >= 50) return const Color(0xFFF59E0B);
  return const Color(0xFFEF4444);
}

String _scoreLabel(int score) {
  if (score >= 85) return 'EXCELLENT';
  if (score >= 70) return 'GOOD';
  if (score >= 50) return 'FAIR';
  return 'POOR';
}

IconData _getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'caffeine':
      return Icons.coffee_rounded;
    case 'screen':
    case 'screen time':
      return Icons.phone_android_rounded;
    case 'stress':
    case 'stress & mood':
      return Icons.psychology_rounded;
    case 'environment':
    case 'sleep environment':
      return Icons.home_rounded;
    case 'biological':
    case 'biological readiness':
      return Icons.fitness_center_rounded;
    default:
      return Icons.nights_stay_rounded;
  }
}

Color _getPriorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return const Color(0xFFEF4444);
    case 'medium':
      return const Color(0xFFF59E0B);
    case 'low':
      return const Color(0xFF16A34A);
    default:
      return Colors.grey;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────────────────────

class SleepReportScreen extends ConsumerWidget {
  const SleepReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(latestAnalysisProvider);
    final recommendationsAsync = ref.watch(recommendationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: const Text(
          'Sleep Report',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.home),
        ),
      ),
      body: analysisAsync.when(
        data: (analysis) => _ReportBody(
          analysis: analysis,
          recommendationsAsync: recommendationsAsync,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Error loading report: $err',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Report Body
// ─────────────────────────────────────────────────────────────────────────────

class _ReportBody extends ConsumerWidget {
  const _ReportBody({
    required this.analysis,
    required this.recommendationsAsync,
  });

  final DerivedSleepData analysis;
  final AsyncValue<List<Recommendation>> recommendationsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = analysis.finalScore ?? 0;
    final color = _scoreColor(score);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        // ── Score Gauge ────────────────────────────────────────────────────
        // ── Score Gauge ────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Column(
            children: [
              const Text(
                'Your Sleep Score',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500, letterSpacing: 0.5),
              ),
              const SizedBox(height: 20),
              // Ring gauge — score text is BELOW, not inside, to avoid overlap
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 14,
                  backgroundColor: color.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '$score',
                style: TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: color, height: 1),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _scoreLabel(score),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color, letterSpacing: 2.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Metric Grid ────────────────────────────────────────────────────
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _MetricCard(
              icon: Icons.access_time_rounded,
              value: _formatHours(analysis.tst ?? 0.0),
              label: 'Duration',
            ),
            _MetricCard(
              icon: Icons.bolt_rounded,
              value:
                  '${((analysis.sleepEfficiency ?? 0.0) * 100).toStringAsFixed(0)}%',
              label: 'Efficiency',
            ),
            _MetricCard(
              icon: Icons.calendar_today_outlined,
              value:
                  '${((analysis.consistency7d ?? 0.0) * 100).toStringAsFixed(0)}%',
              label: 'Consistency',
            ),
            _MetricCard(
              icon: Icons.favorite_outline,
              value:
                  '${((analysis.biologicalReady ?? 0.0) * 100).toStringAsFixed(0)}%',
              label: 'Bio-Readiness',
            ),
          ],
        ),
        const SizedBox(height: 28),

        // ── Personalised Insights ──────────────────────────────────────────
        const Text(
          'Personalised Insights',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        recommendationsAsync.when(
          data: (recs) {
            if (recs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No recommendations available yet.',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              );
            }
            return Column(
              children: recs
                  .map((rec) => _RecommendationCard(rec: rec))
                  .toList(),
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text(
            'Could not load insights.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
        const SizedBox(height: 28),

        // ── Feedback Button (only shown when not yet rated) ────────────────
        if (analysis.userScore == null)
          PrimaryButton(
            text: 'Rate Last Night\'s Sleep',
            onPressed: () => _showFeedbackSheet(context, ref),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF16A34A).withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20),
                const SizedBox(width: 10),
                Text(
                  'You rated this sleep ${analysis.userScore!.toInt()}/100',
                  style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.pushReplacementNamed(
              context, AppRoutes.home),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Back to Dashboard'),
        ),
      ],
    );
  }

  void _showFeedbackSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FeedbackSheet(
        onSubmitted: (score, userClass) async {
          await ref
              .read(analysisRepositoryProvider)
              .submitFeedback(score, userClass);
          ref.invalidate(latestAnalysisProvider);
          ref.invalidate(sleepHistoryProvider);
          ref.invalidate(recommendationsProvider);
          if (context.mounted) {
            Navigator.pop(context); // close the sheet first
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Feedback submitted. Thank you!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Metric Card
// ─────────────────────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: theme.colorScheme.primary.withOpacity(0.45),
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recommendation Card
// ─────────────────────────────────────────────────────────────────────────────

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.rec});

  final Recommendation rec;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = _getPriorityColor(rec.priority);
    final categoryIcon = _getCategoryIcon(rec.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(categoryIcon, size: 20, color: priorityColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          rec.category,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: priorityColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: priorityColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          rec.priority.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rec.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feedback Bottom Sheet (StatefulWidget)
// ─────────────────────────────────────────────────────────────────────────────

typedef _FeedbackCallback = Future<void> Function(double score, String userClass);

class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet({required this.onSubmitted});
  final _FeedbackCallback onSubmitted;

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  double _score = 70;
  bool _isSubmitting = false;

  String get _classification {
    if (_score >= 85) return 'Excellent';
    if (_score >= 70) return 'Good';
    if (_score >= 50) return 'Fair';
    return 'Poor';
  }

  Color get _color {
    if (_score >= 85) return const Color(0xFF16A34A);
    if (_score >= 70) return const Color(0xFF2563EB);
    if (_score >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmitted(_score, _classification);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException ? e.message : 'Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),

          Text(
            'Rate Last Night\'s Sleep',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 6),
          Text(
            'How would you personally rate the quality of your sleep?',
            style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Large score display
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Text(
              '${_score.toInt()}',
              key: ValueKey(_score.toInt()),
              style: TextStyle(fontSize: 80, fontWeight: FontWeight.w900, color: _color, height: 1),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(
              _classification.toUpperCase(),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _color, letterSpacing: 2),
            ),
          ),
          const SizedBox(height: 20),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _color,
              inactiveTrackColor: _color.withOpacity(0.15),
              thumbColor: _color,
              overlayColor: _color.withOpacity(0.12),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: _score,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (v) => setState(() => _score = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              Text('Poor  ·  Fair  ·  Good  ·  Excellent', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              Text('100', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
            ],
          ),
          const SizedBox(height: 28),

          // Buttons
          Row(
            children: [
              TextButton(
                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _color,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Rating', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
