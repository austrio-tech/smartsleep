// ─────────────────────────────────────────────────────────────────────────────
// analytics_screen.dart  –  Sleep analytics with charts, stats, and data export.
//
// Features:
//   - Period filter chips (This Week / This Month / This Year / Custom range)
//   - Summary stats row: average, best, worst, total nights
//   - Score history line chart with a dashed average reference line
//   - Score distribution bar chart (Excellent / Good / Fair / Poor breakdown)
//   - "Export as CSV" — opens the native share sheet with a .csv file attached
//   - "Email Export" — calls the backend which generates and emails the CSV
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/providers/sleep_data_provider.dart';
import '../../../data/providers/analysis_provider.dart';
import '../../../data/models/derived_sleep_data.dart';
import '../../../core/network/api_exception.dart';

/// Which time period the analytics are filtered to.
enum _Period { week, month, year, custom }

/// The analytics screen — shows sleep trends, distribution, and export options.
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  _Period _period = _Period.week;  // Default to this week's view
  DateTimeRange? _customRange;     // Set by the date range picker for custom filter
  bool _exporting = false;          // True while the share-sheet CSV export is running
  bool _emailExporting = false;     // True while the backend email export is running

  // ── Filter logic ─────────────────────────────────────────────────────────

  /// Filters the full history list to only records within the selected period.
  ///
  /// Also excludes stub records (no TST means the analysis isn't done yet).
  List<DerivedSleepData> _filter(List<DerivedSleepData> all) {
    final now = DateTime.now();
    DateTime cutoff;

    switch (_period) {
      case _Period.week:
        cutoff = now.subtract(const Duration(days: 7));
        break;
      case _Period.month:
        cutoff = now.subtract(const Duration(days: 30));
        break;
      case _Period.year:
        cutoff = now.subtract(const Duration(days: 365));
        break;
      case _Period.custom:
        if (_customRange == null) return all;
        // For custom range, filter by both start and end date
        return all.where((r) {
          final d = DateTime.tryParse(r.date);
          if (d == null) return false;
          return !d.isBefore(_customRange!.start) && !d.isAfter(_customRange!.end);
        }).where((r) => r.tst != null && (r.finalScore ?? 0) > 0).toList();
    }

    // For non-custom periods, filter by cutoff date and only include analysed records
    return all
        .where((r) => r.tst != null && (r.finalScore ?? 0) > 0)
        .where((r) {
          final d = DateTime.tryParse(r.date);
          return d != null && d.isAfter(cutoff);
        })
        .toList();
  }

  // ── Custom date range picker ───────────────────────────────────────────────

  /// Opens a date range picker dialog and updates [_customRange] with the result.
  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: Theme.of(ctx).colorScheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _customRange = picked);
  }

  // ── Share-sheet CSV export ─────────────────────────────────────────────────

  /// Generates a CSV locally and opens the native share sheet (copy/AirDrop/etc.).
  ///
  /// This runs entirely on the device — no server call needed.
  Future<void> _export(List<DerivedSleepData> records) async {
    if (records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export for this period.')),
      );
      return;
    }
    setState(() => _exporting = true);
    try {
      // Build a human-readable filename from the selected period
      final label = _period == _Period.custom && _customRange != null
          ? '${DateFormat('yyyy-MM-dd').format(_customRange!.start)}'
            '_to_${DateFormat('yyyy-MM-dd').format(_customRange!.end)}'
          : _period.name;
      final fileName = 'smartsleep_$label.csv';

      // Write the CSV to the system temp directory
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(_buildCsv(records), flush: true);

      // Open the native share sheet with the CSV file attached
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv', name: fileName)],
        subject: 'SmartSleep Export — ${records.length} nights',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is ApiException ? e.message : 'Export failed. Please try again.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ── Email CSV export ───────────────────────────────────────────────────────

  /// Calls the backend to generate a CSV of the selected period and email it.
  ///
  /// Unlike `_export()` which runs entirely on the device, this method makes
  /// a network request to the backend. The server queries the database,
  /// builds the CSV, renders an HTML email, and sends it to the user's
  /// registered email address via the Google Apps Script relay.
  ///
  /// Flow:
  ///   1. Convert the selected period to start/end date strings
  ///   2. Call POST /api/v1/sleep/export with those dates
  ///   3. Show a green SnackBar on success, red SnackBar on failure
  ///
  /// The method is `async` because it makes a network request that takes time.
  /// `await` pauses execution until the network call finishes.
  Future<void> _emailExport(List<DerivedSleepData> records) async {
    // Guard: nothing to export
    if (records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export for this period.')),
      );
      return;
    }

    // Show the loading spinner on the "Email Export" button
    // setState() tells Flutter to rebuild the widget with the new state value
    setState(() => _emailExporting = true);

    // try/catch/finally is the standard error-handling pattern in Dart:
    //   try    — run the code that might fail
    //   catch  — handle the error if something goes wrong
    //   finally— always run this, whether success or failure (cleanup)
    try {
      // ── Compute the date range to send to the API ─────────────────────
      // The API accepts optional start_date / end_date strings in "YYYY-MM-DD" format.
      // If we send null for both, the server exports ALL records.
      String? startDate;
      String? endDate;

      if (_period == _Period.custom && _customRange != null) {
        // Custom range: the user picked exact start and end dates via the date picker.
        // DateFormat('yyyy-MM-dd').format(date) converts a DateTime to "YYYY-MM-DD" string.
        startDate = DateFormat('yyyy-MM-dd').format(_customRange!.start);
        endDate   = DateFormat('yyyy-MM-dd').format(_customRange!.end);
      } else if (_period != _Period.week || _period != _Period.month || _period != _Period.year) {
        // Preset period: calculate the cutoff date based on the selected chip.
        final now = DateTime.now();

        // Dart 3 switch expression (not a statement — it returns a value).
        // Each `=> value` maps a case to the resulting value.
        // `now.subtract(Duration(days: 7))` calculates "7 days ago from now".
        final cutoff = switch (_period) {
          _Period.week   => now.subtract(const Duration(days: 7)),    // Last 7 days
          _Period.month  => now.subtract(const Duration(days: 30)),   // Last 30 days
          _Period.year   => now.subtract(const Duration(days: 365)),  // Last 365 days
          _Period.custom => now, // Already handled above — this case won't be reached
        };
        // Only send a start_date (no end_date = "up to today")
        startDate = DateFormat('yyyy-MM-dd').format(cutoff);
      }
      // If _period is none of the above (shouldn't happen), both dates stay null
      // and the server exports everything.

      // ── Make the API call ─────────────────────────────────────────────
      // ref.read() gets the current value of a provider WITHOUT watching it.
      // We use ref.read (not ref.watch) here because:
      //   - ref.watch causes the widget to rebuild whenever the provider changes
      //   - ref.read is a one-time read — perfect for triggering an action
      //   - We don't need the repository to cause rebuilds; we just call a method on it
      final repository = ref.read(analysisRepositoryProvider);

      // await pauses this method until emailExport() completes (HTTP call finishes).
      // The method returns the server's success message string.
      final message = await repository.emailExport(
        startDate: startDate,
        endDate: endDate,
      );

      // ── Show success feedback ─────────────────────────────────────────
      // `mounted` checks whether this widget is still in the widget tree.
      // After an async gap (await), the widget might have been removed
      // (e.g., user navigated away). Using a disposed widget's context crashes.
      if (mounted) {
        // SnackBar = the small banner that slides up from the bottom of the screen
        // BehaviorBehavior.floating = the snack bar "floats" above the bottom nav bar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message), // e.g. "Export sent to user@... (42 nights)"
            backgroundColor: const Color(0xFF16A34A), // Success green
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4), // Auto-dismiss after 4 seconds
          ),
        );
      }
    } catch (e) {
      // Something went wrong (network error, server error, etc.)
      // `e` is the exception object — we convert it to a readable string.
      if (mounted) {
        // Strip the "ApiException: " prefix that our custom exception adds,
        // so the user sees just the human-readable message from the server.
        final msg = e is ApiException ? e.message : 'Something went wrong. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email export failed: $msg'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      // This block ALWAYS runs, even if an exception was thrown.
      // We use it to hide the loading spinner regardless of success or failure.
      // `mounted` guard is needed here too (same reason as above).
      if (mounted) setState(() => _emailExporting = false);
    }
  }

  // ── CSV builder (client-side, for share sheet export) ─────────────────────

  /// Builds a CSV string from the given records list.
  ///
  /// Columns match the backend's export format so both export methods
  /// produce identical data.
  String _buildCsv(List<DerivedSleepData> records) {
    final buf = StringBuffer();
    buf.writeln('Date,Score,Classification,Duration_h,Efficiency_%,Consistency_%,Bio_Readiness_%,Psych_Load_%,Env_Score_%,Caffeine_Gap_h,Screen_Impact_%,Penalty,User_Score,User_Class');
    for (final r in records.reversed) {
      buf.writeln([
        r.date,
        r.finalScore ?? '',
        r.userClass ?? '',
        r.tst?.toStringAsFixed(2) ?? '',
        r.sleepEfficiency != null ? (r.sleepEfficiency! * 100).toStringAsFixed(0) : '',
        r.consistency7d != null ? (r.consistency7d! * 100).toStringAsFixed(0) : '',
        r.biologicalReady != null ? (r.biologicalReady! * 100).toStringAsFixed(0) : '',
        r.psychologicalLoad != null ? (r.psychologicalLoad! * 100).toStringAsFixed(0) : '',
        r.environmentScore != null ? (r.environmentScore! * 100).toStringAsFixed(0) : '',
        r.caffeineGapHours?.toStringAsFixed(1) ?? '',
        r.screenImpact != null ? (r.screenImpact! * 100).toStringAsFixed(0) : '',
        r.penalty?.toStringAsFixed(1) ?? '',
        r.userScore?.toStringAsFixed(0) ?? '',
        r.userClass ?? '',
      ].join(','));
    }
    return buf.toString();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Watch the sleep history provider — this widget rebuilds when history changes
    final historyAsync = ref.watch(sleepHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Sleep Analytics',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: historyAsync.when(
        data: (all) {
          final records = _filter(all); // Apply period filter
          return _buildContent(context, theme, records, all);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading data: $e')),
      ),
    );
  }

  /// Builds the main scrollable content with charts, stats, and export buttons.
  Widget _buildContent(BuildContext context, ThemeData theme,
      List<DerivedSleepData> records, List<DerivedSleepData> all) {
    // `scored` is oldest-first for the chart's left-to-right direction
    final scored = records.reversed.toList();
    final spots = scored.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), (e.value.finalScore ?? 0).toDouble()))
        .toList();

    // Calculate summary statistics
    final avg = scored.isEmpty
        ? 0.0
        : scored.fold(0.0, (s, r) => s + (r.finalScore ?? 0)) / scored.length;
    final best  = scored.isEmpty ? 0 : scored.map((r) => r.finalScore ?? 0).reduce((a, b) => a > b ? a : b);
    final worst = scored.isEmpty ? 0 : scored.map((r) => r.finalScore ?? 0).reduce((a, b) => a < b ? a : b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [

        // ── Period filter chips ───────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _PeriodChip(
                label: 'This Week',
                selected: _period == _Period.week,
                onTap: () => setState(() => _period = _Period.week),
              ),
              const SizedBox(width: 8),
              _PeriodChip(
                label: 'This Month',
                selected: _period == _Period.month,
                onTap: () => setState(() => _period = _Period.month),
              ),
              const SizedBox(width: 8),
              _PeriodChip(
                label: 'This Year',
                selected: _period == _Period.year,
                onTap: () => setState(() => _period = _Period.year),
              ),
              const SizedBox(width: 8),
              _PeriodChip(
                // Show selected date range or generic "Custom" label
                label: _period == _Period.custom && _customRange != null
                    ? '${DateFormat('MMM d').format(_customRange!.start)} – ${DateFormat('MMM d').format(_customRange!.end)}'
                    : 'Custom',
                selected: _period == _Period.custom,
                onTap: () async {
                  await _pickCustomRange();
                  setState(() => _period = _Period.custom);
                },
                icon: Icons.date_range_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Summary stats row ─────────────────────────────────────────────
        Row(
          children: [
            Expanded(child: _StatBox(label: 'Average', value: avg.toStringAsFixed(0), color: const Color(0xFF6366F1))),
            const SizedBox(width: 10),
            Expanded(child: _StatBox(label: 'Best',    value: '$best',               color: const Color(0xFF16A34A))),
            const SizedBox(width: 10),
            Expanded(child: _StatBox(label: 'Worst',   value: '$worst',              color: const Color(0xFFEF4444))),
            const SizedBox(width: 10),
            Expanded(child: _StatBox(label: 'Nights',  value: '${scored.length}',    color: const Color(0xFFF59E0B))),
          ],
        ),
        const SizedBox(height: 16),

        // ── Score history line chart ──────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Score History',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                  const Spacer(),
                  if (scored.isNotEmpty)
                    Text('${scored.length} nights',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                ],
              ),
              const SizedBox(height: 16),
              if (scored.length < 2)
                // Empty state — not enough data for a meaningful line
                Container(
                  height: 160,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.show_chart_rounded, size: 40, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      const Text('Not enough data for this period',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 100,
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 25, // Grid lines at 0, 25, 50, 75, 100
                        getDrawingHorizontalLine: (v) =>
                            FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1),
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 25,
                            reservedSize: 32,
                            getTitlesWidget: (v, _) => Text(
                              '${v.toInt()}',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            // Show fewer labels when many data points to avoid overlap
                            interval: (scored.length > 10)
                                ? (scored.length / 5).ceilToDouble()
                                : 1,
                            getTitlesWidget: (v, _) {
                              final idx = v.toInt();
                              if (idx < 0 || idx >= scored.length) return const SizedBox.shrink();
                              final d = DateTime.tryParse(scored[idx].date);
                              if (d == null) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  DateFormat('M/d').format(d),
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        // Main score line
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: const Color(0xFF6366F1),
                          barWidth: 3,
                          dotData: FlDotData(
                            // Show dots only when few data points (else chart gets cluttered)
                            show: scored.length <= 14,
                            getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                              radius: 4,
                              color: const Color(0xFF6366F1),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1).withOpacity(0.25),
                                const Color(0xFF6366F1).withOpacity(0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        // Dashed average reference line — shows where the mean sits
                        LineChartBarData(
                          spots: [
                            FlSpot(0, avg),
                            FlSpot((scored.length - 1).toDouble(), avg),
                          ],
                          isCurved: false,
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          barWidth: 1,
                          dashArray: [6, 4], // Dashed line pattern
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Score distribution ────────────────────────────────────────────
        if (scored.isNotEmpty) ...[
          _buildDistributionCard(scored),
          const SizedBox(height: 16),
        ],

        // ── Export buttons ────────────────────────────────────────────────
        // Two separate buttons for two different export methods.
        // We show them both disabled while EITHER export is running to prevent
        // the user from triggering two exports at the same time.
        //
        //   Button 1: "Export as CSV"  — works entirely on the device, no internet needed.
        //             Generates the CSV locally → opens the OS share sheet.
        //             The share sheet lets the user AirDrop, WhatsApp, or save to Files.
        //
        //   Button 2: "Email Export"   — makes a network call to the backend.
        //             The server queries the database → builds CSV → emails it.
        //             The user receives the CSV in their registered email inbox.

        // ── Button 1: Share-sheet / device-local CSV export ───────────────
        SizedBox(
          width: double.infinity, // Stretch the button to the full screen width
          child: ElevatedButton.icon(
            // onPressed: null disables the button (greyed out, not clickable)
            // We disable both buttons while either export is in progress to prevent
            // accidental double-taps or overlapping requests.
            onPressed: (_exporting || _emailExporting) ? null : () => _export(records),

            // Show a spinning loader INSIDE the button while exporting,
            // replacing the normal icon. SizedBox constrains the spinner size.
            icon: _exporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    // CircularProgressIndicator = the spinning circle loading animation
                    // strokeWidth controls how thick the ring is
                    // color: Colors.white because the button background is dark
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.share_rounded, size: 20), // Normal state icon

            // Change the button label dynamically based on loading state
            label: Text(_exporting ? 'Exporting…' : 'Export as CSV'),

            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // ── Button 2: Backend email export ────────────────────────────────
        // OutlinedButton = button with a border and transparent background
        // (as opposed to ElevatedButton which has a filled background).
        // Using a different style visually separates the two export options.
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: (_exporting || _emailExporting) ? null : () => _emailExport(records),

            icon: _emailExporting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      // OutlinedButton has a transparent (white) background,
                      // so we use the primary colour instead of white for the spinner
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : const Icon(Icons.email_outlined, size: 20),

            label: Text(_emailExporting ? 'Sending…' : 'Email Export'),

            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),

        // Small helper text below both buttons explaining the difference
        const SizedBox(height: 8),
        const Text(
          'CSV → opens share sheet on this device\nEmail → sends CSV to your registered email address',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), height: 1.5),
        ),
      ],
    );
  }

  /// Builds the score distribution bar chart card.
  Widget _buildDistributionCard(List<DerivedSleepData> scored) {
    // Count records in each quality tier
    int excellent = 0, good = 0, fair = 0, poor = 0;
    for (final r in scored) {
      final s = r.finalScore ?? 0;
      if (s >= 85)      excellent++;
      else if (s >= 70) good++;
      else if (s >= 50) fair++;
      else              poor++;
    }
    final total = scored.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Score Distribution',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          _DistBar(label: 'Excellent', count: excellent, total: total, color: const Color(0xFF16A34A)),
          const SizedBox(height: 8),
          _DistBar(label: 'Good',      count: good,      total: total, color: const Color(0xFF2563EB)),
          const SizedBox(height: 8),
          _DistBar(label: 'Fair',      count: fair,      total: total, color: const Color(0xFFF59E0B)),
          const SizedBox(height: 8),
          _DistBar(label: 'Poor',      count: poor,      total: total, color: const Color(0xFFEF4444)),
        ],
      ),
    );
  }
}

// ─── Private sub-widgets ──────────────────────────────────────────────────────

/// A tappable period filter chip (e.g., "This Week", "Custom").
class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;      // True = this chip is the active filter
  final VoidCallback onTap;
  final IconData? icon;     // Optional icon shown before the label (used for "Custom")

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0F172A); // Deep night blue when selected
    const indigo  = Color(0xFF6366F1);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), // Smooth colour transition on select
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? primary : const Color(0xFFE2E8F0)),
          boxShadow: selected
              ? [BoxShadow(color: primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? Colors.white : indigo),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A summary statistic box (Average / Best / Worst / Nights).
class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

/// A single horizontal bar in the score distribution chart.
///
/// Shows label, a proportional progress bar, and the count.
class _DistBar extends StatelessWidget {
  const _DistBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  final String label;
  final int count;
  final int total;  // Used to compute the fraction for the progress bar
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : count / total;
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,                            // 0.0 to 1.0
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 24,
          child: Text(
            '$count',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ],
    );
  }
}
