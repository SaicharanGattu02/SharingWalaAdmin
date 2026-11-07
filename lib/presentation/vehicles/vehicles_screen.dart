import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/vehicles/vehicles_cubit.dart';
import '../../bloc/vehicles/vehicles_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/admin_models.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/status_badge.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  String _selectedType = 'ALL';
  String _selectedStatus = 'ALL';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetch() {
    context.read<VehiclesCubit>().fetchVehicles(
          vehicleType: _selectedType == 'ALL' ? null : _selectedType,
          status: _selectedStatus == 'ALL' ? null : _selectedStatus,
        );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _verify(AdminVehicleItem vehicle, String status) async {
    final isReject = status == 'REJECTED';
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: isReject ? 'Reject Vehicle RC' : 'Approve Vehicle RC',
        message: 'Are you sure you want to change registration status for ${vehicle.registrationNumber} (${vehicle.make} ${vehicle.model}) to $status?',
        confirmText: isReject ? 'Reject' : 'Approve',
        confirmColor: isReject ? AppColors.error : AppColors.success,
        requireReason: isReject,
        reasonHint: 'Specify rejection reason (e.g., RC image mismatch, expired policy)...',
      ),
    );

    if (result != null && mounted) {
      final ok = await context.read<VehiclesCubit>().verifyVehicle(
            vehicle.id,
            status,
            reason: result['reason'] as String?,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Vehicle status updated to [$status]' : 'Update failed'),
            backgroundColor: ok ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  void _showVehicleInspectionDialog(AdminVehicleItem vehicle) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 760),
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
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.directions_car_rounded, color: Color(0xFF0F172A), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Vehicle & RC Compliance Inspection', style: AppTextStyles.h3),
                            Text(
                              'Audit vehicle RC documents, seating capacity, and active insurance',
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

                // Vehicle Summary Badge Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  border: Border.all(color: Colors.amber.shade400),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  vehicle.registrationNumber,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontFamily: 'monospace', fontSize: 15),
                                ),
                              ),
                              const SizedBox(width: 10),
                              StatusBadge(status: vehicle.vehicleType),
                            ],
                          ),
                          StatusBadge(status: vehicle.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSpecItem('Model', '${vehicle.make} ${vehicle.model}'),
                          ),
                          Expanded(
                            child: _buildSpecItem('Year', vehicle.year.toString()),
                          ),
                          Expanded(
                            child: _buildSpecItem('Color', vehicle.color),
                          ),
                          Expanded(
                            child: _buildSpecItem('Seats', '${vehicle.seatCapacity} Seats'),
                          ),
                          Expanded(
                            child: _buildSpecItem('Fuel', vehicle.fuelType),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Owner Info Bar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: Text(
                          (vehicle.driverName != null && vehicle.driverName!.isNotEmpty) ? vehicle.driverName![0] : 'D',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vehicle.driverName ?? 'Registered Driver', style: AppTextStyles.bodyBold),
                            Text('Phone: ${vehicle.driverPhone ?? "N/A"} • Email: ${vehicle.driverEmail ?? "N/A"}',
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      if (vehicle.driverPhone != null && vehicle.driverPhone!.isNotEmpty)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.phone, size: 14),
                          label: const Text('Call Owner'),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                          onPressed: () => _launchUrl('tel:${vehicle.driverPhone}'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Documents Comparison: RC Card VS Insurance
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Document 1: Registration Certificate (RC)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.badge_outlined, size: 16, color: AppColors.info),
                              const SizedBox(width: 6),
                              Text('1. Registration Certificate (RC)', style: AppTextStyles.bodyBold.copyWith(fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: vehicle.rcDocumentUrl != null && vehicle.rcDocumentUrl!.isNotEmpty
                                ? Image.network(
                                    vehicle.rcDocumentUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => _buildFallbackDocumentView(
                                      Icons.description_outlined,
                                      'RC Document On File',
                                      vehicle.registrationNumber,
                                    ),
                                  )
                                : _buildFallbackDocumentView(
                                    Icons.badge_outlined,
                                    'RC Document Submitted',
                                    'Plate: ${vehicle.registrationNumber}',
                                  ),
                          ),
                          if (vehicle.rcDocumentUrl != null && vehicle.rcDocumentUrl!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: TextButton.icon(
                                icon: const Icon(Icons.open_in_new, size: 14),
                                label: const Text('Open Full RC in Browser'),
                                onPressed: () => _launchUrl(vehicle.rcDocumentUrl!),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Document 2: Insurance Certificate
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.policy_outlined, size: 16, color: Colors.green),
                              const SizedBox(width: 6),
                              Text('2. Insurance Policy Certificate', style: AppTextStyles.bodyBold.copyWith(fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: vehicle.insuranceDocumentUrl != null && vehicle.insuranceDocumentUrl!.isNotEmpty
                                ? Image.network(
                                    vehicle.insuranceDocumentUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => _buildFallbackDocumentView(
                                      Icons.policy_rounded,
                                      vehicle.insuranceProvider ?? 'Insurance Active',
                                      'Policy: ${vehicle.insurancePolicyNumber ?? "Verified"}',
                                    ),
                                  )
                                : _buildFallbackDocumentView(
                                    Icons.verified_rounded,
                                    vehicle.insuranceProvider ?? 'Comprehensive Policy',
                                    'Expires: ${vehicle.insuranceValidUntil?.split("T").first ?? "Active Policy"}',
                                  ),
                          ),
                          if (vehicle.insuranceDocumentUrl != null && vehicle.insuranceDocumentUrl!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: TextButton.icon(
                                icon: const Icon(Icons.open_in_new, size: 14),
                                label: const Text('Open Policy Document'),
                                onPressed: () => _launchUrl(vehicle.insuranceDocumentUrl!),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Decision Action Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorBg,
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.cancel, size: 16),
                      label: const Text('Reject RC'),
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        _verify(vehicle, 'REJECTED');
                      },
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.check_circle, size: 16),
                      label: const Text('Approve Vehicle RC'),
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        _verify(vehicle, 'APPROVED');
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

  Widget _buildSpecItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1),
      ],
    );
  }

  Widget _buildFallbackDocumentView(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 44, color: Colors.blueGrey.shade400),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
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
            // Filter Bar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: _selectedType,
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('All Vehicle Modes')),
                        DropdownMenuItem(value: 'CAR', child: Text('Cars')),
                        DropdownMenuItem(value: 'BIKE', child: Text('Motorcycles / Bikes')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedType = val);
                          _fetch();
                        }
                      },
                    ),
                    DropdownButton<String>(
                      value: _selectedStatus,
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('All Statuses')),
                        DropdownMenuItem(value: 'PENDING', child: Text('Pending Review')),
                        DropdownMenuItem(value: 'APPROVED', child: Text('Approved')),
                        DropdownMenuItem(value: 'REJECTED', child: Text('Rejected')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedStatus = val);
                          _fetch();
                        }
                      },
                    ),
                    ElevatedButton.icon(
                      onPressed: _fetch,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Reload'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Vehicle Grid / Table
            Expanded(
              child: BlocBuilder<VehiclesCubit, VehiclesState>(
                builder: (context, state) {
                  if (state is VehiclesLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  if (state is VehiclesError) {
                    return EmptyState(
                      title: 'Error loading vehicles',
                      message: state.message,
                      onRetry: _fetch,
                    );
                  }

                  if (state is VehiclesLoaded) {
                    final vehicles = state.vehicles;
                    if (vehicles.isEmpty) {
                      return const EmptyState(
                        title: 'No vehicles found',
                        message: 'No vehicles match the selected criteria.',
                        icon: Icons.directions_car_outlined,
                      );
                    }

                    if (isMobile) {
                      return ListView.separated(
                        itemCount: vehicles.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _buildMobileVehicleCard(vehicles[i]),
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
                                DataColumn(label: Text('Plate Number')),
                                DataColumn(label: Text('Vehicle & Specs')),
                                DataColumn(label: Text('Type')),
                                DataColumn(label: Text('Owner')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: vehicles.map((v) {
                                final isPending = v.status == 'PENDING';

                                return DataRow(cells: [
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade50,
                                        border: Border.all(color: Colors.amber.shade400),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        v.registrationNumber,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('${v.make} ${v.model}', style: AppTextStyles.bodyBold),
                                        Text('${v.year} • ${v.color} • ${v.fuelType} (${v.seatCapacity} Seats)',
                                            style: AppTextStyles.caption),
                                      ],
                                    ),
                                  ),
                                  DataCell(StatusBadge(status: v.vehicleType)),
                                  DataCell(
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(v.driverName ?? 'Driver', style: const TextStyle(fontWeight: FontWeight.w600)),
                                        if (v.driverPhone != null)
                                          Text(v.driverPhone!, style: AppTextStyles.caption),
                                      ],
                                    ),
                                  ),
                                  DataCell(StatusBadge(status: v.status)),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_red_eye_outlined, color: AppColors.info),
                                          tooltip: 'Inspect RC & Insurance Documents',
                                          onPressed: () => _showVehicleInspectionDialog(v),
                                        ),
                                        if (isPending) ...[
                                          IconButton(
                                            icon: const Icon(Icons.check_circle, color: AppColors.success),
                                            tooltip: 'Approve RC',
                                            onPressed: () => _verify(v, 'APPROVED'),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.cancel, color: AppColors.error),
                                            tooltip: 'Reject RC',
                                            onPressed: () => _verify(v, 'REJECTED'),
                                          ),
                                        ] else ...[
                                          IconButton(
                                            icon: const Icon(Icons.change_circle_outlined),
                                            tooltip: 'Toggle Status',
                                            onPressed: () => _verify(
                                              v,
                                              v.status == 'APPROVED' ? 'REJECTED' : 'APPROVED',
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

  Widget _buildMobileVehicleCard(AdminVehicleItem vehicle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(vehicle.registrationNumber, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                StatusBadge(status: vehicle.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('${vehicle.make} ${vehicle.model}', style: AppTextStyles.bodyBold),
            const SizedBox(height: 4),
            Text('Owner: ${vehicle.driverName ?? "Driver"} • ${vehicle.year} • ${vehicle.color}', style: AppTextStyles.caption),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                label: const Text('Inspect RC & Insurance Docs'),
                onPressed: () => _showVehicleInspectionDialog(vehicle),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                StatusBadge(status: vehicle.vehicleType),
                const Spacer(),
                TextButton(
                  onPressed: () => _verify(vehicle, vehicle.status == 'APPROVED' ? 'REJECTED' : 'APPROVED'),
                  child: Text(vehicle.status == 'APPROVED' ? 'Revoke Approval' : 'Approve RC'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
