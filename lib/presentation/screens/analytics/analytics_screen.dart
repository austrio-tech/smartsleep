import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/providers/sleep_data_provider.dart';
import '../../../data/models/derived_sleep_data.dart';

enum _Period { week, month, year, custom }

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  _Period _period = _Period.week;
  DateTimeRange? _customRange;
  bool _exporting = false;

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
        return all.where((r) {
          final d = DateTime.tryParse(r.date);
          if (d == null) return false;
          return !d.isBefore(_customRange!.start) && !d.isAfter(_customRange!.end);
        }).where((r) => r.tst != null && (r.finalScore ?? 0) > 0).toList();
    }
    return all
        .where((r) => r.tst != null && (r.finalScore ?? 0) > 0)
        .where((r) {
          final d = DateTime.tryParse(r.date);
          return d != null && d.isAfter(cutoff);
        })
        .toList();
  }

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

  Future<void> _export(List<DerivedSleepData> records) async {
    if (records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export for this period.')),
      );
      return;
    }
    setState(() => _exporting = true);
    try {
      // Build filename based on selected period
      final label = _period == _Period.custom && _customRange != null
          ? '${DateFormat('yyyy-MM-dd').format(_customRange!.start)}'
            '_to_${DateFormat('yyyy-MM-dd').format(_customRange!.end)}'
          : _period.name;
      final fileName = 'smartsleep_$label.csv';

      // Write CSV to the system temp directory
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(_buildCsv(records), flush: true);

      // Share as a real file — opens native share sheet with CSV attachment
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv', name: fileName)],
        subject: 'SmartSleep Export — ${records.length} nights',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(sleepHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Sleep Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: historyAsync.when(
        data: (all) {
          final records = _filter(all);
          return _buildContent(context, theme, records, all);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, List<DerivedSleepData> records, List<DerivedSleepData> all) {
    final scored = records.reversed.toList();
    final spots = scored.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), (e.value.finalScore ?? 0).toDouble()))
        .toList();

    final avg = scored.isEmpty
        ? 0.0
        : scored.fold(0.0, (s, r) => s + (r.finalScore ?? 0)) / scored.length;
    final best = scored.isEmpty ? 0 : scored.map((r) => r.finalScore ?? 0).reduce((a, b) => a > b ? a : b);
    final worst = scored.isEmpty ? 0 : scored.map((r) => r.finalScore ?? 0).reduce((a, b) => a < b ? a : b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        // ── Period Filters ─────────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _PeriodChip(label: 'This Week', selected: _period == _Period.week, onTap: () => setState(() => _period = _Period.week)),
              const SizedBox(width: 8),
              _PeriodChip(label: 'This Month', selected: _period == _Period.month, onTap: () => setState(() => _period = _Period.month)),
              const SizedBox(width: 8),
              _PeriodChip(label: 'This Year', selected: _period == _Period.year, onTap: () => setState(() => _period = _Period.year)),
              const SizedBox(width: 8),
              _PeriodChip(
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

        // ── Stats Row ──────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(child: _StatBox(label: 'Average', value: avg.toStringAsFixed(0), color: const Color(0xFF6366F1))),
            const SizedBox(width: 10),
            Expanded(child: _StatBox(label: 'Best', value: '$best', color: const Color(0xFF16A34A))),
            const SizedBox(width: 10),
            Expanded(child: _StatBox(label: 'Worst', value: '$worst', color: const Color(0xFFEF4444))),
            const SizedBox(width: 10),
            Expanded(child: _StatBox(label: 'Nights', value: '${scored.length}', color: const Color(0xFFF59E0B))),
          ],
        ),
        const SizedBox(height: 16),

        // ── Line Chart ─────────────────────────────────────────────────────
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
                  const Text('Score History', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                  const Spacer(),
                  if (scored.isNotEmpty)
                    Text('${scored.length} nights', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                ],
              ),
              const SizedBox(height: 16),
              if (scored.length < 2)
                Container(
                  height: 160,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.show_chart_rounded, size: 40, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      const Text('Not enough data for this period', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
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
                        horizontalInterval: 25,
                        getDrawingHorizontalLine: (v) => FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1),
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 25,
                            reservedSize: 32,
                            getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: (scored.length > 10) ? (scored.length / 5).ceilToDouble() : 1,
                            getTitlesWidget: (v, _) {
                              final idx = v.toInt();
                              if (idx < 0 || idx >= scored.length) return const SizedBox.shrink();
                              final d = DateTime.tryParse(scored[idx].date);
                              if (d == null) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(DateFormat('M/d').format(d), style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: const Color(0xFF6366F1),
                          barWidth: 3,
                          dotData: FlDotData(
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
                              colors: [const Color(0xFF6366F1).withOpacity(0.25), const Color(0xFF6366F1).withOpacity(0.0)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        // Average reference line
                        LineChartBarData(
                          spots: [FlSpot(0, avg), FlSpot((scored.length - 1).toDouble(), avg)],
                          isCurved: false,
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          barWidth: 1,
                          dashArray: [6, 4],
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

        // ── Score Distribution ─────────────────────────────────────────────
        if (scored.isNotEmpty) ...[
          _buildDistributionCard(scored),
          const SizedBox(height: 16),
        ],

        // ── Export Button ──────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _exporting ? null : () => _export(records),
            icon: _exporting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.share_rounded, size: 20),
            label: Text(_exporting ? 'Exporting…' : 'Export as CSV'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionCard(List<DerivedSleepData> scored) {
    int excellent = 0, good = 0, fair = 0, poor = 0;
    for (final r in scored) {
      final s = r.finalScore ?? 0;
      if (s >= 85) excellent++;
      else if (s >= 70) good++;
      else if (s >= 50) fair++;
      else poor++;
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
          const Text('Score Distribution', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          _DistBar(label: 'Excellent', count: excellent, total: total, color: const Color(0xFF16A34A)),
          const SizedBox(height: 8),
          _DistBar(label: 'Good', count: good, total: total, color: const Color(0xFF2563EB)),
          const SizedBox(height: 8),
          _DistBar(label: 'Fair', count: fair, total: total, color: const Color(0xFFF59E0B)),
          const SizedBox(height: 8),
          _DistBar(label: 'Poor', count: poor, total: total, color: const Color(0xFFEF4444)),
        ],
      ),
    );
  }
}

// ─── Subwidgets ────────────────────────────────────────────────────────────────

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({required this.label, required this.selected, required this.onTap, this.icon});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0F172A);
    const indigo = Color(0xFF6366F1);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? primary : const Color(0xFFE2E8F0)),
          boxShadow: selected ? [BoxShadow(color: primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 14, color: selected ? Colors.white : indigo), const SizedBox(width: 6)],
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : const Color(0xFF475569))),
          ],
        ),
      ),
    );
  }
}

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

class _DistBar extends StatelessWidget {
  const _DistBar({required this.label, required this.count, required this.total, required this.color});
  final String label;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : count / total;
    return Row(
      children: [
        SizedBox(width: 72, child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500))),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 24,
          child: Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ),
      ],
    );
  }
}
