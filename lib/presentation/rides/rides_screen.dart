import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                        decoration: const InputDecoration(
                          hintText: 'Search route, origin, destination...',
                          prefixIcon: Icon(Icons.search),
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
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                                DataColumn(label: Text('Driver')),
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
                                    canCancel
                                        ? ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.errorBg,
                                              foregroundColor: AppColors.error,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            ),
                                            icon: const Icon(Icons.cancel, size: 14),
                                            label: const Text('Cancel Ride'),
                                            onPressed: () => _cancelRide(r),
                                          )
                                        : const Text('Archived', style: TextStyle(color: AppColors.unselect, fontSize: 12)),
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
            if (canCancel) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                icon: const Icon(Icons.cancel, size: 16),
                label: const Text('Cancel Ride'),
                onPressed: () => _cancelRide(ride),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

