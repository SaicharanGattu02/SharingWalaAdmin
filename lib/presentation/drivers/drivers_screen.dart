import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/drivers/drivers_cubit.dart';
import '../../bloc/drivers/drivers_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/admin_models.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/status_badge.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  final List<String> _statusTabs = ['PENDING', 'APPROVED', 'REJECTED', 'ALL'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetch();
      }
    });
    _fetch();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _fetch() {
    final status = _statusTabs[_tabController.index];
    context.read<DriversCubit>().fetchDrivers(
          status: status == 'ALL' ? null : status,
          search: _searchController.text.trim(),
        );
  }

  Future<void> _verify(AdminDriverItem driver, String status) async {
    final isReject = status == 'REJECTED';
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: isReject ? 'Reject Driver Application' : 'Approve Driver Application',
        message: 'Are you sure you want to mark ${driver.driverName}\'s driver application as $status?',
        confirmText: isReject ? 'Reject Application' : 'Approve Driver',
        confirmColor: isReject ? AppColors.error : AppColors.success,
        requireReason: isReject,
        reasonHint: 'Specify rejection reason for the driver...',
      ),
    );

    if (result != null && mounted) {
      final ok = await context.read<DriversCubit>().verifyDriver(
            driver.id,
            status,
            reason: result['reason'] as String?,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Driver verification status updated' : 'Operation failed'),
            backgroundColor: ok ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs Bar
            Card(
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.textDark,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Pending Approvals'),
                  Tab(text: 'Approved Drivers'),
                  Tab(text: 'Rejected Drivers'),
                  Tab(text: 'All Drivers'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _fetch(),
                    decoration: InputDecoration(
                      hintText: 'Search by driver name, phone, or license number...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          _fetch();
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _fetch,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Drivers Data
            Expanded(
              child: BlocBuilder<DriversCubit, DriversState>(
                builder: (context, state) {
                  if (state is DriversLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  if (state is DriversError) {
                    return EmptyState(
                      title: 'Error loading drivers',
                      message: state.message,
                      onRetry: _fetch,
                    );
                  }

                  if (state is DriversLoaded) {
                    final drivers = state.drivers;
                    if (drivers.isEmpty) {
                      return const EmptyState(
                        title: 'No driver records found',
                        message: 'No drivers match the current verification tab.',
                        icon: Icons.check_circle_outline,
                      );
                    }

                    if (isMobile) {
                      return ListView.separated(
                        itemCount: drivers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _buildMobileCard(drivers[i]),
                      );
                    }

                    return Card(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 320),
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                              columns: const [
                                DataColumn(label: Text('Driver Name')),
                                DataColumn(label: Text('Phone')),
                                DataColumn(label: Text('License Number')),
                                DataColumn(label: Text('Expiry Date')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: drivers.map((d) {
                                final isPending = d.verificationStatus == 'PENDING';

                                return DataRow(cells: [
                                  DataCell(
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: AppColors.warning.withValues(alpha: 0.2),
                                          child: Text(d.driverName.isNotEmpty ? d.driverName[0] : 'D'),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(d.driverName, style: AppTextStyles.bodyBold),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(d.driverPhone, style: AppTextStyles.body)),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        d.licenseNumber,
                                        style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(d.licenseExpiryDate?.split('T').first ?? 'N/A')),
                                  DataCell(StatusBadge(status: d.verificationStatus)),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_red_eye_outlined, color: AppColors.info),
                                          tooltip: 'Inspect Camera & License Photos',
                                          onPressed: () => _showVerificationComparisonDialog(d),
                                        ),
                                        if (isPending) ...[
                                          IconButton(
                                            icon: const Icon(Icons.check_circle, color: AppColors.success),
                                            tooltip: 'Approve Driver',
                                            onPressed: () => _verify(d, 'APPROVED'),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.cancel, color: AppColors.error),
                                            tooltip: 'Reject Application',
                                            onPressed: () => _verify(d, 'REJECTED'),
                                          ),
                                        ] else ...[
                                          IconButton(
                                            icon: const Icon(Icons.edit_note),
                                            tooltip: 'Modify Verification',
                                            onPressed: () => _verify(
                                              d,
                                              d.verificationStatus == 'APPROVED' ? 'REJECTED' : 'APPROVED',
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildMobileCard(AdminDriverItem driver) {
    final isPending = driver.verificationStatus == 'PENDING';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.warning.withValues(alpha: 0.2),
                  child: Text(driver.driverName.isNotEmpty ? driver.driverName[0] : 'D'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driver.driverName, style: AppTextStyles.bodyBold),
                      Text(driver.driverPhone, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                StatusBadge(status: driver.verificationStatus),
              ],
            ),
            const SizedBox(height: 12),
            Text('License: ${driver.licenseNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                label: const Text('Inspect Photos & Verify Match'),
                onPressed: () => _showVerificationComparisonDialog(driver),
              ),
            ),
            const SizedBox(height: 10),
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                      onPressed: () => _verify(driver, 'REJECTED'),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                      onPressed: () => _verify(driver, 'APPROVED'),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showVerificationComparisonDialog(AdminDriverItem driver) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.verified_user_rounded, color: Color(0xFF0F172A), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Driver Identity Verification', style: AppTextStyles.h3),
                            Text(
                              'Compare live camera photo against submitted Driving License',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Driver Details Bar
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: Text(driver.driverName.isNotEmpty ? driver.driverName[0] : 'D'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(driver.driverName, style: AppTextStyles.bodyBold),
                            Text('Phone: ${driver.driverPhone}  •  License: ${driver.licenseNumber}', style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      StatusBadge(status: driver.verificationStatus),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Photo Comparison Row (Live Camera Selfie VS Driving License)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Live Camera Selfie Photo Card
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.info),
                              const SizedBox(width: 6),
                              Text('1. Live Camera Selfie', style: AppTextStyles.bodyBold.copyWith(fontSize: 13)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('Live Capture', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: driver.selfieUrl != null && driver.selfieUrl!.isNotEmpty
                                ? Image.network(
                                    driver.selfieUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildPlaceholderPhoto(Icons.person, 'No Selfie Loaded'),
                                  )
                                : _buildPlaceholderPhoto(Icons.camera_alt_outlined, 'No Camera Selfie Available'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 2. Driving License Photo Card
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.badge_outlined, size: 16, color: AppColors.success),
                              const SizedBox(width: 6),
                              Text('2. Driving License', style: AppTextStyles.bodyBold.copyWith(fontSize: 13)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('Government ID', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: driver.licenseFrontUrl != null && driver.licenseFrontUrl!.isNotEmpty
                                ? Image.network(
                                    driver.licenseFrontUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildPlaceholderPhoto(Icons.badge, 'No License Loaded'),
                                  )
                                : _buildPlaceholderPhoto(Icons.credit_card_outlined, 'No License Photo Available'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Trust & Safety Advisory Note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Colors.amber.shade900, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Identity Verification Rule: Verify that the facial structure and eye alignment in the live camera capture matches the Driving License photo before approving this driver.',
                          style: TextStyle(fontSize: 12, color: Colors.amber.shade900, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                if (driver.rejectedReason != null && driver.rejectedReason!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      'Previous Rejection Reason: ${driver.rejectedReason}',
                      style: TextStyle(fontSize: 12, color: Colors.red.shade800, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Decision Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        _verify(driver, 'REJECTED');
                      },
                      child: const Text('Reject Application'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Approve Driver & Grant License'),
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        _verify(driver, 'APPROVED');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderPhoto(IconData icon, String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

