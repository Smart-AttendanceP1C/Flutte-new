import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../instructor/state/instructor_controller.dart';
import '../../instructor/state/risk_controllers.dart';
import '../../instructor/state/session_controller.dart';
import '../../student/state/correction_controller.dart';
import '../../student/state/history_controller.dart';
import '../../student/state/scan_controller.dart';
import '../../student/state/student_home_controller.dart';
import '../state/auth_state.dart';

/// PAGE 15 — Log Out confirmation. Matches `15-log out.jpeg` (rebranded to
/// Smart Attendance, neutral wording — no beacon/proximity copy).
class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  bool _remember = true;

  Future<void> _logout() async {
    // Capture controllers synchronously (before the async gap), then clear
    // auth + persisted JWT and drop cached protected state so the next
    // account never sees stale records. Navigation clears the stack
    // (required for logout only — normal back keeps history).
    final auth = context.read<AuthState>();
    final studentHome = context.read<StudentHomeController>();
    final history = context.read<HistoryController>();
    final scan = context.read<ScanController>();
    final corrections = context.read<CorrectionController>();
    final instructor = context.read<InstructorController>();
    final sessions = context.read<SessionController>();
    final risk = context.read<RiskController>();
    final queue = context.read<CorrectionQueueController>();
    await auth.logout();
    if (!mounted) return;
    studentHome.reset();
    history.reset();
    scan.clear();
    corrections.reset();
    instructor.reset();
    sessions.reset();
    risk.reset();
    queue.reset();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final name = auth.isAuthenticated
        ? auth.displayName
        : context.tr('signed_out');
    final id = auth.isAuthenticated ? auth.userCode : '';
    final dept = auth.role ?? '';
    final initials = _initials(name);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.fingerprint,
              color: AppColors.primaryDark,
              size: 26,
            ),
            const SizedBox(width: 8),
            Text(
              context.tr('smart_attendance'),
              style: AppFonts.serif(
                size: 20,
                weight: FontWeight.w800,
                color: AppColors.heading(context),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sensors,
                  size: 14,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 4),
                Text(
                  context.tr('live'),
                  style: AppFonts.mono(
                    size: 11,
                    weight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.paleBlue,
                          border: Border.all(color: AppColors.borderMid),
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          size: 36,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.dangerBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.logout,
                            size: 14,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('logout_title'),
                    textAlign: TextAlign.center,
                    style: AppFonts.serif(
                      size: 24,
                      weight: FontWeight.w800,
                      color: AppColors.ink(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.paleBlue,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.avatarNavy,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: AppFonts.serif(
                                  size: 17,
                                  weight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              Text(
                                dept,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMid,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.borderMid,
                            ),
                          ),
                          child: Text(
                            id,
                            style: AppFonts.mono(
                              size: 11,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('account'),
                          style: AppFonts.mono(size: 10),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          auth.role ?? '—',
                          style: AppFonts.serif(
                            size: 20,
                            weight: FontWeight.w800,
                            color: AppColors.ink(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.email,
                          style: AppFonts.mono(
                            size: 10,
                            color: AppColors.textMid,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('status_lbl'),
                          style: AppFonts.mono(size: 10),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          auth.isAuthenticated
                              ? context.tr('signed_in')
                              : context.tr('signed_out'),
                          style: AppFonts.serif(
                            size: 20,
                            weight: FontWeight.w800,
                            color: AppColors.ink(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr('token_cleared'),
                          style: AppFonts.mono(
                            size: 10,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.chipBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('security_title'),
                          style: AppFonts.mono(
                            size: 12,
                            weight: FontWeight.w700,
                            color: AppColors.heading(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr('security_body'),
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMid,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.badge_outlined,
                    color: AppColors.textMid,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('remember_id'),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.ink(context),
                          ),
                        ),
                        Text(
                          context.tr('quick_login'),
                          style: AppFonts.mono(size: 10),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _remember,
                    activeThumbColor: AppColors.primaryBlue,
                    onChanged: (v) => setState(() => _remember = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: Text(
                  context.tr('yes_logout'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.logoutNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: context.tr('stay'),
              onPressed: () => Navigator.maybePop(context),
              outline: true,
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('app_core'),
              style: AppFonts.mono(size: 10),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '…';
    if (parts.length == 1) {
      return parts.first.length >= 2
          ? parts.first.substring(0, 2).toUpperCase()
          : parts.first.toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
