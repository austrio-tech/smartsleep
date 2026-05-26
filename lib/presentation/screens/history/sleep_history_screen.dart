import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/routes.dart';
import '../../../data/providers/sleep_data_provider.dart';
import '../../../data/models/derived_sleep_data.dart';
import '../../../core/network/api_exception.dart';
import 'sleep_detail_screen.dart';

class SleepHistoryScreen extends ConsumerWidget {
  const SleepHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(sleepHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Sleep History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, color: Colors.white),
            tooltip: 'Analytics',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.analytics),
          ),
        ],
      ),
      body: historyAsync.when(
        data: (history) {
          final scored = history.where((r) => r.tst != null).toList();
          if (scored.isEmpty) return _buildEmpty(context);
          return _buildList(context, scored);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e is ApiException ? e.message : 'Failed to load history. Please try again.')),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bedtime_outlined, size: 56, color: theme.colorScheme.primary.withOpacity(0.3)),
            ),
            const SizedBox(height: 24),
            Text('No Records Yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Complete your first evening + morning check-in to see your sleep history here.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.preSleepEntry),
              child: const Text('Start Tonight'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<DerivedSleepData> records) {
    return Column(
      children: [
        // Analytics banner
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.analytics),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.insights_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'View Analytics, Trends & Export Data',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            itemCount: records.length,
            itemBuilder: (context, index) {
              return _HistoryCard(
                record: records[index],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SleepDetailScreen(record: records[index])),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.record, required this.onTap});

  final DerivedSleepData record;
  final VoidCallback onTap;

  Color _scoreColor(int score) {
    if (score >= 85) return const Color(0xFF16A34A);
    if (score >= 70) return const Color(0xFFF59E0B);
    if (score >= 50) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = record.finalScore ?? 0;
    final color = _scoreColor(score);
    final date = DateTime.tryParse(record.date) ?? DateTime.now();
    final hasUserRating = record.userScore != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Score circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text('$score', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 17)),
            ),
            const SizedBox(width: 16),
            // Date + classification
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d').format(date),
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        record.userClass ?? 'Pending',
                        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      if (hasUserRating) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Rated', style: TextStyle(fontSize: 10, color: Color(0xFF6366F1), fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // TST
            if (record.tst != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_fmt(record.tst!), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const Text('slept', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  String _fmt(double hours) {
    final h = hours.toInt();
    final m = ((hours - h) * 60).toInt();
    return '${h}h ${m}m';
  }
}
