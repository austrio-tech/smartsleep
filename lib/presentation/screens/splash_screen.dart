// ─────────────────────────────────────────────────────────────────────────────
// splash_screen.dart  –  Animated launch screen shown while checking auth state.
//
// Displayed for ~2 seconds while:
//   1. The animation plays (logo fades and scales in)
//   2. The auth provider checks for a stored JWT token
//
// After the auth check completes, main.dart's ref.listen automatically
// navigates to either the Home screen (authenticated) or Login screen.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The animated splash/launch screen.
///
/// Uses [ConsumerStatefulWidget] instead of [StatefulWidget] because it
/// needs access to the Riverpod [WidgetRef] — though in this case it
/// actually doesn't read any providers (auth navigation is handled in main.dart).
/// ConsumerStatefulWidget is kept here for consistency and potential future needs.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  // AnimationController drives all animations — it's the "clock" that ticks.
  // SingleTickerProviderStateMixin provides the vsync (synchronises with screen refresh).
  late AnimationController _controller;

  // Two separate animations driven by the same controller at different intervals
  late Animation<double> _fadeAnimation;   // Opacity: invisible → visible
  late Animation<double> _scaleAnimation;  // Size: small → full size

  @override
  void initState() {
    super.initState();

    // Create the animation controller with a 2-second total duration
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Fade animation: runs during the first 60% of the animation (0ms to 1200ms)
    // Interval(0.0, 0.6) means "play from 0% to 60% of the total duration"
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Scale animation: logo starts at 80% size and grows to 100%
    // Curves.easeOutBack adds a slight "overshoot" bounce effect
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Start the animation playing forward
    _controller.forward();
  }

  @override
  void dispose() {
    // Always dispose animation controllers to prevent memory leaks.
    // dispose() is called when this widget is removed from the widget tree.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Subtle gradient background — light at top, slightly tinted at bottom
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.8),
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        // AnimatedBuilder efficiently rebuilds only what changes as the animation plays
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,  // Apply opacity animation
              child: ScaleTransition(
                scale: _scaleAnimation, // Apply scale animation
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo asset
                    Image.asset(
                      'lib/SmartSleepLogo.png',
                      height: 180,
                      width: 180,
                    ),
                    const SizedBox(height: 48),
                    // Thin loading progress bar below the logo
                    SizedBox(
                      width: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          // Subtle progress indicator — very low opacity so it's not distracting
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary.withOpacity(0.4),
                          ),
                          minHeight: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
