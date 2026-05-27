import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/derived_sleep_data.dart';
import '../../../data/models/recommendation.dart';
import '../../../data/providers/analysis_provider.dart';
import '../../../app/routes.dart';

// ConsumerWidget gives access to Riverpod's `ref` so we can watch providers.
class SleepDetailScreen extends ConsumerWidget {
  const SleepDetailScreen({super.key, required this.record});

  final DerivedSleepData record;

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

  String _fmt(double hours) {
    final h = hours.toInt();
    final m = ((hours - h) * 60).toInt();
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final score = record.finalScore ?? 0;
    final color = _scoreColor(score);
    final date = DateTime.tryParse(record.date) ?? DateTime.now();

    // Fetch recommendations specific to this record so each history entry
    // shows its own insights rather than the latest entry's.
    final recommendationsAsync = record.id != null
        ? ref.watch(recommendationsByIdProvider(record.id!))
        : ref.watch(recommendationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          DateFormat('EEE, MMM d').format(date),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.white),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: [
          // ── Score Gauge ──────────────────────────────────────────────────
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
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(date),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
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
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    _scoreLabel(score),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color, letterSpacing: 2.5),
                  ),
                ),
                if (record.userScore != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFF6366F1), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'You rated this ${record.userScore!.toInt()}/100',
                        style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Core Metrics 2x2 ────────────────────────────────────────────
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
                value: record.tst != null ? _fmt(record.tst!) : '—',
                label: 'Duration',
                color: const Color(0xFF6366F1),
              ),
              _MetricCard(
                icon: Icons.bolt_rounded,
                value: record.sleepEfficiency != null
                    ? '${(record.sleepEfficiency! * 100).toStringAsFixed(0)}%'
                    : '—',
                label: 'Efficiency',
                color: const Color(0xFF2563EB),
              ),
              _MetricCard(
                icon: Icons.calendar_today_outlined,
                value: record.consistency7d != null
                    ? '${(record.consistency7d! * 100).toStringAsFixed(0)}%'
                    : '—',
                label: 'Consistency',
                color: const Color(0xFF16A34A),
              ),
              _MetricCard(
                icon: Icons.favorite_outline,
                value: record.biologicalReady != null
                    ? '${(record.biologicalReady! * 100).toStringAsFixed(0)}%'
                    : '—',
                label: 'Bio-Readiness',
                color: const Color(0xFFF59E0B),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Score Breakdown ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Score Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                const SizedBox(height: 16),
                _ScoreRow('Psychological Load', record.psychologicalLoad != null ? '${(record.psychologicalLoad! * 100).toStringAsFixed(0)}%' : '—', Icons.psychology_outlined, inverted: true),
                _ScoreRow('Environment Quality', record.environmentScore != null ? '${(record.environmentScore! * 100).toStringAsFixed(0)}%' : '—', Icons.home_outlined),
                _ScoreRow('Caffeine Gap', record.caffeineGapHours != null ? '${record.caffeineGapHours!.toStringAsFixed(1)}h before bed' : '—', Icons.coffee_rounded),
                _ScoreRow('Screen Impact', record.screenImpact != null ? '${(record.screenImpact! * 100).toStringAsFixed(0)}%' : '—', Icons.phone_android_rounded, inverted: true),
                if (record.penalty != null && record.penalty! > 0)
                  _ScoreRow('Penalties Applied', '-${record.penalty!.toStringAsFixed(0)} pts', Icons.remove_circle_outline, negative: true),
                _ScoreRow('Base Score', record.baseScore != null ? '${(record.baseScore! * 100).toStringAsFixed(0)}/100' : '—', Icons.analytics_outlined),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Personalised Recommendations ─────────────────────────────────
          const Text(
            'Personalised Recommendations',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          // Subtitle clarifies these reflect current patterns, not just this one night
          const Text(
            'Based on your recent sleep patterns',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 12),
          recommendationsAsync.when(
            data: (recs) {
              if (recs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No recommendations available yet. Complete a few more nights to unlock insights.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                );
              }
              // Show all recommendations as cards
              return Column(
                children: recs.map((rec) => _RecommendationCard(rec: rec)).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Could not load recommendations.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper functions for recommendation cards
// ─────────────────────────────────────────────────────────────────────────────

// Maps a recommendation category string to an icon
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

// Maps priority string to a colour: high=red, medium=amber, low=green
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
// Widgets
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coloured icon badge
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
                      // Priority badge (HIGH / MEDIUM / LOW)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.value, required this.label, required this.color});
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: color),
            ),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow(this.label, this.value, this.icon, {this.inverted = false, this.negative = false});
  final String label;
  final String value;
  final IconData icon;
  final bool inverted;
  final bool negative;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF475569)))),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: negative ? const Color(0xFFEF4444) : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
