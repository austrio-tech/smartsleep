// ─────────────────────────────────────────────────────────────────────────────
// theme.dart  –  Global app theme using Material Design 3.
//
// Flutter's theming system lets you define the visual style (colours, fonts,
// shapes, sizes) ONCE here, and it applies automatically to every widget
// throughout the app. No need to hardcode colours in individual screens.
//
// We use Material 3 (useMaterial3: true) — Google's latest design language.
// Font: "Plus Jakarta Sans" from Google Fonts.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Defines the entire visual style of the SmartSleep app.
///
/// All colour and typography constants are defined as static members so
/// other files can reference them (e.g., `AppTheme.secondary` for the
/// indigo colour without duplicating the hex code).
class AppTheme {
  // ── Colour Palette ────────────────────────────────────────────────────────
  // Sleep-themed colours — deep night blue, calm indigo, soft moon gold.
  // Each `const Color(0xFF...)` is an ARGB hex colour:
  //   0xFF = fully opaque (alpha), followed by 6-digit hex RGB

  static const Color primary    = Color(0xFF0F172A); // Deep Night Blue — used for headers, dark surfaces
  static const Color secondary  = Color(0xFF6366F1); // Calm Indigo — accent, buttons, charts
  static const Color accent     = Color(0xFFF59E0B); // Soft Moon Gold — warm highlight colour
  static const Color background = Color(0xFFF8FAFC); // Very light grey — page backgrounds
  static const Color surface    = Colors.white;      // Pure white — cards and dialogs
  static const Color error      = Color(0xFFEF4444); // Red — error messages, failed validations
  static const Color success    = Color(0xFF10B981); // Green — success states

  static const Color textPrimary   = Color(0xFF0F172A); // Dark text for headings
  static const Color textSecondary = Color(0xFF64748B); // Medium grey for body text
  static const Color textTertiary  = Color(0xFF94A3B8); // Light grey for hints/placeholders

  /// Returns the configured light theme for the entire app.
  ///
  /// `ThemeData.light(useMaterial3: true)` creates a base M3 theme, then
  /// `.copyWith(...)` overrides specific parts with our custom values.
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      // ── Colour Scheme ───────────────────────────────────────────────────
      // ColorScheme.fromSeed() generates a harmonious set of colours from
      // our seed colour, then we override specific roles with exact colours.
      colorScheme: ColorScheme.fromSeed(
        seedColor: secondary,
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: surface,
        error: error,
        onPrimary: Colors.white,    // Text/icons on primary colour backgrounds
        onSecondary: Colors.white,  // Text/icons on secondary colour backgrounds
      ),
      scaffoldBackgroundColor: background, // Default page background colour

      // ── Typography ──────────────────────────────────────────────────────
      // TextTheme defines the named text styles used across the app.
      // `GoogleFonts.plusJakartaSansTextTheme()` provides the base styles
      // with the correct font family, then `.copyWith()` adds our sizes/weights.
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        // For large page titles (e.g., "Welcome Back" on login screen)
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1.5,
          color: textPrimary, height: 1.2,
        ),
        // For medium page titles
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -1,
          color: textPrimary,
        ),
        // For section headings
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        // For card titles
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: -0.5,
        ),
        // For smaller section titles
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        // For normal paragraph text
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16, color: textPrimary, height: 1.6,
        ),
        // For secondary/descriptive text
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14, color: textSecondary, height: 1.6,
        ),
        // For button labels
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary,
        ),
      ),

      // ── App Bar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: primary,    // Dark blue header
        foregroundColor: Colors.white,
        elevation: 0,                 // No shadow under the app bar
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
      ),

      // ── Elevated Button (e.g., PrimaryButton widget) ────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 58), // Full width, 58px tall
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.2,
          ),
        ),
      ),

      // ── Outlined Button ─────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(double.infinity, 58),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),

      // ── Text Button (e.g., "Forgot Password?", "Create Account") ────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondary, // Indigo text
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),

      // ── Input Fields (text boxes) ────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        // Border shown when the field is not focused
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        // Border shown when the user is typing in the field
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: secondary, width: 2),
        ),
        // Border shown when validation fails
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: textSecondary, fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: textTertiary, fontWeight: FontWeight.w400,
        ),
        prefixIconColor: textTertiary,
      ),

      // ── Cards ────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,           // No shadow — we use custom Material widgets with elevation instead
        color: surface,
        margin: EdgeInsets.zero, // No default margin; each card controls its own spacing
        clipBehavior: Clip.antiAlias, // Rounded corners clip child content cleanly
      ),

      // ── Dividers ─────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Color(0xFFF1F5F9), // Very subtle light grey divider
        thickness: 1,
        space: 1,
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 10,
        indicatorColor: secondary.withOpacity(0.08), // Soft indigo pill behind active icon
        height: 80,
        // WidgetStateProperty allows different styles for selected/unselected states
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: secondary, size: 26); // Active: indigo, larger
          }
          return const IconThemeData(color: textTertiary, size: 24); // Inactive: grey, smaller
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(
              fontSize: 12, fontWeight: FontWeight.w700, color: secondary,
            );
          }
          return GoogleFonts.plusJakartaSans(
            fontSize: 12, fontWeight: FontWeight.w500, color: textTertiary,
          );
        }),
      ),
    );
  }
}
