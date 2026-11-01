import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
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

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedReportStatus = 'ALL';
  String _selectedSosStatus = 'ALL';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetch();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _fetch() {
    context.read<ReportsCubit>().fetchReports(
          status: _selectedReportStatus == 'ALL' ? null : _selectedReportStatus,
        );
  }

  // -------------------------------------------------------------
  // DIALOGS & ACTIONS
  // -------------------------------------------------------------

  Future<void> _launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _showUpdateSosStatusDialog(AdminSosIncidentItem incident) async {
    String newStatus = incident.status;
    final notesController = TextEditingController(text: incident.adminNotes ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shield_outlined, color: Colors.red, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Emergency Dispatch Action', style: AppTextStyles.h3),
                              Text('Incident #${incident.id} • ${incident.userName}', style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Update Incident Status:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['ACTIVE', 'INVESTIGATING', 'POLICE_NOTIFIED', 'RESOLVED'].map((st) {
                        final isSel = newStatus == st;
                        Color col = Colors.grey;
                        if (st == 'ACTIVE') col = Colors.red;
                        if (st == 'INVESTIGATING') col = Colors.amber.shade800;
                        if (st == 'POLICE_NOTIFIED') col = Colors.blue.shade700;
                        if (st == 'RESOLVED') col = Colors.green.shade700;

                        return ChoiceChip(
                          label: Text(st.replaceAll('_', ' ')),
                          selected: isSel,
                          selectedColor: col.withValues(alpha: 0.2),
                          side: BorderSide(color: isSel ? col : Colors.grey.shade300),
                          labelStyle: TextStyle(
                            color: isSel ? col : Colors.black87,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) setDialogState(() => newStatus = st);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    const Text('Action Log & Safety Findings:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'e.g. Spoke to passenger. Patrol PCR van 14 dispatched to landmark...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: const Color(0xFF0F172A),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            if (notesController.text.trim().isEmpty) return;
                            Navigator.pop(ctx, true);
                          },
                          child: const Text('Save Incident Status', style: TextStyle(fontWeight: FontWeight.bold)),
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
      final ok = await context.read<ReportsCubit>().updateSosStatus(
            incident.id,
            newStatus,
            notesController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'SOS Incident status updated to [$newStatus]' : 'Failed to update SOS incident'),
            backgroundColor: ok ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
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

  // -------------------------------------------------------------
  // BUILD METHOD
  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Column(
        children: [
          // Top Navigation Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: const Color(0xFF0F172A),
                    unselectedLabelColor: const Color(0xFF64748B),
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.emergency_rounded, color: Colors.red),
                        text: '🚨 Emergency SOS Dispatch',
                      ),
                      Tab(
                        icon: Icon(Icons.shield_outlined),
                        text: 'User Safety Reports',
                      ),
                      Tab(
                        icon: Icon(Icons.system_update_rounded),
                        text: 'App Version & Force Update',
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh All Feeds',
                  onPressed: _fetch,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: BlocBuilder<ReportsCubit, ReportsState>(
              builder: (context, state) {
                if (state is ReportsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ReportsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(state.message, style: AppTextStyles.body),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _fetch, child: const Text('Retry')),
                      ],
                    ),
                  );
                }

                if (state is ReportsLoaded) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSosDispatchTab(state.sosIncidents),
                      _buildReportsTab(state.reports),
                      _buildAppUpdateConfigTab(state.appConfig),
                    ],
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: SOS EMERGENCY DISPATCH
  // -------------------------------------------------------------

  Widget _buildSosDispatchTab(List<AdminSosIncidentItem> allSos) {
    var filtered = allSos;
    if (_selectedSosStatus != 'ALL') {
      filtered = allSos.where((i) => i.status == _selectedSosStatus).toList();
    }

    final activeCount = allSos.where((i) => i.status == 'ACTIVE').length;
    final investigatingCount = allSos.where((i) => i.status == 'INVESTIGATING').length;
    final policeCount = allSos.where((i) => i.status == 'POLICE_NOTIFIED').length;
    final resolvedCount = allSos.where((i) => i.status == 'RESOLVED').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Safety Monitoring KPI Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Active Emergency Alerts',
                  activeCount.toString(),
                  Icons.sensors_rounded,
                  activeCount > 0 ? Colors.red : Colors.grey,
                  isAlert: activeCount > 0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Under Investigation',
                  investigatingCount.toString(),
                  Icons.policy_rounded,
                  Colors.amber.shade800,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Police Notified',
                  policeCount.toString(),
                  Icons.local_police_rounded,
                  Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Resolved Incidents',
                  resolvedCount.toString(),
                  Icons.check_circle_outline,
                  Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filter Row
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text('Incident Status Filter:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedSosStatus,
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All Incidents')),
                      DropdownMenuItem(value: 'ACTIVE', child: Text('🔴 Active Only')),
                      DropdownMenuItem(value: 'INVESTIGATING', child: Text('🟡 Investigating')),
                      DropdownMenuItem(value: 'POLICE_NOTIFIED', child: Text('🔵 Police Dispatched')),
                      DropdownMenuItem(value: 'RESOLVED', child: Text('🟢 Resolved')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSosStatus = val);
                    },
                  ),
                  const Spacer(),
                  Text(
                    'Showing ${filtered.length} of ${allSos.length} Incidents',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (filtered.isEmpty)
            const EmptyState(
              icon: Icons.health_and_safety_outlined,
              title: 'No Emergency SOS Alerts',
              message: 'No SOS beacon incidents match the selected filter.',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = filtered[index];
                return _buildSosIncidentCard(item);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, {bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAlert ? Colors.red : Colors.grey.shade200,
          width: isAlert ? 2 : 1,
        ),
        boxShadow: [
          if (isAlert)
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.caption, maxLines: 1),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSosIncidentCard(AdminSosIncidentItem incident) {
    Color statusColor = Colors.grey;
    if (incident.status == 'ACTIVE') statusColor = Colors.red;
    if (incident.status == 'INVESTIGATING') statusColor = Colors.amber.shade800;
    if (incident.status == 'POLICE_NOTIFIED') statusColor = Colors.blue.shade700;
    if (incident.status == 'RESOLVED') statusColor = Colors.green.shade700;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: incident.status == 'ACTIVE' ? Colors.red.shade300 : Colors.grey.shade200,
          width: incident.status == 'ACTIVE' ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: ID, Time, Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  incident.id,
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  incident.emergencyType.replaceAll('_', ' '),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Row(
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      incident.status.replaceAll('_', ' '),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // User & Vehicle Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Details
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_pin_rounded, size: 20, color: Color(0xFF0F172A)),
                        const SizedBox(width: 6),
                        Text(
                          incident.userName,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Phone: ${incident.userPhone} • Email: ${incident.userEmail ?? "N/A"}',
                        style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            incident.address,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Ride & Driver Details (if present)
              if (incident.vehiclePlate != null || incident.driverName != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('VEHICLE & RIDER',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                        const SizedBox(height: 4),
                        Text('Plate: ${incident.vehiclePlate ?? "N/A"}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Driver: ${incident.driverName ?? "N/A"} (${incident.driverPhone ?? ""})',
                            style: AppTextStyles.caption),
                        Text('Model: ${incident.vehicleModel ?? "N/A"}', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          if (incident.adminNotes != null && incident.adminNotes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Text(
                'Admin Notes: ${incident.adminNotes}',
                style: TextStyle(color: Colors.amber.shade900, fontSize: 12),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Action Toolbar
          Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.phone_rounded, size: 16),
                label: Text('Call Passenger (${incident.userPhone})'),
                onPressed: () => _launchExternalUrl('tel:${incident.userPhone}'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                icon: const Icon(Icons.local_police_rounded, size: 16, color: Colors.blue),
                label: const Text('Call 112 Police'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.blue.shade800),
                onPressed: () => _launchExternalUrl('tel:112'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                icon: const Icon(Icons.map_rounded, size: 16, color: Colors.red),
                label: const Text('View GPS Location'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade800),
                onPressed: () => _launchExternalUrl(
                  'https://www.google.com/maps/search/?api=1&query=${incident.latitude},${incident.longitude}',
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.admin_panel_settings_rounded, size: 16),
                label: const Text('Dispatch / Update Status'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: const Color(0xFF0F172A),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () => _showUpdateSosStatusDialog(incident),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: USER SAFETY REPORTS
  // -------------------------------------------------------------

  Widget _buildReportsTab(List<AdminReportItem> reports) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Bar
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text('Report Status Filter:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedReportStatus,
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All Grievances')),
                      DropdownMenuItem(value: 'OPEN', child: Text('Open Unresolved')),
                      DropdownMenuItem(value: 'INVESTIGATING', child: Text('Under Investigation')),
                      DropdownMenuItem(value: 'RESOLVED', child: Text('Resolved Tickets')),
                      DropdownMenuItem(value: 'DISMISSED', child: Text('Dismissed')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedReportStatus = val);
                        _fetch();
                      }
                    },
                  ),
                  const Spacer(),
                  Text('Showing ${reports.length} Reports', style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (reports.isEmpty)
            const EmptyState(
              icon: Icons.check_circle_outline,
              title: 'No Safety Reports',
              message: 'No incidents match the selected filter.',
            )
          else
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reports.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = reports[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: item.status == 'OPEN' ? Colors.red.shade100 : Colors.green.shade100,
                      child: Icon(
                        item.status == 'OPEN' ? Icons.warning_amber_rounded : Icons.check,
                        color: item.status == 'OPEN' ? AppColors.error : AppColors.success,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text('Reported: ${item.reportedUserName}', style: AppTextStyles.bodyBold),
                        const SizedBox(width: 12),
                        StatusBadge(status: item.status),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Reason: ${item.reason} • Filed By: ${item.reporterName}', style: AppTextStyles.caption),
                        const SizedBox(height: 4),
                        Text(item.description, style: AppTextStyles.body),
                        if (item.adminNotes != null && item.adminNotes!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('Resolution Notes: ${item.adminNotes}',
                              style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontStyle: FontStyle.italic)),
                        ],
                      ],
                    ),
                    trailing: item.status != 'RESOLVED'
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: const Color(0xFF0F172A),
                            ),
                            onPressed: () => _resolveTicket(item),
                            child: const Text('Resolve & Action'),
                          )
                        : const Icon(Icons.check_circle, color: AppColors.success),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 3: APP UPDATE & FORCE UPDATE ENGINE CONFIG
  // -------------------------------------------------------------

  Widget _buildAppUpdateConfigTab(AppUpdateConfigModel? config) {
    return _AppUpdateConfigView(initialConfig: config);
  }
}

class _AppUpdateConfigView extends StatefulWidget {
  final AppUpdateConfigModel? initialConfig;

  const _AppUpdateConfigView({this.initialConfig});

  @override
  State<_AppUpdateConfigView> createState() => _AppUpdateConfigViewState();
}

class _AppUpdateConfigViewState extends State<_AppUpdateConfigView> {
  late TextEditingController _latestVersionCtrl;
  late TextEditingController _minVersionCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _messageCtrl;
  late TextEditingController _storeUrlCtrl;
  late TextEditingController _notesCtrl;
  bool _forceUpdate = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final cfg = widget.initialConfig;
    _latestVersionCtrl = TextEditingController(text: cfg?.latestVersion ?? '1.2.0');
    _minVersionCtrl = TextEditingController(text: cfg?.minSupportedVersion ?? '1.0.0');
    _titleCtrl = TextEditingController(text: cfg?.title ?? 'Update Available');
    _messageCtrl = TextEditingController(text: cfg?.message ?? 'A newer, safer version of SharingWala is available with real-time SOS protection.');
    _storeUrlCtrl = TextEditingController(text: cfg?.storeUrl ?? 'https://play.google.com/store/apps/details?id=com.sharingwala.app');
    _notesCtrl = TextEditingController(text: (cfg?.releaseNotes ?? ['New 24/7 Live Emergency SOS Beacon', 'Mandatory Driver Selfie & License verification']).join('\n'));
    _forceUpdate = cfg?.forceUpdate ?? false;
  }

  @override
  void dispose() {
    _latestVersionCtrl.dispose();
    _minVersionCtrl.dispose();
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    _storeUrlCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSaveConfig() async {
    setState(() => _isSaving = true);

    final notes = _notesCtrl.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final payload = {
      'latestVersion': _latestVersionCtrl.text.trim(),
      'minSupportedVersion': _minVersionCtrl.text.trim(),
      'forceUpdate': _forceUpdate,
      'title': _titleCtrl.text.trim(),
      'message': _messageCtrl.text.trim(),
      'storeUrl': _storeUrlCtrl.text.trim(),
      'releaseNotes': notes,
      'enabled': true,
    };

    final ok = await context.read<ReportsCubit>().updateAppConfig(payload);

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'App Update Rules Deployed Successfully!' : 'Failed to save configuration'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 820),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.system_update_rounded, color: Color(0xFF0F172A), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('App Version & Force Update Governance', style: AppTextStyles.h2),
                        const SizedBox(height: 2),
                        Text(
                          'Enforce mandatory app upgrades when older client builds are sunset or vulnerable.',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Force Update Master Switch
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _forceUpdate ? Colors.red.shade50 : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _forceUpdate ? Colors.red.shade300 : const Color(0xFFE2E8F0)),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _forceUpdate,
                  activeThumbColor: Colors.red,
                  title: Row(
                    children: [
                      Text(
                        'Enforce Mandatory Force Update',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _forceUpdate ? Colors.red.shade900 : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _forceUpdate ? Colors.red : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _forceUpdate ? 'BLOCKING MODAL ACTIVE' : 'OPTIONAL NOTIFICATION',
                          style: TextStyle(
                            color: _forceUpdate ? Colors.white : Colors.black87,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    _forceUpdate
                        ? 'All mobile users on older versions will be blocked by a non-dismissible update modal until they update.'
                        : 'Users below minimum supported version will still be prompted, but can continue with a dismissible modal.',
                    style: TextStyle(
                      fontSize: 12,
                      color: _forceUpdate ? Colors.red.shade800 : Colors.blueGrey,
                    ),
                  ),
                  onChanged: (val) => setState(() => _forceUpdate = val),
                ),
              ),
              const SizedBox(height: 20),

              // Version fields
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Latest App Version:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _latestVersionCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g. 1.2.0',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Minimum Supported Version:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _minVersionCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g. 1.0.0',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title & Message
              const Text('Modal Title:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  hintText: 'Update Available',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Update Explanation Message:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _messageCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Reason for the update...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Release Notes (1 item per line):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _notesCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '• Feature 1\n• Feature 2...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Store Download URL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _storeUrlCtrl,
                decoration: InputDecoration(
                  hintText: 'https://play.google.com/store/apps/details?id=...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _handleSaveConfig,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.cloud_upload_rounded, color: Color(0xFF0F172A)),
                  label: Text(
                    _isSaving ? 'SAVING RULES...' : 'DEPLOY APP UPDATE RULES',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
