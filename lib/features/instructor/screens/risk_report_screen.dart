import '../../../core/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_widgets.dart';
import '../data/instructor_models.dart';
import '../state/instructor_controller.dart';
import '../state/risk_controllers.dart';

/// PAGE 10 — Attendance Risk / Reports. Matches `10-AI.png` (low-res).
/// Real `GET /staff/me/sections/:sectionId/risk` per section.
/// `unavailable` bands render as-is — never faked.
class RiskReportScreen extends StatefulWidget {
  const RiskReportScreen({super.key});

  @override
  State<RiskReportScreen> createState() => _RiskReportScreenState();
}

class _RiskReportScreenState extends State<RiskReportScreen> {
  String _filter = 'all';
  int? _sectionId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final boot = context.read<InstructorController>();
      await boot.load();
      if (!mounted) return;
      final sections = boot.sections;
      if (sections.isNotEmpty) {
        setState(() => _sectionId = sections.first.id);
        await context.read<RiskController>().load(sections.first.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final boot = context.watch<InstructorController>();
    final risk = context.watch<RiskController>();
    final sections = boot.sections;
    if (_sectionId == null && sections.isNotEmpty) {
      _sectionId = sections.first.id;
    }

    final students = _applyFilter(risk.students);
    final flagged = risk.students.where((s) => s.isFlagged).length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              context.tr('risk_title'),
              style: AppFonts.serif(
                size: 19,
                weight: FontWeight.w800,
                color: AppColors.heading(context),
              ),
            ),
            Text(
              sections.isEmpty
                  ? context.tr('no_sections_assigned')
                  : '${risk.section?['course_code'] ?? ''} • Week ${risk.weekNumber}',
              style: AppFonts.mono(size: 10),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Builder(
        builder: (_) {
          if ((boot.loading || risk.loading) && risk.students.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (risk.error != null && risk.students.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.tr(risk.error!),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _sectionId == null
                          ? null
                          : () => risk.load(_sectionId!, force: true),
                      child: Text(context.tr('retry')),
                    ),
                  ],
                ),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (sections.length > 1)
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: sections.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final s = sections[i];
                        final sel = s.id == _sectionId;
                        return ChoiceChip(
                          label: Text(
                            '${s.courseCode} • ${s.sectionCode}',
                            style: AppFonts.mono(
                              size: 11,
                              weight: FontWeight.w700,
                              color: sel
                                  ? Colors.white
                                  : AppColors.ink(context),
                            ),
                          ),
                          selected: sel,
                          selectedColor: AppColors.primaryDark,
                          onSelected: (_) async {
                            setState(() => _sectionId = s.id);
                            await context
                                .read<RiskController>()
                                .load(s.id, force: true);
                          },
                        );
                      },
                    ),
                  ),
                if (sections.length > 1) const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('risk_notice'),
                        style: AppFonts.mono(
                          size: 10,
                          weight: FontWeight.w800,
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${risk.students.length} students • $flagged flagged • Week ${risk.weekNumber}',
                        style: AppFonts.serif(
                          size: 14,
                          weight: FontWeight.w400,
                          color: AppColors.textMid,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const ['all', 'flagged', 'high', 'medium', 'low']
                        .map(
                          (f) => Padding(
                            padding:
                                const EdgeInsets.only(right: 8),
                            child: _RiskFilterChip(
                              value: f,
                              selected: _filter == f,
                              onTap: () =>
                                  setState(() => _filter = f),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),
                if (students.isEmpty)
                  AppCard(
                    child: Text(
                      'No students match this filter.',
                      style: AppFonts.mono(
                        color: AppColors.textMid,
                      ),
                    ),
                  )
                else
                  ...students.map((s) => _RiskRow(
                        student: s,
                        onTap: () => _openStudent(context, s),
                      )),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  List<RiskStudent> _applyFilter(List<RiskStudent> all) {
    switch (_filter) {
      case 'flagged':
        return all.where((s) => s.isFlagged).toList();
      case 'high':
        return all
            .where((s) =>
                s.riskBand.toLowerCase().contains('high') &&
                !s.riskBand.toLowerCase().contains('very'))
            .toList();
      case 'medium':
        return all
            .where((s) => s.riskBand.toLowerCase().contains('medium'))
            .toList();
      case 'low':
        return all
            .where((s) => s.riskBand.toLowerCase().contains('low'))
            .toList();
      default:
        return all;
    }
  }

  void _openStudent(BuildContext context, RiskStudent s) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.name,
              style: AppFonts.serif(
                size: 19,
                weight: FontWeight.w800,
                color: AppColors.ink(context),
              ),
            ),
            Text(
              '${s.studentCode} • ${s.riskBand} • ${s.riskPercentage?.toStringAsFixed(1) ?? '—'}%',
              style: AppFonts.mono(size: 11),
            ),
            const SizedBox(height: 10),
            if (s.features != null)
              Text(
                'Rate: ${s.features!['attendance_rate_to_date']} • '
                'Trend: ${s.features!['trend_last_3']} • '
                'Consecutive absences: ${s.features!['consecutive_absences']} • '
                'Load: ${s.features!['course_load']} • '
                'Rejected: ${s.features!['rejected_last_2']}',
                style: AppFonts.mono(
                  size: 10,
                  color: AppColors.textMid,
                ),
              ),
            if (s.error != null)
              Text(
                context.tr(s.error!),
                style: AppFonts.mono(
                  size: 10,
                  color: AppColors.warning,
                ),
              ),
            const SizedBox(height: 14),
            AppButton(
              label: context.tr('open_queue'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRoutes.instructorReports,
                );
                context
                    .read<CorrectionQueueController>()
                    .load(status: 'pending');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskRow extends StatelessWidget {
  final RiskStudent student;
  final VoidCallback onTap;
  const _RiskRow({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pct = student.riskPercentage;
    final band = student.riskBand;
    final color = _bandColor(band);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.chipBg,
                child: Text(
                  _initials(student.name),
                  style: TextStyle(
                    color: AppColors.heading(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct == null
                            ? 0
                            : (pct / 100).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: AppColors.borderLight,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student.error ??
                          '${pct?.toStringAsFixed(1) ?? '—'}% • ${_featuresLine(student)}',
                      style: AppFonts.mono(
                        size: 9,
                        color: AppColors.textMid,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  band,
                  style: AppFonts.mono(size: 9, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _featuresLine(RiskStudent s) {
    final f = s.features;
    if (f == null) return s.isFlagged ? 'flagged' : 'stable';
    return 'rate ${f['attendance_rate_to_date']}';
  }

  Color _bandColor(String band) {
    final b = band.toLowerCase();
    if (b.contains('very high') || b.contains('critical')) {
      return AppColors.danger;
    }
    if (b.contains('high')) return AppColors.dangerBright;
    if (b.contains('medium')) return AppColors.warning;
    if (b.contains('low')) return AppColors.success;
    return AppColors.textFaint;
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.length >= 2
          ? parts.first.substring(0, 2).toUpperCase()
          : parts.first.toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}


class _RiskFilterChip extends StatelessWidget {
  final String value;
  final bool selected;
  final VoidCallback onTap;
  const _RiskFilterChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  String _key() {
    switch (value) {
      case 'flagged': return 'filter_flagged';
      case 'high': return 'filter_high';
      case 'medium': return 'filter_medium';
      case 'low': return 'filter_low';
      default: return 'filter_all';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        context.tr(_key()),
        style: AppFonts.mono(
          size: 11,
          weight: FontWeight.w700,
          color: selected ? Colors.white : AppColors.ink(context),
        ),
      ),
      selected: selected,
      selectedColor: AppColors.primaryDark,
      onSelected: (_) => onTap(),
    );
  }
}
