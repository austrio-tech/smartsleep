// ─────────────────────────────────────────────────────────────────────────────
// home_screen.dart  –  Main dashboard screen shown after login.
//
// Displays:
//   - Personalised greeting with the user's first name
//   - Action cards for the current logging stage (Evening / Morning check-in)
//   - Last sleep score card with 7-day comparison
//   - 7-day sleep trend line chart (using fl_chart)
//   - Analytics shortcut banner
//   - Personalisation progress banner
//
// Data is loaded via Riverpod FutureProviders:
//   userProfileProvider    → user name
//   latestAnalysisProvider → last sleep score
//   sleepHistoryProvider   → history for the chart and logging stage
// ─────────────────────────────────────────────────────────────────────────────

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

/// The main Home screen / dashboard tab.
///
/// Uses ConsumerWidget (not StatelessWidget) because it needs to watch
/// Riverpod providers. ConsumerWidget rebuilds automatically when any
/// watched provider changes.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// Returns a time-appropriate greeting based on the current hour.
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Maps a sleep score (0-100) to a semantic colour.
  ///
  /// Green for excellent (≥85), blue for good (≥70), amber for fair (≥50), red for poor.
  Color _scoreColor(int score) {
    if (score >= 85) return const Color(0xFF16A34A);  // Green
    if (score >= 70) return const Color(0xFF2563EB);  // Blue
    if (score >= 50) return const Color(0xFFF59E0B);  // Amber
    return const Color(0xFFEF4444);                    // Red
  }

  /// Pull-to-refresh handler — invalidates all data providers to force a reload.
  Future<void> _refresh(WidgetRef ref) async {
    // invalidate() marks a provider as stale — the next read rebuilds it
    ref.invalidate(userProfileProvider);
    ref.invalidate(latestAnalysisProvider);
    ref.invalidate(sleepHistoryProvider);

    // Wait for all three to finish loading (errors are silently ignored)
    await Future.wait([
      ref.read(userProfileProvider.future).catchError((_) => null),
      ref.read(latestAnalysisProvider.future).catchError((_) => null),
      ref.read(sleepHistoryProvider.future).catchError((_) => <DerivedSleepData>[]),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Watch all three providers — this widget rebuilds when any of them changes
    final profileAsync  = ref.watch(userProfileProvider);
    final latestAsync   = ref.watch(latestAnalysisProvider);
    final historyAsync  = ref.watch(sleepHistoryProvider);
    final loggingStage  = ref.watch(loggingStageProvider); // pre/post/feedback

    // Extract the user's first name from the profile, or fall back to "there"
    final firstName = profileAsync.whenOrNull(
          data: (user) {
            final name = user.fullName?.trim() ?? '';
            if (name.isNotEmpty) return name.split(' ').first;
            return user.email.split('@').first;
          },
        ) ?? 'there';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'SmartSleep',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
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
            // Logout clears the token and navigates to login (via auth state change)
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
      // RefreshIndicator adds pull-to-refresh functionality to any scrollable widget
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Greeting section ──────────────────────────────────────────
            _GreetingSection(greeting: _greeting(), firstName: firstName),
            const SizedBox(height: 20),

            // ── Action cards — one per logging stage ──────────────────────
            // `enabled` is based on loggingStage — only the current stage's card is tappable.
            _ActionCard(
              color: const Color(0xFFFBBF24),   // Amber for evening
              icon: Icons.nightlight_round,
              title: 'Evening Check-in',
              subtitle: 'Log your daily activities and habits',
              enabled: loggingStage == LoggingStage.waitingForPreSleep,
              onTap: () => Navigator.pushNamed(context, AppRoutes.preSleepEntry),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              color: const Color(0xFF6366F1),   // Indigo for morning
              icon: Icons.wb_sunny_rounded,
              title: 'Morning Check-in',
              subtitle: 'Log your sleep data and how you feel',
              enabled: loggingStage == LoggingStage.waitingForPostSleep,
              onTap: () => Navigator.pushNamed(context, AppRoutes.postSleepEntry),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              color: const Color(0xFF8B5CF6),   // Purple for history
              icon: Icons.bar_chart_rounded,
              title: 'Sleep History',
              subtitle: 'View your past sleep logs and trends',
              enabled: true, // Always enabled
              onTap: () => Navigator.pushNamed(context, AppRoutes.history),
            ),
            const SizedBox(height: 20),

            // ── Last Sleep Score card ─────────────────────────────────────
            // `when()` handles all three async states: loading, data, error.
            latestAsync.when(
              data: (data) => _ScoreCard(
                data: data,
                loggingStage: loggingStage,
                scoreColor: _scoreColor(data.finalScore ?? 0),
                onTap: () => Navigator.pushNamed(context, AppRoutes.sleepReport),
                history: historyAsync.asData?.value ?? [],
              ),
              loading: () => const _CardSkeleton(height: 110), // Placeholder while loading
              error: (_, __) => const SizedBox.shrink(),        // Hide on error
            ),
            const SizedBox(height: 20),

            // ── 7-day trend chart ─────────────────────────────────────────
            historyAsync.when(
              data: (history) => _TrendCard(history: history),
              loading: () => const _CardSkeleton(height: 220),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // ── Analytics shortcut banner ─────────────────────────────────
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
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
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

            // ── Personalisation stage banner ──────────────────────────────
            historyAsync.when(
              data: (history) => _PersonalisationBanner(daysLogged: history.length),
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
// Private sub-widgets
// These are prefixed with `_` to indicate they are private to this file.
// Breaking the UI into small named widgets makes the code more readable and
// helps Flutter optimise rebuilds (only changed widgets are redrawn).
// ─────────────────────────────────────────────────────────────────────────────

/// Displays the time-based greeting and user's first name.
class _GreetingSection extends StatelessWidget {
  const _GreetingSection({required this.greeting, required this.firstName});

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
            fontWeight: FontWeight.bold, color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'How did you sleep last night?',
          style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
        ),
      ],
    );
  }
}

/// A tappable card for one of the logging actions (Evening / Morning / History).
///
/// Shows as greyed out (opacity 0.45) and non-tappable when [enabled] is false.
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
  final bool enabled;      // Whether this card is currently actionable
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      // Dim disabled cards to visually indicate they're not available
      opacity: enabled ? 1.0 : 0.45,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: enabled ? 2 : 0,
        shadowColor: color.withOpacity(0.15),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null, // null disables the tap gesture
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Circular icon container with semi-transparent background
                Container(
                  width: 48, height: 48,
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
                      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: enabled ? color : const Color(0xFF94A3B8), size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Displays the latest sleep score with a 7-day comparison chip.
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

  /// Computes a comparison string vs the 7-day rolling average.
  ///
  /// Returns (text, isPositive) or null if not enough history.
  /// Example: ("↑ 12% better than 7-day avg", true)
  (String, bool)? _comparison(int currentScore) {
    final prior = history
        .where((r) => r.tst != null && (r.finalScore ?? 0) > 0)
        .skip(1)  // Skip the latest (current) record — compare against the rest
        .take(6)  // Max 6 previous records for the 7-day average
        .toList();
    if (prior.isEmpty) return null;
    final avg = prior.fold(0.0, (s, r) => s + (r.finalScore ?? 0)) / prior.length;
    if (avg == 0) return null;
    final diff = ((currentScore - avg) / avg * 100).round();
    if (diff == 0) return ('Same as 7-day avg', true);
    final arrow = diff > 0 ? '↑' : '↓';
    return ('$arrow ${diff.abs()}% ${diff > 0 ? "better" : "worse"} than 7-day avg', diff > 0);
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
            const Text('Last Sleep Score',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF64748B), letterSpacing: 0.3)),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Large score number
                Text('$score',
                    style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: scoreColor, height: 1)),
                const SizedBox(width: 4),
                Text('/ 100',
                    style: TextStyle(fontSize: 18, color: scoreColor.withOpacity(0.6), fontWeight: FontWeight.w500)),
                const Spacer(),
                // Action button — "Rate Your Sleep" or "View Full Report"
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: scoreColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isWaitingFeedback ? 'Rate Your Sleep' : 'View Full Report',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: scoreColor),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: scoreColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Quality classification label (Excellent / Good / Fair / Poor)
            if (data.userClass != null) ...[
              const SizedBox(height: 6),
              Text(data.userClass!,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: scoreColor)),
            ],
            // 7-day comparison chip
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
                  child: Text(text,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: chipColor)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Card containing the 7-day sleep score line chart.
