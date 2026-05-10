import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../app/routes.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/profile_provider.dart';
import '../../../data/providers/analysis_provider.dart';
import '../../../data/providers/sleep_data_provider.dart';
import '../../../data/models/derived_sleep_data.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Color _scoreColor(int score) {
    if (score >= 85) return const Color(0xFF16A34A);
    if (score >= 70) return const Color(0xFF2563EB);
    if (score >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(userProfileProvider);
    ref.invalidate(latestAnalysisProvider);
    ref.invalidate(sleepHistoryProvider);
    await Future.wait([
      ref.read(userProfileProvider.future).catchError((_) => null),
      ref.read(latestAnalysisProvider.future).catchError((_) => null),
      ref.read(sleepHistoryProvider.future).catchError((_) => <DerivedSleepData>[]),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final latestAsync = ref.watch(latestAnalysisProvider);
    final historyAsync = ref.watch(sleepHistoryProvider);
    final loggingStage = ref.watch(loggingStageProvider);

    final firstName = profileAsync.whenOrNull(
          data: (user) {
            final name = user.fullName?.trim() ?? '';
            if (name.isNotEmpty) return name.split(' ').first;
            return user.email.split('@').first;
          },
        ) ??
        'there';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'SmartSleep',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'History',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.history),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Greeting ──────────────────────────────────────────────────────
            _GreetingSection(greeting: _greeting(), firstName: firstName),
            const SizedBox(height: 20),

            // ── Action Cards ──────────────────────────────────────────────────
            _ActionCard(
              color: const Color(0xFFFBBF24),
              icon: Icons.nightlight_round,
              title: 'Evening Check-in',
              subtitle: 'Log your daily activities and habits',
              enabled: loggingStage == LoggingStage.waitingForPreSleep,
              onTap: () => Navigator.pushNamed(context, AppRoutes.preSleepEntry),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              color: const Color(0xFF6366F1),
              icon: Icons.wb_sunny_rounded,
              title: 'Morning Check-in',
              subtitle: 'Log your sleep data and how you feel',
              enabled: loggingStage == LoggingStage.waitingForPostSleep,
              onTap: () => Navigator.pushNamed(context, AppRoutes.postSleepEntry),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              color: const Color(0xFF8B5CF6),
              icon: Icons.bar_chart_rounded,
              title: 'Sleep History',
              subtitle: 'View your past sleep logs and trends',
              enabled: true,
              onTap: () => Navigator.pushNamed(context, AppRoutes.history),
            ),
            const SizedBox(height: 20),

            // ── Last Sleep Score ───────────────────────────────────────────────
            latestAsync.when(
              data: (data) => _ScoreCard(
                data: data,
                loggingStage: loggingStage,
                scoreColor: _scoreColor(data.finalScore ?? 0),
                onTap: () => Navigator.pushNamed(context, AppRoutes.sleepReport),
                history: historyAsync.asData?.value ?? [],
              ),
              loading: () => const _CardSkeleton(height: 110),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // ── 7-Day Trend ────────────────────────────────────────────────────
            historyAsync.when(
              data: (history) => _TrendCard(history: history),
              loading: () => const _CardSkeleton(height: 220),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // ── Analytics Shortcut ─────────────────────────────────────────────
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.analytics),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.insights_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sleep Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                          Text('View graphs, trends & export data', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Personalisation Banner ─────────────────────────────────────────
            historyAsync.when(
              data: (history) =>
                  _PersonalisationBanner(daysLogged: history.length),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _GreetingSection extends StatelessWidget {
  const _GreetingSection({
    required this.greeting,
    required this.firstName,
  });

  final String greeting;
  final String firstName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $firstName!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'How did you sleep last night?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: enabled ? 2 : 0,
        shadowColor: color.withOpacity(0.15),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: enabled ? color : const Color(0xFF94A3B8),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.data,
    required this.loggingStage,
    required this.scoreColor,
    required this.onTap,
    this.history = const [],
  });

  final DerivedSleepData data;
  final LoggingStage loggingStage;
  final Color scoreColor;
  final VoidCallback onTap;
  final List<DerivedSleepData> history;

  // Returns (text, isPositive) for the 7-day comparison chip, or null if not enough data.
  (String, bool)? _comparison(int currentScore) {
    final prior = history
        .where((r) => r.tst != null && (r.finalScore ?? 0) > 0)
        .skip(1) // skip the latest (current) record
        .take(6)
        .toList();
    if (prior.isEmpty) return null;
    final avg = prior.fold(0.0, (s, r) => s + (r.finalScore ?? 0)) / prior.length;
    if (avg == 0) return null;
    final diff = ((currentScore - avg) / avg * 100).round();
    if (diff == 0) return ('Same as 7-day avg', true);
    final arrow = diff > 0 ? '↑' : '↓';
    final text = '$arrow ${diff.abs()}% ${diff > 0 ? "better" : "worse"} than 7-day avg';
    return (text, diff > 0);
  }

  @override
  Widget build(BuildContext context) {
    final score = data.finalScore ?? 0;
    final isWaitingFeedback = loggingStage == LoggingStage.waitingForFeedback;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last Sleep Score',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/ 100',
                  style: TextStyle(
                    fontSize: 18,
                    color: scoreColor.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: scoreColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isWaitingFeedback
                              ? 'Rate Your Sleep'
                              : 'View Full Report',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: scoreColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded,
                            size: 14, color: scoreColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (data.userClass != null) ...[
              const SizedBox(height: 6),
              Text(
                data.userClass!,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: scoreColor),
              ),
            ],
            // ── 7-day comparison chip ──────────────────────────────────────
            Builder(builder: (_) {
              final cmp = _comparison(score);
              if (cmp == null) return const SizedBox.shrink();
              final (text, isPositive) = cmp;
              final chipColor = isPositive ? const Color(0xFF16A34A) : const Color(0xFFEF4444);
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: chipColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: chipColor.withOpacity(0.25)),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: chipColor),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.history});

  final List<DerivedSleepData> history;

  @override
  Widget build(BuildContext context) {
    // Last 7 scored records, reversed so oldest is first on the chart
    final scored = history
        .where((r) => (r.finalScore ?? 0) > 0)
        .toList()
        .reversed
        .toList();
    final last7 =
        scored.length > 7 ? scored.sublist(scored.length - 7) : scored;

    final hasEnoughData = last7.length >= 2;

    final double avgScore = last7.isEmpty
        ? 0
        : last7.fold(0.0, (sum, r) => sum + (r.finalScore ?? 0)) /
            last7.length;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '7-Day Trend',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                if (hasEnoughData)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Avg ${avgScore.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (!hasEnoughData)
              Container(
                height: 120,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart_rounded,
                      size: 36,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Keep logging to see your trend',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 150,
                child: _SleepLineChart(records: last7),
              ),
          ],
        ),
      ),
    );
  }
}

