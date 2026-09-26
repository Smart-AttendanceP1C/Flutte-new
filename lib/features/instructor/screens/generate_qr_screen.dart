import '../../../core/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_widgets.dart';
import '../data/instructor_models.dart';
import '../state/instructor_controller.dart';
import '../state/session_controller.dart';

/// PAGE 13 — Session QR Code / Generate QR. Matches `13-generate scanner.jpeg`.
/// Real flow only: pick timetable → open session → rotating REAL QR token
/// (10s) → roster log → close. No fake QR.
class GenerateQrScreen extends StatefulWidget {
  const GenerateQrScreen({super.key});

  @override
  State<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends State<GenerateQrScreen> {
  int _tab = 0;
  TimetableEntry? _picked;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstructorController>().load();
    });
  }

  Future<void> _generate() async {
    final session = context.read<SessionController>();
    if (session.session != null) {
      await session.refreshQr();
      await session.loadRoster();
      return;
    }
    final t = _picked ??
        context.read<InstructorController>().timetable.firstOrNull;
    if (t == null) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(context.tr('no_timetable_assigned')),
        ),
      );
      return;
    }
    final ok = await session.open(t.id);
    if (!mounted) return;
    if (!ok) {
      final lang = Localizations.localeOf(context).languageCode;
      final messenger = ScaffoldMessenger.of(context);
      final err = session.error;
      messenger.showSnackBar(
        SnackBar(
            content: Text(err != null
                ? S.code(lang, err)
                : S.code(lang, 'close_failed'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final boot = context.watch<InstructorController>();
    final session = context.watch<SessionController>();
    final timetable = boot.timetable;
    _picked ??= timetable.isNotEmpty ? timetable.first : null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 190,
            pinned: true,
            backgroundColor: AppColors.instructorSky,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.instructorSky,
                padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          context.tr('instructor_portal'),
                          style: AppFonts.sans(
                            size: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      context.tr('smart_attendance'),
                      style: AppFonts.serif(
                        size: 28,
                        weight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('active_course'),
                                  style: AppFonts.sans(
                                    size: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<TimetableEntry>(
                                    value: _picked,
                                    dropdownColor:
                                        AppColors.instructorSkyDark,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                    items: timetable
                                        .map(
                                          (t) => DropdownMenuItem(
                                            value: t,
                                            child: Text(
                                              '${t.courseCode}: ${t.courseName}',
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) => setState(() {
                                      _picked = v;
                                      session.reset();
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.successDot,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.tr('live'),
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.chipBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TabChip(
                            label: context.tr('gen_qr'),
                            selected: _tab == 0,
                            onTap: () => setState(() => _tab = 0),
                          ),
                        ),
                        Expanded(
                          child: _TabChip(
                            label:
                                context.tr('log_tab', {'n': '${session.roster.length}'}),
                            selected: _tab == 1,
                            onTap: () => setState(() => _tab = 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_tab == 0) ...[
                    AppCard(
                      radius: 24,
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.chipBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lock_outline,
                                  size: 14,
                                  color: AppColors.primaryBlue,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  context.tr('access_only'),
                                  style: AppFonts.mono(
                                    size: 11,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.tr('session_qr'),
                            style: AppFonts.serif(
                              size: 24,
                              weight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr('scan_to_mark'),
                            style: TextStyle(
                              color: AppColors.instructorSky,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (session.working)
                            const SizedBox(
                              height: 220,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (session.qr != null)
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.borderMid,
                                    ),
                                  ),
                                  child: QrImageView(
                                    data: session.qr!.token,
                                    version: QrVersions.auto,
                                    size: 210,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Session #${session.session?.id} • ${session.qr!.rotationSec}s',
                                  style: AppFonts.mono(size: 10),
                                ),
                                Text(
                                  'Expires: ${session.qr!.expiresAt}',
                                  style: AppFonts.mono(
                                    size: 9,
                                    color: AppColors.textFaint,
                                  ),
                                ),
                              ],
                            )
                          else
                            Container(
                              height: 220,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.borderMid,
                                  style: BorderStyle.solid,
                                ),
                                color: AppColors.lightBg,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.qr_code_2,
                                      size: 44,
                                      color: AppColors.borderMid,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      session.session == null
                                          ? context.tr('tap_generate')
                                          : context.tr('no_qr_yet'),
                                      textAlign: TextAlign.center,
                                      style: AppFonts.mono(
                                        color: AppColors.textFaint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (session.error != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              context.tr(session.error!),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Text(
                            session.qr == null
                                ? context.tr('qr_expires_once')
                                : context.tr('qr_expires', {'n': '${session.qr!.rotationSec}'}),
                            style: const TextStyle(
                              color: AppColors.instructorSky,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 58,
                      child: ElevatedButton(
                        onPressed:
                            session.working ? null : _generate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.instructorSky,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          session.session == null
                              ? context.tr('gen_qr_code')
                              : context.tr('refresh_qr'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                    if (session.session != null) ...[
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: session.working
                            ? null
                            : () async {
                                final lang =
                                    Localizations.localeOf(context)
                                        .languageCode;
                                final messenger =
                                    ScaffoldMessenger.of(context);
                                final sid =
                                    '${session.session?.id}';
                                final okMsg = S.code(
                                    lang, 'session_closed_msg',
                                    {'id': sid});
                                final failBase = S.code(
                                    lang, 'close_failed');
                                final ok =
                                    await session.close();
                                if (!mounted) return;
                                final err = session.error;
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(ok
                                        ? okMsg
                                        : (err != null
                                            ? S.code(lang, err)
                                            : failBase)),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.stop_circle_outlined),
                        label: Text(
                          context.tr('close_session', {'id': '${session.session?.id}'}),
                          style: AppFonts.mono(
                            color: AppColors.primaryDark,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize:
                              const Size.fromHeight(50),
                        ),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton(
                        onPressed: () => session.reset(),
                        style: OutlinedButton.styleFrom(
                          minimumSize:
                              const Size.fromHeight(46),
                        ),
                        child: Text(context.tr('start_over')),
                      ),
                    ],
                  ] else ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.session == null
                                ? context.tr('no_open_session')
                                : 'Session #${session.session?.id} • ${session.checkedIn}/${session.roster.length} checked in',
                            style: AppFonts.mono(
                              size: 11,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (session.roster.isEmpty)
                            Text(
                              context.tr('log_empty'),
                              style: AppFonts.mono(
                                color: AppColors.textMid,
                              ),
                            )
                          else
                            ...session.roster.map(
                              (r) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.chipBg,
                                  child: Text(
                                    r.studentName.isNotEmpty
                                        ? r.studentName[0]
                                        : '?',
                                    style: const TextStyle(
                                      color:
                                          AppColors.primaryDark,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  r.studentName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                subtitle: Text(
                                  '${r.studentCode} • ${r.attendanceStatus}',
                                  style: AppFonts.mono(size: 10),
                                ),
                                trailing: Text(
                                  r.scannedAt ?? '',
                                  style: AppFonts.mono(size: 9),
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () =>
                                session.loadRoster(),
                            icon: const Icon(Icons.refresh, size: 16),
                            label: Text(context.tr('refresh_log')),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: selected
                ? AppColors.primaryDark
                : AppColors.textFaint,
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
