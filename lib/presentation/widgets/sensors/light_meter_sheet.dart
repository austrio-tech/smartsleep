import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/sensor_utils.dart';

enum _Phase { requesting, initialising, measuring, done, error }

/// Bottom sheet that estimates ambient light using the device camera.
///
/// Opens the front camera (falls back to rear if unavailable), streams frames,
/// and averages the Y-plane (luminance) of each frame to compute approximate lux.
/// Samples for [_sampleFrames] frames then returns the result via [Navigator.pop].
///
/// Usage:
/// ```dart
/// final double? value = await showModalBottomSheet<double>(
///   context: context,
///   builder: (_) => const LightMeterSheet(),
/// );
/// ```
class LightMeterSheet extends StatefulWidget {
  const LightMeterSheet({super.key});

  @override
  State<LightMeterSheet> createState() => _LightMeterSheetState();
}

class _LightMeterSheetState extends State<LightMeterSheet> {
  static const int _sampleFrames = 60;

  _Phase _phase = _Phase.requesting;
  String _errorMessage = '';
  double _liveLux = 0;
  double _measuredLux = 0;
  int _framesCaptured = 0;

  CameraController? _controller;
  final List<double> _luxReadings = [];

  @override
  void initState() {
    super.initState();
    _requestAndStart();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _requestAndStart() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (status.isGranted) {
      await _initCamera();
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _phase = _Phase.error;
        _errorMessage = 'Camera permission permanently denied.\nOpen app settings to enable it.';
      });
    } else {
      setState(() {
        _phase = _Phase.error;
        _errorMessage = 'Camera permission is required to measure light level.';
      });
    }
  }

  Future<void> _initCamera() async {
    setState(() => _phase = _Phase.initialising);
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _phase = _Phase.error;
          _errorMessage = 'No camera found on this device.';
        });
        return;
      }
      // Prefer front camera; fall back to first available
      final selected = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _controller = CameraController(
        selected,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _phase = _Phase.measuring);
      _startStream();
    } catch (e) {
      if (mounted) {
        setState(() {
          _phase = _Phase.error;
          _errorMessage = 'Could not open camera: $e';
        });
      }
    }
  }

  void _startStream() {
    _luxReadings.clear();
    _framesCaptured = 0;
    _controller?.startImageStream((CameraImage image) {
      if (!mounted) return;
      // Y-plane is the luminance channel in YUV420
      final yPlane = image.planes[0];
      final bytes = yPlane.bytes;
      if (bytes.isEmpty) return;

      double sum = 0;
      for (final b in bytes) {
        sum += b;
      }
      final avgY = sum / bytes.length;
      final lux = clampLux(brightnessToLux(avgY));

      _luxReadings.add(lux);
      _framesCaptured++;
      setState(() => _liveLux = lux);

      if (_framesCaptured >= _sampleFrames) {
        _controller?.stopImageStream();
        _finishMeasuring();
      }
    });
  }

  void _finishMeasuring() {
    if (_luxReadings.isEmpty) {
      setState(() {
        _phase = _Phase.error;
        _errorMessage = 'No camera frames captured. Please try again.';
      });
      return;
    }
    final avg = _luxReadings.reduce((a, b) => a + b) / _luxReadings.length;
    setState(() {
      _measuredLux = clampLux(avg);
      _phase = _Phase.done;
    });
  }

  Future<void> _remeasure() async {
    try {
      await _controller?.stopImageStream();
    } catch (_) {}
    _luxReadings.clear();
    _framesCaptured = 0;
    setState(() => _phase = _Phase.measuring);
    _startStream();
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
              'Measuring Light Level',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              _phase == _Phase.measuring
                  ? 'Point camera at your bedroom ceiling or wall'
                  : 'Your bedroom light level',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
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
      case _Phase.initialising:
        return SizedBox(
          height: 120,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(
                  _phase == _Phase.requesting ? 'Requesting permission…' : 'Opening camera…',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );

      case _Phase.measuring:
        final ctrl = _controller;
        return Column(
          children: [
            if (ctrl != null && ctrl.value.isInitialized)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: ctrl.value.previewSize?.height ?? 100,
                      height: ctrl.value.previewSize?.width ?? 100,
                      child: CameraPreview(ctrl),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Text(
              '≈ ${_liveLux.toStringAsFixed(0)} lux',
              style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _framesCaptured / _sampleFrames,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                color: Colors.amber.shade600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sampling… ($_framesCaptured / $_sampleFrames frames)',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        );

      case _Phase.done:
        return Column(
          children: [
            Icon(Icons.light_mode_rounded, size: 52, color: Colors.amber.shade600),
            const SizedBox(height: 12),
            Text(
              '${_measuredLux.toStringAsFixed(0)} lux',
              style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 6),
            Text(
              luxLabel(_measuredLux),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case _Phase.error:
        return Column(
          children: [
            const Icon(Icons.no_photography_rounded, size: 48, color: Color(0xFFEF4444)),
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
      case _Phase.initialising:
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
                onPressed: () => Navigator.pop(context, _measuredLux),
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
