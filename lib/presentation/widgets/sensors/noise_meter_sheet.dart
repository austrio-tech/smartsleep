import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/sensor_utils.dart';

enum _Phase { requesting, measuring, done, error }

/// Bottom sheet that measures ambient noise using the device microphone.
///
/// Samples the microphone for [_sampleSeconds] seconds, averages the dB
/// readings, then returns the clamped result via [Navigator.pop].
///
/// Usage:
/// ```dart
/// final double? value = await showModalBottomSheet<double>(
///   context: context,
///   builder: (_) => const NoiseMeterSheet(),
/// );
/// ```
class NoiseMeterSheet extends StatefulWidget {
  const NoiseMeterSheet({super.key});

  @override
  State<NoiseMeterSheet> createState() => _NoiseMeterSheetState();
}

class _NoiseMeterSheetState extends State<NoiseMeterSheet>
    with SingleTickerProviderStateMixin {
  static const int _sampleSeconds = 4;

  _Phase _phase = _Phase.requesting;
  String _errorMessage = '';
  double _liveDb = 0;
  double _measuredDb = 0;

  StreamSubscription<NoiseReading>? _noiseSub;
  Timer? _sampleTimer;
  final List<double> _readings = [];
  int _elapsedSeconds = 0;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _requestAndStart();
  }

  @override
  void dispose() {
    _noiseSub?.cancel();
    _sampleTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestAndStart() async {
    final status = await Permission.microphone.request();
    if (!mounted) return;
    if (status.isGranted) {
      _startMeasuring();
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _phase = _Phase.error;
        _errorMessage = 'Microphone permission permanently denied.\nOpen app settings to enable it.';
      });
    } else {
      setState(() {
        _phase = _Phase.error;
        _errorMessage = 'Microphone permission is required to measure noise.';
      });
    }
  }

  void _startMeasuring() {
    _readings.clear();
    _elapsedSeconds = 0;
    setState(() => _phase = _Phase.measuring);

    _noiseSub = NoiseMeter().noise.listen(
      (NoiseReading reading) {
        if (!mounted) return;
        final db = reading.meanDecibel;
        if (db.isFinite && !db.isNaN) {
          _readings.add(db);
          setState(() => _liveDb = db);
        }
      },
      onError: (_) {
        if (mounted) {
          setState(() {
            _phase = _Phase.error;
            _errorMessage = 'Could not access microphone. Please try again.';
          });
        }
      },
    );

    _sampleTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
      if (_elapsedSeconds >= _sampleSeconds) {
        t.cancel();
        _finishMeasuring();
      }
    });
  }

  void _finishMeasuring() {
    _noiseSub?.cancel();
    _noiseSub = null;
    if (_readings.isEmpty) {
      setState(() {
        _phase = _Phase.error;
        _errorMessage = 'No audio data captured. Please try again.';
      });
      return;
    }
    final avg = _readings.reduce((a, b) => a + b) / _readings.length;
    setState(() {
      _measuredDb = clampNoise(avg);
      _phase = _Phase.done;
    });
  }

  void _remeasure() {
    _noiseSub?.cancel();
    _sampleTimer?.cancel();
    _readings.clear();
    _startMeasuring();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // drag handle
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Measuring Noise Level',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              _phase == _Phase.measuring
                  ? 'Hold still — sampling for $_sampleSeconds seconds'
                  : 'Your bedroom noise level',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            _buildBody(),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_phase) {
      case _Phase.requesting:
        return const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        );

      case _Phase.measuring:
        return Column(
          children: [
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic_rounded, size: 38, color: Color(0xFF6366F1)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${_liveDb.toStringAsFixed(0)} dB',
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _elapsedSeconds / _sampleSeconds,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$_elapsedSeconds s / $_sampleSeconds s',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        );

      case _Phase.done:
        return Column(
          children: [
            const Icon(Icons.check_circle_rounded, size: 48, color: Color(0xFF16A34A)),
            const SizedBox(height: 12),
            Text(
              '${_measuredDb.toStringAsFixed(0)} dB',
              style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 6),
            Text(
              noiseLabel(_measuredDb),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case _Phase.error:
        return Column(
          children: [
            const Icon(Icons.mic_off_rounded, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            if (_errorMessage.contains('settings')) ...[
              const SizedBox(height: 12),
              const TextButton(
                onPressed: openAppSettings,
                child: Text('Open App Settings'),
              ),
            ],
          ],
        );
    }
  }

  Widget _buildActions() {
    switch (_phase) {
      case _Phase.requesting:
      case _Phase.measuring:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        );

      case _Phase.done:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _remeasure,
                child: const Text('Remeasure'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(context, _measuredDb),
                child: const Text('Use This Value'),
              ),
            ),
          ],
        );

      case _Phase.error:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        );
    }
  }
}
