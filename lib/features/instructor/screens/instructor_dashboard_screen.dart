import '../../../core/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_widgets.dart';
import '../state/instructor_controller.dart';

/// PAGE 12 — Instructor Dashboard. Matches `12-instrucror dashboard.jpeg`.
/// All numbers come from REAL endpoints (my sections/timetable/roster/
/// correction queue/records), scoped to MY sections. Never university-wide
/// fakes. Admin-only imports have no UI here (documented).
class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({super.key});

  @override
  State<InstructorDashboardScreen> createState() =>
      _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState
    extends State<InstructorDashboardScreen> {
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.fingerprint,
              color: AppColors.primaryDark,
              size: 22,
            ),
            const SizedBox(width: 6),
            Text(
              context.tr('smart_attendance'),
              style: AppFonts.serif(
                size: 18,
                weight: FontWeight.w800,
                color: AppColors.heading(context),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.heading(context),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                context.tr('admin_console'),
                style: AppFonts.mono(
                  size: 9,
                  weight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.sensors, color: AppColors.primaryDark, size: 20),
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (c.loading && c.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.error != null && c.profile == null) {
            return _ErrorState(
              message: context.tr(c.error!),
              onRetry: () => c.refresh(),
            );
          }
          final p = c.profile;
          final sections = c.sections;
          final pending = c.pending.length;
          final initials = _initials(p?.name ?? '');
          return RefreshIndicator(
            onRefresh: () => c.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        context.tr('system_live'),
                        style: AppFonts.mono(
                          size: 10,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.tr('sections_assigned',
                            {'n': '${sections.length}'}),
                        style: AppFonts.mono(size: 10),
                      ),
                      const Spacer(),
                      Text(
                        context.tr('my_scope'),
                        style: AppFonts.mono(size: 9),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.paleBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.borderMid,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initials,
                            style: AppFonts.serif(
                              size: 18,
                              weight: FontWeight.w800,
                              color: AppColors.heading(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p?.name ?? '—',
                                style: AppFonts.serif(
                                  size: 17,
                                  weight: FontWeight.w800,
                                  color: AppColors.ink(context),
                                ),
                              ),
                              Text(
                                '${_roleLabel(p?.role)}'
                                '${p != null && p.staffCode.isNotEmpty ? ' • ${p.staffCode}' : ''}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMid,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.more_vert,
                          color: AppColors.ink(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        context.tr('today_pulse'),
                        style: AppFonts.serif(
                          size: 18,
                          weight: FontWeight.w800,
                          color: AppColors.ink(context),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        context.tr('my_sections'),
                        style: AppFonts.mono(
                          size: 10,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _PulseCard(
                          label: context.tr('my_sections_card'),
                          value: '${sections.length}',
                          sub: sections.isEmpty
                              ? context.tr('no_sections_assigned')
                              : sections
                                  .take(2)
                                  .map((s) => s.courseCode)
                                  .join(', '),
                          subColor: AppColors.success,
                          icon: Icons.group_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PulseCard(
                          label: context.tr('scheduled'),
                          value: '${c.timetable.length}',
                          sub: context.tr('this_week'),
                          subColor: AppColors.success,
                          icon: Icons.meeting_room_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _PulseCard(
                          label: context.tr('pending_reviews'),
                          value: '$pending',
                          sub: pending == 0
                              ? context.tr('queue_clear')
                              : context.tr('need_signoff'),
                          subColor: pending == 0
                              ? AppColors.success
                              : AppColors.warning,
                          icon: Icons.flag_outlined,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.instructorReports,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PulseCard(
                          label: context.tr('corrections'),
                          value: '$pending',
                          sub: pending == 0
                              ? context.tr('none_pending')
                              : context.tr('view_queue'),
                          subColor: AppColors.danger,
                          icon: Icons.fact_check_outlined,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.instructorReports,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        context.tr('monitoring'),
                        style: AppFonts.serif(
                          size: 17,
                          weight: FontWeight.w800,
                          color: AppColors.heading(context),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.successDot,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (c.timetable.isEmpty)
                    AppCard(
                      child: Text(
                        context.tr('no_timetable'),
                        style: AppFonts.mono(
                          size: 11,
                          color: AppColors.textMid,
                        ),
                      ),
                    )
                  else
                    ...c.timetable.take(4).map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${t.courseCode} • ${t.courseName}',
                                          style: AppFonts.serif(
                                            size: 14,
                                            weight: FontWeight.w800,
                                            color: AppColors.ink(context),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.successBg,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          t.dayOfWeek,
                                          style: AppFonts.mono(
                                            size: 9,
                                            color: AppColors.success,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${t.roomName} ${t.building} • ${t.startTime}–${t.endTime}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMid,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        t.sectionCode,
                                        style: AppFonts.mono(
                                          size: 10,
                                          color: AppColors.heading(context),
                                        ),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          AppRoutes
                                              .instructorGenerateQr,
                                        ),
                                        child: Text(
                                          context.tr('open_session'),
                                          style: AppFonts.mono(
                                            size: 10,
                                            weight: FontWeight.w700,
                                            color:
                                                AppColors.primaryBlue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('access_records'),
                    style: AppFonts.serif(
                      size: 17,
                      weight: FontWeight.w800,
                      color: AppColors.heading(context),
                    ),
                  ),
                  Text(
                    context.tr('assigned_sections'),
                    style: AppFonts.mono(size: 10),
                  ),
                  const SizedBox(height: 10),
                  if (sections.isEmpty)
                    AppCard(
                      child: Text(
                        context.tr('no_sections_assigned'),
                        style: AppFonts.mono(
                          size: 11,
                          color: AppColors.textMid,
                        ),
                      ),
                    )
                  else
                    ...sections.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.chipBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  s.courseCode.length >= 2
                                      ? s.courseCode.substring(0, 2)
                                      : s.courseCode,
                                  style: AppFonts.mono(
                                    size: 12,
                                    weight: FontWeight.w800,
                                    color: AppColors.heading(context),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.courseCode,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '${s.courseName} • ${s.sectionCode}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMid,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.instructorReports,
                                ),
                                child: Text(
                                  context.tr('view'),
                                  style: AppFonts.mono(
                                    size: 11,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.tr('add_admin_msg'),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add_outlined),
                    label: Text(context.tr('add_admin_only')),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '—';
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
        return 'Teaching Assistant';
      case 'admin':
        return 'Admin';
      default:
        return role ?? '';
    }
  }
}

class _PulseCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color subColor;
  final IconData icon;
  final VoidCallback? onTap;
  const _PulseCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.subColor,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label, style: AppFonts.mono(size: 9)),
                ),
                Icon(icon, size: 16, color: AppColors.textMid),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppFonts.serif(
                size: 26,
                weight: FontWeight.w800,
                color: AppColors.heading(context),
              ),
            ),
            Text(
              sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.mono(size: 9, color: subColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.danger),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(context.tr('retry')),
            ),
          ],
        ),
      ),
    );
  }
}
