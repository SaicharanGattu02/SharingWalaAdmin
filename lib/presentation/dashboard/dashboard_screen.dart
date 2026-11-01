import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/dashboard/dashboard_cubit.dart';
import '../../bloc/dashboard/dashboard_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().fetchDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (state is DashboardError) {
          return EmptyState(
            title: 'Failed to load dashboard',
            message: state.message,
            onRetry: () => context.read<DashboardCubit>().fetchDashboardStats(),
          );
        }

        if (state is DashboardLoaded) {
          final stats = state.stats;
          final isMobile = ResponsiveLayout.isMobile(context);
          final isTablet = ResponsiveLayout.isTablet(context);

          int crossAxisCount = 4;
          if (isMobile) {
            crossAxisCount = 1;
          } else if (isTablet) {
            crossAxisCount = 2;
          }

          return RefreshIndicator(
            onRefresh: () => context.read<DashboardCubit>().fetchDashboardStats(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Banner with Share2Go Yellow Accent
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'LIVE PLATFORM RADAR',
                                      style: TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Real-Time Synced',
                                    style: TextStyle(color: Colors.white60, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'SharingWala Operational Intelligence',
                                style: AppTextStyles.h2.copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Monitor ride matches, commuter verifications, fuel cost-sharing, and trust & safety tickets.',
                                style: AppTextStyles.subtitle.copyWith(color: AppColors.textLightMuted),
                              ),
                            ],
                          ),
                        ),
                        if (!isMobile) ...[
                          const SizedBox(width: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.bolt, size: 48, color: AppColors.primary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Metric Stat Cards Grid
                  GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: isMobile ? 2.5 : 1.4,
                    children: [
                      StatCard(
                        title: 'Total Commuters',
                        value: stats.totalUsers.toString(),
                        subtitle: '${stats.activeUsers} active on network',
                        icon: Icons.people_outline,
                        iconColor: const Color(0xFF3B82F6),
                        trend: '+14% MoM',
                      ),
                      StatCard(
                        title: 'Verified Drivers',
                        value: stats.totalDrivers.toString(),
                        subtitle: '${stats.pendingDrivers} awaiting license check',
                        icon: Icons.verified_user_outlined,
                        iconColor: AppColors.warning,
                        iconBgColor: AppColors.warningBg,
                        trend: '${stats.pendingDrivers} Pending',
                        isTrendPositive: stats.pendingDrivers == 0,
                      ),
                      StatCard(
                        title: 'Active Rides',
                        value: stats.activeRides.toString(),
                        subtitle: '${stats.completedRides} completed trips',
                        icon: Icons.directions_car_outlined,
                        iconColor: AppColors.success,
                        iconBgColor: AppColors.successBg,
                        trend: 'Live Now',
                      ),
                      StatCard(
                        title: 'Open Safety Reports',
                        value: stats.openReports.toString(),
                        subtitle: 'Trust & safety incidents',
                        icon: Icons.security_outlined,
                        iconColor: AppColors.error,
                        iconBgColor: AppColors.errorBg,
                        trend: stats.openReports > 0 ? 'Requires Action' : 'Clear',
                        isTrendPositive: stats.openReports == 0,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Secondary Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Total Bookings',
                          value: stats.totalBookings.toString(),
                          subtitle: 'Passenger confirmed seats',
                          icon: Icons.confirmation_number_outlined,
                          iconColor: const Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Vehicles on Grid',
                          value: stats.totalVehicles.toString(),
                          subtitle: '${stats.pendingVehicles} verification queued',
                          icon: Icons.two_wheeler_outlined,
                          iconColor: const Color(0xFFEC4899),
                        ),
                      ),
                      if (!isMobile) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            title: 'Active Communities',
                            value: stats.totalCommunities.toString(),
                            subtitle: 'Corporate & campus networks',
                            icon: Icons.corporate_fare_outlined,
                            iconColor: const Color(0xFF14B8A6),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Quick Action Hub
                  Text('Operational Action Hub', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildActionTile(
                            context,
                            icon: Icons.verified_user,
                            iconColor: AppColors.warning,
                            title: 'Driver License Approvals',
                            subtitle: 'Review pending driver licenses and documents',
                            count: stats.pendingDrivers,
                            route: '/drivers',
                          ),
                          const Divider(),
                          _buildActionTile(
                            context,
                            icon: Icons.security,
                            iconColor: AppColors.error,
                            title: 'Safety Incident Reports',
                            subtitle: 'Resolve customer disputes and conduct investigations',
                            count: stats.openReports,
                            route: '/reports',
                          ),
                          const Divider(),
                          _buildActionTile(
                            context,
                            icon: Icons.directions_car,
                            iconColor: AppColors.info,
                            title: 'Vehicle RC Cards & Insurance',
                            subtitle: 'Audit vehicle capacities and compliance',
                            count: stats.pendingVehicles,
                            route: '/vehicles',
                          ),
                          const Divider(),
                          _buildActionTile(
                            context,
                            icon: Icons.explore,
                            iconColor: const Color(0xFF10B981),
                            title: 'Stranger Section Moderation',
                            subtitle: 'Moderate co-travel trips, meetups, travel plans & creator reels',
                            count: 0,
                            route: '/stranger',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required int count,
    required String route,
  }) {
    return ListTile(
      onTap: () => context.go(route),
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: AppTextStyles.bodyBold),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.unselect),
        ],
      ),
    );
  }
}
