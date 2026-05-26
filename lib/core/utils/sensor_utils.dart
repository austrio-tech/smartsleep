import 'dart:math';

/// Clamps a raw dB reading to the slider range used in the app (30–100).
double clampNoise(double db) => db.clamp(30.0, 100.0);

/// Clamps a lux estimate to the slider range used in the app (0–300).
double clampLux(double lux) => lux.clamp(0.0, 300.0);

/// Maps average camera luminance (0–255 Y-plane) to approximate lux (0–300).
///
/// Uses a power curve so dark rooms (low Y) map to very low lux and bright
/// rooms compress toward the 300 lux ceiling. This is a calibrated
/// approximation — camera sensors vary, so the result is indicative, not lab-grade.
double brightnessToLux(double avgY) {
  if (avgY <= 0) return 0;
  return 300.0 * pow(avgY / 255.0, 2.2);
}

/// Short descriptive label for a noise level (dB).
String noiseLabel(double db) {
  if (db < 40) return 'Quiet — ideal for sleep';
  if (db < 55) return 'Moderate — manageable';
  if (db < 70) return 'Loud — may affect sleep';
  return 'Very loud — likely disruptive';
}

/// Short descriptive label for a light level (lux).
String luxLabel(double lux) {
  if (lux < 10) return 'Very dark — ideal for sleep';
  if (lux < 50) return 'Dim — acceptable';
  if (lux < 150) return 'Moderately lit';
  return 'Bright — may disrupt sleep';
}
