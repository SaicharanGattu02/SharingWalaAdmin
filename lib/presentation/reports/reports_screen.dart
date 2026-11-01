import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/reports/reports_cubit.dart';
import '../../bloc/reports/reports_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/admin_models.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedStatus = 'ALL';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    context.read<ReportsCubit>().fetchReports(
          status: _selectedStatus == 'ALL' ? null : _selectedStatus,
        );
  }

  Future<void> _resolveTicket(AdminReportItem report) async {
    final notesController = TextEditingController();
    String penaltyAction = 'NONE';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resolve Safety Report #${report.id.substring(0, 8)}', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    Text('Reported User: ${report.reportedUserName} by ${report.reporterName}', style: AppTextStyles.caption),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Text('Reason: ${report.reason}\n${report.description}', style: TextStyle(color: Colors.red.shade900)),
                    ),
                    const SizedBox(height: 16),
                    const Text('Resolution Notes & Findings:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'Enter internal resolution findings...'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Penalize Reported User:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: penaltyAction,
                      items: const [
                        DropdownMenuItem(value: 'NONE', child: Text('No Penalty (Resolved)')),
                        DropdownMenuItem(value: 'SUSPEND', child: Text('Suspend User Account (Temporary lock)')),
                        DropdownMenuItem(value: 'BLOCK', child: Text('Block User Account Permanently')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => penaltyAction = val);
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                          onPressed: () {
                            if (notesController.text.trim().isEmpty) return;
                            Navigator.pop(context, true);
                          },
                          child: const Text('Submit Resolution'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      final ok = await context.read<ReportsCubit>().resolveReport(
            report.id,
            'RESOLVED',
            notesController.text.trim(),
            penalize: penaltyAction != 'NONE',
            penalty: penaltyAction,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Safety ticket marked as RESOLVED' : 'Failed to resolve ticket'),
            backgroundColor: ok ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Bar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    DropdownButton<String>(
                      value: _selectedStatus,
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('All Tickets')),
                        DropdownMenuItem(value: 'OPEN', child: Text('Open / Under Review')),
                        DropdownMenuItem(value: 'RESOLVED', child: Text('Resolved')),
                        DropdownMenuItem(value: 'DISMISSED', child: Text('Dismissed')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedStatus = val);
                          _fetch();
                        }
                      },
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _fetch,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reports List
            Expanded(
              child: BlocBuilder<ReportsCubit, ReportsState>(
                builder: (context, state) {
                  if (state is ReportsLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  if (state is ReportsError) {
                    return EmptyState(
                      title: 'Error loading reports',
                      message: state.message,
                      onRetry: _fetch,
                    );
                  }

                  if (state is ReportsLoaded) {
                    final reports = state.reports;
                    if (reports.isEmpty) {
                      return const EmptyState(
                        title: 'All clear! No safety incidents',
                        message: 'No reports match the current filter.',
                        icon: Icons.verified_user,
                      );
                    }

                    return ListView.separated(
                      itemCount: reports.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final r = reports[i];
                        final isOpen = r.status == 'OPEN';

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    StatusBadge(status: r.status),
                                    const SizedBox(width: 10),
                                    Text(r.reason, style: AppTextStyles.h3.copyWith(fontSize: 16)),
                                    const Spacer(),
                                    Text(r.createdAt.split('T').first, style: AppTextStyles.caption),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(r.description, style: AppTextStyles.body),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Reported by: ${r.reporterName} ➔ Accused: ${r.reportedUserName}',
                                          style: AppTextStyles.bodyBold.copyWith(fontSize: 13),
                                        ),
                                      ),
                                      if (isOpen)
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.success,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () => _resolveTicket(r),
                                          child: const Text('Resolve Ticket'),
                                        )
                                      else
                                        Text('Resolution: ${r.adminNotes ?? "Resolved"}', style: AppTextStyles.caption),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
