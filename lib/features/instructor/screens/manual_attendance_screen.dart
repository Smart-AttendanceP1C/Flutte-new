import '../../../core/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_widgets.dart';
import '../state/session_controller.dart';

/// Manual Attendance Correction — real roster + real PATCH update.
/// Requires an open session (created in Generate QR). Session must be
/// `open`; backend enforces opener + assigned-staff + reason-required.
class ManualAttendanceScreen extends StatelessWidget {
  const ManualAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.heading(context),
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          context.tr('manual_title'),
          style: AppFonts.serif(
            size: 19,
            weight: FontWeight.w800,
            color: AppColors.heading(context),
          ),
        ),
        centerTitle: true,
      ),
      body: Builder(
        builder: (_) {
          if (session.session == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.playlist_add_check_outlined,
                      size: 48,
                      color: AppColors.textFaint,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('manual_none'),
                      style: AppFonts.serif(
                        size: 19,
                        weight: FontWeight.w800,
                        color: AppColors.ink(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr('manual_none_d'),
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: AppColors.textMid),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: context.tr('open_gen_qr'),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.instructorGenerateQr,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          if (session.roster.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (session.error != null)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        context.tr(session.error!),
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: AppColors.danger),
                      ),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => session.loadRoster(),
                    child: Text(context.tr('load_roster')),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: session.roster.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final r = session.roster[i];
              return AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.chipBg,
                      child: Text(
                        r.studentName.isNotEmpty
                            ? r.studentName[0]
                            : '?',
                        style: TextStyle(
                          color: AppColors.heading(context),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.studentName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${r.studentCode} • ${r.attendanceStatus}',
                            style: AppFonts.mono(size: 10),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onSelected: (status) =>
                          _edit(context, session, r.studentId,
                              r.studentName, status),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'present',
                          child: Text(context.tr('mark_present')),
                        ),
                        PopupMenuItem(
                          value: 'absent',
                          child: Text(context.tr('mark_absent')),
                        ),
                        PopupMenuItem(
                          value: 'excused',
                          child: Text(context.tr('mark_excused')),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _edit(
    BuildContext context,
    SessionController session,
    int studentId,
    String name,
    String status,
  ) {
    final reason = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$name • $status'),
        content: TextField(
          controller: reason,
          decoration: InputDecoration(
            labelText: context.tr('reason_required'),
            border: const OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reason.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('reason_empty')),
                  ),
                );
                return;
              }
              Navigator.pop(context);
              final ok = await session.manualUpdate(
                studentId: studentId,
                status: status,
                reason: reason.text.trim(),
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok
                        ? context.tr('attendance_updated')
                        : (session.error != null ? context.tr(session.error!) : context.tr('update_failed')),
                  ),
                ),
              );
            },
            child: Text(context.tr('confirm')),
          ),
        ],
      ),
    );
  }
}
