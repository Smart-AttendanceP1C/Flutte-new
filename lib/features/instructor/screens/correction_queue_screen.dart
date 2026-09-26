import '../../../core/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_widgets.dart';
import '../state/risk_controllers.dart';

/// Correction review queue — real list + real approve/reject.
/// Lecturer/TA sees only own sections (enforced server-side).
class CorrectionQueueScreen extends StatefulWidget {
  const CorrectionQueueScreen({super.key});

  @override
  State<CorrectionQueueScreen> createState() => _CorrectionQueueScreenState();
}

class _CorrectionQueueScreenState extends State<CorrectionQueueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CorrectionQueueController>().load(status: 'pending');
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = context.watch<CorrectionQueueController>();
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
          context.tr('queue_title'),
          style: AppFonts.serif(
            size: 19,
            weight: FontWeight.w800,
            color: AppColors.heading(context),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryDark),
            onPressed: () => q.load(status: q.filter),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: ['pending', 'approved', 'rejected']
                  .map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          s,
                          style: AppFonts.mono(
                            size: 11,
                            weight: FontWeight.w700,
                            color: q.filter == s
                                ? Colors.white
                                : AppColors.ink(context),
                          ),
                        ),
                        selected: q.filter == s,
                        selectedColor: AppColors.primaryDark,
                        onSelected: (_) => q.load(status: s),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (_) {
                if (q.loading && q.items.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (q.error != null && q.items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.tr(q.error!),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.danger,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () =>
                                q.load(status: q.filter),
                            child: Text(context.tr('retry')),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (q.items.isEmpty) {
                  return Center(
                    child: Text(
                      'No ${q.filter} requests.',
                      style: AppFonts.mono(
                        color: AppColors.textMid,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: q.items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final r = q.items[i];
                    final isPending = r.status == 'pending';
                    return AppCard(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${r.courseCode} • ${r.studentName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
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
                                  color: isPending
                                      ? AppColors.warningBg
                                      : AppColors.successBg,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '#REQ-${r.id} • ${r.status}',
                                  style: AppFonts.mono(size: 9),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${r.sectionCode} • ${r.studentCode}',
                            style: AppFonts.mono(size: 10),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            r.evidence,
                            style: const TextStyle(fontSize: 13),
                          ),
                          if (isPending) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: q.reviewing
                                        ? null
                                        : () => _review(
                                              context,
                                              q,
                                              r.id,
                                              'rejected',
                                            ),
                                    child: Text(context.tr('reject')),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: q.reviewing
                                        ? null
                                        : () => _review(
                                              context,
                                              q,
                                              r.id,
                                              'approved',
                                            ),
                                    child: Text(context.tr('approve')),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _review(
    BuildContext context,
    CorrectionQueueController q,
    int id,
    String status,
  ) {
    final reason = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.tr('review_confirm', {'v': status == 'approved' ? context.tr('approve') : context.tr('reject'), 'id': '$id'})),
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
              final ok = await q.review(
                requestId: id,
                status: status,
                reason: reason.text.trim(),
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? 'Request $status.' : (q.error != null ? context.tr(q.error!) : context.tr('update_failed')),
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
