// ─────────────────────────────────────────────────────────────────────────────
// main_screen.dart  –  Root screen with bottom navigation bar.
//
// This screen acts as a shell/container for the three main tab screens:
//   Tab 0: Home screen
//   Tab 1: Sleep History screen
//   Tab 2: Profile screen
//
// It uses IndexedStack to keep all three screens alive simultaneously.
// Unlike PageView, IndexedStack preserves scroll position and state when
// you switch tabs because all screens remain in memory.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';       // For SystemUiOverlayStyle
import 'home/home_screen.dart';
import 'history/sleep_history_screen.dart';
import 'profile/profile_screen.dart';

/// The main app shell shown after the user logs in.
///
/// Manages the bottom navigation bar and keeps track of which tab is active.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Tracks which tab index is currently selected (0=Home, 1=History, 2=Profile)
  int _currentIndex = 0;

  // All three tab screens are instantiated once and kept alive in memory.
  // `const` widgets are extra efficient — Flutter reuses the same instance.
  final List<Widget> _screens = const [
    HomeScreen(),
    SleepHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // SystemUiOverlayStyle.light makes the status bar icons (time, battery, wifi)
      // appear white — needed when the app bar background is dark.
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // IndexedStack shows only the screen at _currentIndex, but keeps all
        // others in memory (unlike Navigator which destroys off-screen widgets).
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          // When a destination is tapped, update _currentIndex to show that tab
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            // Each destination has outlined (inactive) and filled (active) icons
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
