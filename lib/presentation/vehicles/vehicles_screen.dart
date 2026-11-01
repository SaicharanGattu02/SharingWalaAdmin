import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    context.read<VehiclesCubit>().fetchVehicles(
          vehicleType: _selectedType == 'ALL' ? null : _selectedType,
          status: _selectedStatus == 'ALL' ? null : _selectedStatus,
        );
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
        reasonHint: 'Specify rejection reason (e.g., RC image mismatch)...',
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
            content: Text(ok ? 'Vehicle status updated' : 'Update failed'),
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
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                                DataColumn(label: Text('Vehicle')),
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
                                  DataCell(Text('${v.make} ${v.model}', style: AppTextStyles.bodyBold)),
                                  DataCell(StatusBadge(status: v.vehicleType)),
                                  DataCell(Text(v.driverName ?? 'Driver')),
                                  DataCell(StatusBadge(status: v.status)),
                                  DataCell(
                                    Row(
                                      children: [
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
            Text('Owner: ${vehicle.driverName ?? "Driver"}', style: AppTextStyles.caption),
            const SizedBox(height: 12),
            Row(
              children: [
                StatusBadge(status: vehicle.vehicleType),
                const Spacer(),
                TextButton(
                  onPressed: () => _verify(vehicle, vehicle.status == 'APPROVED' ? 'REJECTED' : 'APPROVED'),
                  child: Text(vehicle.status == 'APPROVED' ? 'Revoke' : 'Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

