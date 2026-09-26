import '../../../core/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_widgets.dart';
import '../state/instructor_controller.dart';

/// PAGE 03 — Instructor Menu. Matches `3-instructor menu.jpeg` (rebranded).
/// Profile/stats/badges come from the REAL backend. Every row navigates.
class InstructorMenuScreen extends StatefulWidget {
  const InstructorMenuScreen({super.key});

  @override
  State<InstructorMenuScreen> createState() => _InstructorMenuScreenState();
}

class _InstructorMenuScreenState extends State<InstructorMenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstructorController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<InstructorController>();
    final name = c.profile?.name ?? '…';
    final code = c.profile?.staffCode ?? '';
    final roleLabel = _roleLabel(c.profile?.role);
    final initials = _initials(name);
    final sections = c.sections.length;
    final pending = c.pending.length;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.paleBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.fingerprint,
            color: AppColors.primaryDark,
            size: 20,
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                context.tr('smart_attendance'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: AppFonts.serif(
                  size: 20,
                  weight: FontWeight.w800,
                  color: AppColors.heading(context),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.paleBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                context.tr('faculty'),
                style: AppFonts.mono(
                  size: 10,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: AppColors.ink(context)),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.instructorDashboard,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.avatarNavy,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.successDot,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  name,
                                  style: AppFonts.serif(
                                    size: 17,
                                    weight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.settings_outlined,
                                  size: 16,
                                  color: AppColors.textMid,
                                ),
                              ],
                            ),
                            Text(
                              roleLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMid,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              code.isEmpty ? 'Loading profile…' : 'ID: $code',
                              style: AppFonts.mono(
                                size: 10,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.more_vert,
                        color: AppColors.textDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _HeadStat(
                          label: context.tr('my_sections'),
                          value: '$sections',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HeadStat(
                          label: context.tr('timetable'),
                          value: '${c.timetable.length}',
                          valueColor: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HeadStat(
                          label: context.tr('pending'),
                          value: '$pending',
                          valueColor: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionHeader(
              title: context.tr('attendance_tools'),
              actionLabel: context.tr('session_live'),
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.successDot,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  context.tr('session_live'),
                                  style: AppFonts.mono(
                                    size: 9,
                                    weight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.qr_code_2,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('qr_generate'),
                        style: AppFonts.serif(
                          size: 20,
                          weight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('qr_generate_sub'),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              context.tr('token_rotation'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: AppFonts.mono(
                                size: 10,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.instructorGenerateQr,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryDark,
                              // Compact pill button: needs a finite minimum
                              // width of its own. The app theme sets
                              // minimumSize to Size.fromHeight(56) (infinite
                              // min width, meant for full-width buttons), so
                              // without this override this button — measured
                              // with unbounded width as a Row child — throws
                              // "BoxConstraints forces an infinite width" and
                              // takes down the whole screen layout.
                              minimumSize: const Size(64, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(context.tr('launch')),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            MenuTile(
              icon: Icons.grid_view,
              title: context.tr('lecturer_dashboard'),
              subtitle: context.tr('lecturer_dashboard_sub'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      context.tr('live'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textFaint,
                  ),
                ],
              ),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.instructorDashboard,
              ),
            ),
            const SizedBox(height: 10),
            MenuTile(
              icon: Icons.playlist_add_check_outlined,
              title: context.tr('manual_correction'),
              subtitle: context.tr('manual_correction_sub'),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.instructorManual,
              ),
            ),
            const SizedBox(height: 16),
            SectionHeader(title: context.tr('academic_mgmt')),
            const SizedBox(height: 8),
            MenuTile(
              icon: Icons.book_outlined,
              title: context.tr('courses_sections'),
              subtitle: context.tr('courses_sections_sub'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$sections Active', style: AppFonts.mono(size: 10)),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textFaint,
                  ),
                ],
              ),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.instructorDashboard,
              ),
            ),
            const SizedBox(height: 10),
            MenuTile(
              icon: Icons.mark_email_unread_outlined,
              title: context.tr('correction_requests'),
              subtitle: context.tr('correction_requests_sub'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$pending Pending',
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textFaint,
                  ),
                ],
              ),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.instructorCorrections,
              ),
            ),
            const SizedBox(height: 16),
            SectionHeader(title: context.tr('system_support')),
            const SizedBox(height: 8),
            MenuTile(
              icon: Icons.admin_panel_settings_outlined,
              title: context.tr('admin_mgmt'),
              subtitle: context.tr('admin_mgmt_sub'),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.instructorDashboard,
              ),
            ),
            const SizedBox(height: 10),
            MenuTile(
              icon: Icons.help_outline,
              title: context.tr('support_desk'),
              subtitle: context.tr('support_desk_sub'),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.support,
              ),
            ),
            const SizedBox(height: 10),
            MenuTile(
              icon: Icons.palette_outlined,
              title: context.tr('appearance'),
              subtitle:
                  '${context.tr('theme_system')} / ${context.tr('language')}',
              onTap: () => AppearanceSheet.show(context),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.instructorDashboard,
              ),
              icon: const Icon(Icons.arrow_back),
              label: Text(context.tr('close_dashboard')),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: context.tr('logout'),
              icon: Icons.logout,
              outline: true,
              danger: true,
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.logout,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('app_core'),
              textAlign: TextAlign.center,
              style: AppFonts.mono(size: 9),
            ),
          ],
        ),
      ),
    );
  }
}

String _initials(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty || name == '…') return '…';
  if (parts.length == 1) {
    return parts.first.length >= 2
        ? parts.first.substring(0, 2).toUpperCase()
        : parts.first.toUpperCase();
  }
  return (parts[0][0] + parts[1][0]).toUpperCase();
}

String _roleLabel(String? role) {
  switch (role) {
    case 'lecturer':
      return 'Lecturer';
    case 'ta':
      return 'TA';
    case 'admin':
      return 'Admin';
    case null:
      return '…';
    default:
      return role;
  }
}

class _HeadStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _HeadStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.tileBg(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppFonts.mono(size: 8, color: AppColors.textMid),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: valueColor ?? AppColors.heading(context),
            ),
          ),
        ],
      ),
    );
  }
}
