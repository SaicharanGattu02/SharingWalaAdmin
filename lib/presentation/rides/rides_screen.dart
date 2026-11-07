import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/rides/rides_cubit.dart';
import '../../bloc/rides/rides_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/admin_models.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/status_badge.dart';

class RidesScreen extends StatefulWidget {
  const RidesScreen({super.key});

  @override
  State<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'ALL';

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
    context.read<RidesCubit>().fetchRides(
          status: _selectedStatus == 'ALL' ? null : _selectedStatus,
          search: _searchController.text.trim(),
        );
  }

  Future<void> _launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _cancelRide(AdminRideItem ride) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Emergency Ride Cancellation',
        message: 'This will cancel the ride from ${ride.startLocationName} to ${ride.endLocationName} and immediately notify the driver and all booked passengers.',
        confirmText: 'Cancel Ride',
        confirmColor: AppColors.error,
        requireReason: true,
        reasonHint: 'Reason for cancellation (e.g. road accident, strike)...',
      ),
    );

    if (result != null && mounted) {
      final ok = await context.read<RidesCubit>().cancelRide(
            ride.id,
            result['reason'] as String? ?? 'Admin force cancellation',
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Ride cancelled and affected parties notified' : 'Failed to cancel ride'),
            backgroundColor: ok ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  void _showRideInspectionDialog(AdminRideItem ride) {
    final canCancel = ride.status == 'PUBLISHED' || ride.status == 'IN_PROGRESS';

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 620),
          padding: const EdgeInsets.all(24),
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
                        child: const Icon(Icons.alt_route_rounded, color: Color(0xFF0F172A), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ride Journey Inspection', style: AppTextStyles.h3),
                          Text('Trip #${ride.id.substring(0, ride.id.length > 8 ? 8 : ride.id.length)}',
                              style: AppTextStyles.caption),
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

              // Route Display Box
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.trip_origin, size: 18, color: AppColors.success),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('PICKUP LOCATION',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                              Text(ride.startLocationName, style: AppTextStyles.bodyBold),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        children: [
                          Container(width: 2, height: 24, color: Colors.grey.shade300),
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, size: 18, color: AppColors.error),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('DROP OFF DESTINATION',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                              Text(ride.endLocationName, style: AppTextStyles.bodyBold),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Ride Meta Grid
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetaItem(
                            'Departure',
                            ride.departureAt.replaceFirst('T', ' ').split('.').first,
                            Icons.calendar_today_rounded,
                          ),
                        ),
                        Expanded(
                          child: _buildMetaItem(
                            'Seats Left',
                            '${ride.availableSeats} of ${ride.totalSeats} Available',
                            Icons.airline_seat_recline_normal_rounded,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetaItem(
                            'Vehicle Assigned',
                            ride.vehiclePlate ?? 'Plate Verified',
                            Icons.directions_car_rounded,
                          ),
                        ),
                        Expanded(
                          child: _buildMetaItem(
                            'Price / Contribution',
                            ride.pricePerSeat > 0 ? '₹${ride.pricePerSeat.toStringAsFixed(0)} / seat' : 'Fuel Shared',
                            Icons.payments_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Driver Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.3),
                      child: Text(
                        (ride.driverName != null && ride.driverName!.isNotEmpty) ? ride.driverName![0] : 'D',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ride.driverName ?? 'Driver Host', style: AppTextStyles.bodyBold),
                          Text(ride.driverPhone != null ? 'Phone: ${ride.driverPhone}' : 'Verified Ride Host',
                              style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    if (ride.driverPhone != null && ride.driverPhone!.isNotEmpty)
                      OutlinedButton.icon(
                        icon: const Icon(Icons.phone, size: 14),
                        label: const Text('Call Host'),
                        onPressed: () => _launchExternalUrl('tel:${ride.driverPhone}'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    child: const Text('Close'),
                  ),
                  if (canCancel) ...[
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorBg,
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.cancel_rounded, size: 16),
                      label: const Text('Force Cancel Ride'),
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        _cancelRide(ride);
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(String title, String val, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
              Text(val, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1),
            ],
          ),
        ),
      ],
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
            // Controls Bar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: isMobile ? double.infinity : 280,
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _fetch(),
                        decoration: InputDecoration(
                          hintText: 'Search route, origin, destination...',
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
                    DropdownButton<String>(
                      value: _selectedStatus,
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('All Rides')),
                        DropdownMenuItem(value: 'PUBLISHED', child: Text('Published / Open')),
                        DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
                        DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
                        DropdownMenuItem(value: 'CANCELLED', child: Text('Cancelled')),
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
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Rides List
            Expanded(
              child: BlocBuilder<RidesCubit, RidesState>(
                builder: (context, state) {
                  if (state is RidesLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  if (state is RidesError) {
                    return EmptyState(
                      title: 'Error loading rides',
                      message: state.message,
                      onRetry: _fetch,
                    );
                  }

                  if (state is RidesLoaded) {
                    final rides = state.rides;
                    if (rides.isEmpty) {
                      return const EmptyState(
                        title: 'No rides found',
                        message: 'No rides match your filter criteria.',
                        icon: Icons.alt_route_outlined,
                      );
                    }

                    if (isMobile) {
                      return ListView.separated(
                        itemCount: rides.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _buildMobileRideCard(rides[i]),
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
                                DataColumn(label: Text('Route')),
                                DataColumn(label: Text('Driver Host')),
                                DataColumn(label: Text('Departure Time')),
                                DataColumn(label: Text('Seats')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: rides.map((r) {
                                final canCancel = r.status == 'PUBLISHED' || r.status == 'IN_PROGRESS';

                                return DataRow(cells: [
                                  DataCell(
                                    Row(
                                      children: [
                                        const Icon(Icons.trip_origin, size: 14, color: AppColors.success),
                                        const SizedBox(width: 6),
                                        Text(r.startLocationName, style: AppTextStyles.bodyBold),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 6),
                                          child: Icon(Icons.arrow_forward, size: 14, color: AppColors.unselect),
                                        ),
                                        const Icon(Icons.location_on, size: 14, color: AppColors.error),
                                        const SizedBox(width: 6),
                                        Text(r.endLocationName, style: AppTextStyles.bodyBold),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(r.driverName ?? 'Driver')),
                                  DataCell(Text(r.departureAt.replaceFirst('T', ' ').split('.').first)),
                                  DataCell(Text('${r.availableSeats}/${r.totalSeats} Available')),
                                  DataCell(StatusBadge(status: r.status)),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_red_eye_outlined, color: AppColors.info),
                                          tooltip: 'View Route & Ride Details',
                                          onPressed: () => _showRideInspectionDialog(r),
                                        ),
                                        if (canCancel)
                                          IconButton(
                                            icon: const Icon(Icons.cancel, color: AppColors.error),
                                            tooltip: 'Cancel Ride',
                                            onPressed: () => _cancelRide(r),
                                          ),
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

  Widget _buildMobileRideCard(AdminRideItem ride) {
    final canCancel = ride.status == 'PUBLISHED' || ride.status == 'IN_PROGRESS';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Driver: ${ride.driverName ?? "Driver"}', style: AppTextStyles.caption),
                StatusBadge(status: ride.status),
              ],
            ),
            const SizedBox(height: 10),
            Text('${ride.startLocationName} ➔ ${ride.endLocationName}', style: AppTextStyles.bodyBold),
            const SizedBox(height: 6),
            Text('Seats: ${ride.availableSeats}/${ride.totalSeats} | Departure: ${ride.departureAt.split("T").first}', style: AppTextStyles.caption),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                    label: const Text('View Details'),
                    onPressed: () => _showRideInspectionDialog(ride),
                  ),
                ),
                if (canCancel) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('Cancel'),
                    onPressed: () => _cancelRide(ride),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
