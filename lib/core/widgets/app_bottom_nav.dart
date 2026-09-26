import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';

TextStyle _selLabel() => const TextStyle(
      fontFamily: 'RobotoMono',
      fontSize: 11,
      fontWeight: FontWeight.w700,
    );

TextStyle _unselLabel() => const TextStyle(
      fontFamily: 'RobotoMono',
      fontSize: 11,
    );

/// Shared bottom navigation for the student shell (3 items — no telemetry).
class StudentBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const StudentBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor:
          dark ? const Color(0xFF101527) : Colors.white,
      selectedItemColor:
          dark ? const Color(0xFF7FA8FF) : AppColors.primaryBlue,
      unselectedItemColor: AppColors.textFaint,
      selectedLabelStyle: _selLabel(),
      unselectedLabelStyle: _unselLabel(),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.timer_outlined),
          activeIcon: const Icon(Icons.timer),
          label: context.tr('nav_checkin'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.history_outlined),
          activeIcon: const Icon(Icons.history),
          label: context.tr('nav_logs'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.badge_outlined),
          activeIcon: const Icon(Icons.badge),
          label: context.tr('nav_profile'),
        ),
      ],
    );
  }
}

/// Shared bottom navigation for the instructor shell.
class InstructorBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const InstructorBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor:
          dark ? const Color(0xFF101527) : Colors.white,
      selectedItemColor:
          dark ? const Color(0xFF7FA8FF) : AppColors.primaryBlue,
      unselectedItemColor: AppColors.textFaint,
      selectedLabelStyle: _selLabel(),
      unselectedLabelStyle: _unselLabel(),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: context.tr('nav_home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.qr_code_2_outlined),
          activeIcon: const Icon(Icons.qr_code_2),
          label: context.tr('nav_qr'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.assessment_outlined),
          activeIcon: const Icon(Icons.assessment),
          label: context.tr('nav_reports'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: context.tr('nav_menu'),
        ),
      ],
    );
  }
}