class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.history});

  final List<DerivedSleepData> history;

  @override
  Widget build(BuildContext context) {
    // Filter to records with a real score, reverse so oldest is left on chart
    final scored = history.where((r) => (r.finalScore ?? 0) > 0).toList().reversed.toList();
    final last7 = scored.length > 7 ? scored.sublist(scored.length - 7) : scored;

    final hasEnoughData = last7.length >= 2; // Need at least 2 points for a line

    final double avgScore = last7.isEmpty
        ? 0
        : last7.fold(0.0, (sum, r) => sum + (r.finalScore ?? 0)) / last7.length;

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
                const Text('7-Day Trend',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                const Spacer(),
                // Average score chip — only shown when there's data
                if (hasEnoughData)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Avg ${avgScore.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6366F1))),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Show empty state if not enough data logged yet
            if (!hasEnoughData)
              Container(
                height: 120,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart_rounded, size: 36, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    const Text('Keep logging to see your trend',
                        style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                  ],
                ),
              )
            else
              // Render the actual line chart when there's enough data
              SizedBox(height: 150, child: _SleepLineChart(records: last7)),
          ],
        ),
      ),
    );
  }
}

/// The actual fl_chart LineChart widget for the 7-day trend.
class _SleepLineChart extends StatelessWidget {
  const _SleepLineChart({required this.records});