class _SleepLineChart extends StatelessWidget {
  const _SleepLineChart({required this.records});

  final List<DerivedSleepData> records;

  @override
  Widget build(BuildContext context) {
    final spots = records.asMap().entries.map((e) {
      return FlSpot(
          e.key.toDouble(), (e.value.finalScore ?? 0).toDouble());
    }).toList();

    final dayLabels = records.map((r) {
      final parsed = DateTime.tryParse(r.date);
      if (parsed == null) return '';
      return DateFormat('EEE').format(parsed).substring(0, 3);
    }).toList();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= dayLabels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    dayLabels[index],
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF6366F1),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: const Color(0xFF6366F1),
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.25),
                  const Color(0xFF6366F1).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalisationBanner extends StatelessWidget {
  const _PersonalisationBanner({required this.daysLogged});

  final int daysLogged;

  @override
  Widget build(BuildContext context) {
    final Color stageColor;
    final String stageLabel;

    if (daysLogged < 7) {
      stageColor = const Color(0xFFF59E0B);
      stageLabel = 'Collecting baseline data';
    } else if (daysLogged < 21) {
      stageColor = const Color(0xFF6366F1);
      stageLabel = 'Learning your patterns';
    } else {
      stageColor = const Color(0xFF16A34A);
      stageLabel = 'Fully personalised';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: stageColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: stageColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 14, color: stageColor),
              const SizedBox(width: 6),
              Text(
                '$daysLogged ${daysLogged == 1 ? 'day' : 'days'} logged · $stageLabel',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: stageColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: SizedBox(
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
