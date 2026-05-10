import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/derived_sleep_data.dart';
import '../../../app/routes.dart';

class SleepDetailScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = record.finalScore ?? 0;
    final color = _scoreColor(score);
    final date = DateTime.tryParse(record.date) ?? DateTime.now();

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

          // ── Additional Metrics ───────────────────────────────────────────
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
        ],
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