  final List<DerivedSleepData> records;

  @override
  Widget build(BuildContext context) {
    // Create (x, y) data points for the chart. x = day index, y = score.
    final spots = records.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value.finalScore ?? 0).toDouble());
    }).toList();

    // Build day labels for the x-axis (e.g., "Mon", "Tue")
    final dayLabels = records.map((r) {
      final parsed = DateTime.tryParse(r.date);
      if (parsed == null) return '';
      return DateFormat('EEE').format(parsed).substring(0, 3);
    }).toList();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100, // Score range
        gridData: const FlGridData(show: false),   // No grid lines
        borderData: FlBorderData(show: false),      // No chart border
        titlesData: FlTitlesData(
          leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= dayLabels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(dayLabels[index],
                      style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,                         // Smooth curved line
            color: const Color(0xFF6366F1),         // Indigo line colour
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: const Color(0xFF6366F1),
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            // Gradient fill below the line
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

/// Small banner showing the ML personalisation stage (Collecting / Learning / Personalised).
class _PersonalisationBanner extends StatelessWidget {
  const _PersonalisationBanner({required this.daysLogged});

  final int daysLogged; // Total number of sleep records the user has logged

  @override
  Widget build(BuildContext context) {
    // Determine the personalisation stage based on how many days have been logged
    final Color stageColor;
    final String stageLabel;

    if (daysLogged < 7) {
      stageColor = const Color(0xFFF59E0B); // Amber — still collecting baseline
      stageLabel = 'Collecting baseline data';
    } else if (daysLogged < 21) {
      stageColor = const Color(0xFF6366F1); // Indigo — ML starting to learn
      stageLabel = 'Learning your patterns';
    } else {
      stageColor = const Color(0xFF16A34A); // Green — fully personalised
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
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: stageColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A placeholder skeleton card shown while data is loading.
///
/// Using a skeleton (grey rectangle) gives better UX than showing nothing —
/// the user can see the layout before data arrives.
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
