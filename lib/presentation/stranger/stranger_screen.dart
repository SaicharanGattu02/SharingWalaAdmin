import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/stranger/stranger_cubit.dart';
import '../../bloc/stranger/stranger_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/admin_models.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

class StrangerScreen extends StatefulWidget {
  const StrangerScreen({super.key});

  @override
  State<StrangerScreen> createState() => _StrangerScreenState();
}

class _StrangerScreenState extends State<StrangerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<StrangerCubit>().fetchAllStrangerData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteTrip(StrangerTripItem trip) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Moderate Stranger Trip',
        message: 'Remove stranger road trip "${trip.origin} ➔ ${trip.destination}" hosted by ${trip.hostName}?',
        confirmText: 'Remove Trip',
        confirmColor: AppColors.error,
        requireReason: true,
        reasonHint: 'Specify moderation reason...',
      ),
    );

    if (result != null && mounted) {
      final ok = await context.read<StrangerCubit>().deleteTrip(trip.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Trip removed from stranger feed' : 'Action failed'),
            backgroundColor: ok ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteMeetup(StrangerMeetupItem meetup) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Moderate Social Meetup',
        message: 'Cancel and remove meetup "${meetup.title}" at ${meetup.location}?',
        confirmText: 'Remove Meetup',
        confirmColor: AppColors.error,
        requireReason: false,
      ),
    );

    if (result != null && mounted) {
      final ok = await context.read<StrangerCubit>().deleteMeetup(meetup.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Meetup removed' : 'Action failed'),
            backgroundColor: ok ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deletePlan(StrangerPlanItem plan) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Moderate Travel Plan',
        message: 'Remove travel plan "${plan.title}" to ${plan.destination}?',
        confirmText: 'Remove Plan',
        confirmColor: AppColors.error,
        requireReason: false,
      ),
    );

    if (result != null && mounted) {
      final ok = await context.read<StrangerCubit>().deletePlan(plan.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Travel plan removed' : 'Action failed'),
            backgroundColor: ok ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteReel(StrangerReelItem reel) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Moderate Reel Video',
        message: 'Remove reel "${reel.title}" created by ${reel.userName}?',
        confirmText: 'Delete Reel',
        confirmColor: AppColors.error,
        requireReason: true,
        reasonHint: 'Specify violation (e.g. inappropriate content, copyright)...',
      ),
    );

    if (result != null && mounted) {
      final ok = await context.read<StrangerCubit>().deleteReel(reel.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Reel removed from feed' : 'Action failed'),
            backgroundColor: ok ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: BlocBuilder<StrangerCubit, StrangerState>(
        builder: (context, state) {
          if (state is StrangerLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is StrangerError) {
            return EmptyState(
              title: 'Error loading Stranger Section',
              message: state.message,
              onRetry: () => context.read<StrangerCubit>().fetchAllStrangerData(),
            );
          }

          if (state is StrangerLoaded) {
            final stats = state.stats;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Headline & Quick Summary Banner
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
                                      'STRANGER MODE CENTER',
                                      style: TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text('Social Commute & Travel Network', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'SharingWala Stranger Section Operations',
                                style: AppTextStyles.h2.copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Moderate long-distance co-travel trips, weekend meetups, travel plans, and short video reels.',
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
                            child: const Icon(Icons.travel_explore, size: 48, color: AppColors.primary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4 Quick Stats
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Stranger Trips',
                          value: stats.totalTrips.toString(),
                          subtitle: 'Active road trips',
                          icon: Icons.alt_route,
                          iconColor: const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Social Meetups',
                          value: stats.totalMeetups.toString(),
                          subtitle: 'Cafes, biking & casuals',
                          icon: Icons.local_cafe_outlined,
                          iconColor: const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Travel Plans',
                          value: stats.totalPlans.toString(),
                          subtitle: 'Co-traveler requests',
                          icon: Icons.backpack_outlined,
                          iconColor: const Color(0xFF10B981),
                        ),
                      ),
                      if (!isMobile) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Reels & Media',
                            value: stats.totalReels.toString(),
                            subtitle: 'Creator video clips',
                            icon: Icons.movie_outlined,
                            iconColor: const Color(0xFFEC4899),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tab Bar Header
                  Card(
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.textDark,
                      unselectedLabelColor: AppColors.textMuted,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(icon: Icon(Icons.directions_car_outlined, size: 18), text: 'Road Trips'),
                        Tab(icon: Icon(Icons.coffee_outlined, size: 18), text: 'Meetups'),
                        Tab(icon: Icon(Icons.map_outlined, size: 18), text: 'Travel Plans'),
                        Tab(icon: Icon(Icons.video_library_outlined, size: 18), text: 'Reels Feed'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tab Views Container
                  SizedBox(
                    height: 650,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Trips
                        _buildTripsTab(state.trips, isMobile, isTablet),

                        // Tab 2: Meetups
                        _buildMeetupsTab(state.meetups, isMobile, isTablet),

                        // Tab 3: Plans
                        _buildPlansTab(state.plans, isMobile, isTablet),

                        // Tab 4: Reels
                        _buildReelsTab(state.reels, isMobile),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // 1. Trips Tab
  Widget _buildTripsTab(List<StrangerTripItem> trips, bool isMobile, bool isTablet) {
    if (trips.isEmpty) {
      return const EmptyState(title: 'No stranger trips', message: 'No stranger road trips available right now.');
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.6 : 1.35,
      ),
      itemCount: trips.length,
      itemBuilder: (context, i) {
        final t = trips[i];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        t.mode.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0F172A)),
                      ),
                    ),
                    StatusBadge(status: t.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.trip_origin, size: 14, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text(t.origin, style: AppTextStyles.bodyBold),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.arrow_forward, size: 14, color: AppColors.unselect),
                    ),
                    const Icon(Icons.location_on, size: 14, color: AppColors.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(t.destination, style: AppTextStyles.bodyBold, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Departure: ${t.date} at ${t.time}', style: AppTextStyles.caption),
                const SizedBox(height: 6),
                Text('Vibe: ${t.vibe}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const Spacer(),
                const Divider(),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: t.hostAvatar != null ? NetworkImage(t.hostAvatar!) : null,
                      child: t.hostAvatar == null ? Text(t.hostName[0]) : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(t.hostName, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    Text('₹${t.pricePerPerson.toInt()}/seat', style: AppTextStyles.bodyBold.copyWith(color: AppColors.primaryDark)),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                      tooltip: 'Moderate Trip',
                      onPressed: () => _deleteTrip(t),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 2. Meetups Tab
  Widget _buildMeetupsTab(List<StrangerMeetupItem> meetups, bool isMobile, bool isTablet) {
    if (meetups.isEmpty) {
      return const EmptyState(title: 'No meetups found', message: 'No social stranger meetups right now.');
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.7 : 1.4,
      ),
      itemCount: meetups.length,
      itemBuilder: (context, i) {
        final m = meetups[i];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(6)),
                      child: Text(m.category, style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                      child: Text('${m.rsvpCount} Attending', style: TextStyle(color: Colors.green.shade800, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(m.title, style: AppTextStyles.bodyBold.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.place, size: 14, color: AppColors.error),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(m.location, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Date: ${m.date} • ${m.time}', style: AppTextStyles.caption),
                const Spacer(),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Host: ${m.hostName}', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
                      onPressed: () => _deleteMeetup(m),
                      child: const Text('Cancel Meetup'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 3. Plans Tab
  Widget _buildPlansTab(List<StrangerPlanItem> plans, bool isMobile, bool isTablet) {
    if (plans.isEmpty) {
      return const EmptyState(title: 'No travel plans', message: 'No travel plans posted yet.');
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.7 : 1.4,
      ),
      itemCount: plans.length,
      itemBuilder: (context, i) {
        final p = plans[i];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                      child: Text(p.style ?? 'Adventure', style: TextStyle(color: Colors.blue.shade800, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    Text('₹${p.budget.toInt()} Est.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(p.title, style: AppTextStyles.bodyBold.copyWith(fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text('Destination: ${p.destination}', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text('Departure: ${p.date}', style: AppTextStyles.caption),
                const Spacer(),
                const Divider(),
                Row(
                  children: [
                    Text('By: ${p.creatorName}', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('${p.companionsCount} Joined', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                      onPressed: () => _deletePlan(p),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 4. Reels Feed Tab
  Widget _buildReelsTab(List<StrangerReelItem> reels, bool isMobile) {
    if (reels.isEmpty) {
      return const EmptyState(title: 'No reels published', message: 'No stranger video reels found.');
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: reels.length,
      itemBuilder: (context, i) {
        final r = reels[i];

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                r.thumbnailUrl ?? 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=80',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.black87),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  icon: const Icon(Icons.delete_outline, color: Colors.white, size: 18),
                  tooltip: 'Moderate Reel',
                  onPressed: () => _deleteReel(r),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${r.userName}',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.title,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 14, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Text('${r.likesCount}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                        const SizedBox(width: 12),
                        const Icon(Icons.comment, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text('${r.commentsCount}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

