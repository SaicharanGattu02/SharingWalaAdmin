import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/staff/staff_cubit.dart';
import '../../bloc/staff/staff_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/admin_models.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/status_badge.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<StaffCubit>().fetchStaffAndLogs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.textDark,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Staff Accounts & Roles'),
                  Tab(text: 'Audit Activity Log Trail'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<StaffCubit, StaffState>(
                builder: (context, state) {
                  if (state is StaffLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  if (state is StaffError) {
                    return EmptyState(
                      title: 'Error loading staff data',
                      message: state.message,
                      onRetry: () => context.read<StaffCubit>().fetchStaffAndLogs(),
                    );
                  }

                  if (state is StaffLoaded) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Staff Users
                        _buildStaffList(state.staff, isMobile),

                        // Tab 2: Audit Logs Trail
                        _buildAuditLogsList(state.auditLogs, isMobile),
                      ],
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

  Widget _buildStaffList(List<AdminStaffItem> staff, bool isMobile) {
    if (staff.isEmpty) {
      return const EmptyState(title: 'No staff users', message: 'No staff registered.');
    }

    return ListView.separated(
      itemCount: staff.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final s = staff[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(s.name.isNotEmpty ? s.name[0] : 'S', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name, style: AppTextStyles.bodyBold),
                      Text(s.email, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 6,
                  children: s.roles.map((r) => StatusBadge(status: r)).toList(),
                ),
                const SizedBox(width: 12),
                StatusBadge(status: s.isActive ? 'ACTIVE' : 'INACTIVE'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuditLogsList(List<AdminAuditLogItem> logs, bool isMobile) {
    if (logs.isEmpty) {
      return const EmptyState(title: 'No audit logs recorded', message: 'Activity logs will appear as admin actions occur.');
    }

    return Card(
      child: ListView.separated(
        itemCount: logs.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final l = logs[i];
          return ListTile(
            leading: const Icon(Icons.history, color: AppColors.primary),
            title: Text(l.action, style: AppTextStyles.bodyBold),
            subtitle: Text('Admin: ${l.adminName} | Target: ${l.entityType} #${l.entityId} | IP: ${l.ipAddress ?? "127.0.0.1"}', style: AppTextStyles.caption),
            trailing: Text(l.createdAt.replaceFirst('T', ' ').split('.').first, style: AppTextStyles.caption),
          );
        },
      ),
    );
  }
}

