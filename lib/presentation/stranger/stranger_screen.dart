import 'dart:async';
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
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    context.read<StrangerCubit>().fetchAllStrangerData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = query.trim().toLowerCase();
        });
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    setState(() {
      _searchQuery = '';
    });
  }

  // -------------------------------------------------------------
  // MODERATION ACTIONS
  // -------------------------------------------------------------

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

  // -------------------------------------------------------------
  // ON-TAP DETAIL INSPECTION DIALOGS
  // -------------------------------------------------------------

  void _showTripDetailsDialog(StrangerTripItem trip) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${trip.mode.toUpperCase()} POOL',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF0F172A)),
                    ),
                  ),
                  StatusBadge(status: trip.status),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.trip_origin, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trip.origin,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 9, top: 4, bottom: 4),
                child: Container(width: 2, height: 16, color: Colors.grey.shade300),
              ),
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trip.destination,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: trip.hostAvatar != null ? NetworkImage(trip.hostAvatar!) : null,
                    child: trip.hostAvatar == null ? Text(trip.hostName.isNotEmpty ? trip.hostName[0] : 'U') : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Host: ${trip.hostName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('Trip ID: ${trip.id}', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  Text('₹${trip.pricePerPerson.toInt()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
                  const Text(' / seat', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Departure Schedule:', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                        Text('${trip.date} at ${trip.time}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Travel Vibe & Style:', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                        Text(trip.vibe, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _deleteTrip(trip);
                    },
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Moderate Trip'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMeetupDetailsDialog(StrangerMeetupItem meetup) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text(meetup.category, style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.w800, fontSize: 11)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text('${meetup.rsvpCount} Attending', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(meetup.title, style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.place, color: AppColors.error, size: 16),
                  const SizedBox(width: 6),
                  Expanded(child: Text(meetup.location, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.blueGrey),
                  const SizedBox(width: 6),
                  Text('Date: ${meetup.date} • Time: ${meetup.time}', style: AppTextStyles.caption),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 8),
              Text('Organized by: ${meetup.hostName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _deleteMeetup(meetup);
                    },
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: const Text('Cancel Meetup'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlanDetailsDialog(StrangerPlanItem plan) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text(plan.style ?? 'Adventure', style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.w800, fontSize: 11)),
                  ),
                  Text('₹${plan.budget.toInt()} Est. Budget', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primaryDark)),
                ],
              ),
              const SizedBox(height: 16),
              Text(plan.title, style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text('Destination: ${plan.destination}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Planned Departure: ${plan.date}', style: AppTextStyles.caption),
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 8),
              Text('Posted by: ${plan.creatorName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('${plan.companionsCount} Travelers Joined', style: AppTextStyles.caption),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _deletePlan(plan);
                    },
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Remove Plan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReelDetailsDialog(StrangerReelItem reel) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.network(
                    reel.thumbnailUrl ?? 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=80',
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(height: 260, color: Colors.black87),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('@${reel.userName}', style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 6),
                    Text(reel.title, style: AppTextStyles.bodyBold),
                    if (reel.description != null && reel.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(reel.description!, style: AppTextStyles.caption),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 16, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Text('${reel.likesCount} Likes', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 16),
                        const Icon(Icons.comment, size: 16, color: Colors.blueGrey),
                        const SizedBox(width: 4),
                        Text('${reel.commentsCount} Comments', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _deleteReel(reel);
                          },
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Delete Reel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // BUILD METHOD
  // -------------------------------------------------------------

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
            final currentTabIndex = _tabController.index;

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

                  // 4 Interactive Navigation KPI Cards (Tap to switch tabs!)
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Stranger Trips',
                          value: stats.totalTrips.toString(),
                          subtitle: 'Active road trips',
                          icon: Icons.alt_route,
                          iconColor: const Color(0xFF3B82F6),
                          isSelected: currentTabIndex == 0,
                          onTap: () => _tabController.animateTo(0),
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
                          isSelected: currentTabIndex == 1,
                          onTap: () => _tabController.animateTo(1),
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
                          isSelected: currentTabIndex == 2,
                          onTap: () => _tabController.animateTo(2),
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
                            isSelected: currentTabIndex == 3,
                            onTap: () => _tabController.animateTo(3),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Dynamic Search Toolbar with 300ms Debounce
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.blueGrey, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: currentTabIndex == 0
                                  ? 'Search road trips by origin, destination, host, or vehicle...'
                                  : currentTabIndex == 1
                                      ? 'Search meetups by title, venue location, category, or host...'
                                      : currentTabIndex == 2
                                          ? 'Search travel plans by title, destination, or creator...'
                                          : 'Search creator reels by caption, title, or username...',
                              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('Debounced Filter Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            tooltip: 'Clear Search',
                            onPressed: _clearSearch,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

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

  // -------------------------------------------------------------
  // TAB 1: TRIPS TAB
  // -------------------------------------------------------------

  Widget _buildTripsTab(List<StrangerTripItem> allTrips, bool isMobile, bool isTablet) {
    final trips = _searchQuery.isEmpty
        ? allTrips
        : allTrips.where((t) {
            return t.origin.toLowerCase().contains(_searchQuery) ||
                t.destination.toLowerCase().contains(_searchQuery) ||
                t.hostName.toLowerCase().contains(_searchQuery) ||
                t.vibe.toLowerCase().contains(_searchQuery) ||
                t.mode.toLowerCase().contains(_searchQuery);
          }).toList();

    if (trips.isEmpty) {
      return EmptyState(
        title: _searchQuery.isEmpty ? 'No stranger trips' : 'No trips match "$_searchQuery"',
        message: _searchQuery.isEmpty ? 'No stranger road trips available right now.' : 'Try adjusting your search query.',
      );
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

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showTripDetailsDialog(t),
            borderRadius: BorderRadius.circular(12),
            child: Card(
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
                          child: t.hostAvatar == null ? Text(t.hostName.isNotEmpty ? t.hostName[0] : 'U') : null,
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
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 2: MEETUPS TAB
  // -------------------------------------------------------------

  Widget _buildMeetupsTab(List<StrangerMeetupItem> allMeetups, bool isMobile, bool isTablet) {
    final meetups = _searchQuery.isEmpty
        ? allMeetups
        : allMeetups.where((m) {
            return m.title.toLowerCase().contains(_searchQuery) ||
                m.location.toLowerCase().contains(_searchQuery) ||
                m.category.toLowerCase().contains(_searchQuery) ||
                m.hostName.toLowerCase().contains(_searchQuery);
          }).toList();

    if (meetups.isEmpty) {
      return EmptyState(
        title: _searchQuery.isEmpty ? 'No meetups found' : 'No meetups match "$_searchQuery"',
        message: _searchQuery.isEmpty ? 'No social stranger meetups right now.' : 'Try adjusting your search query.',
      );
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

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showMeetupDetailsDialog(m),
            borderRadius: BorderRadius.circular(12),
            child: Card(
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
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 3: PLANS TAB
  // -------------------------------------------------------------

  Widget _buildPlansTab(List<StrangerPlanItem> allPlans, bool isMobile, bool isTablet) {
    final plans = _searchQuery.isEmpty
        ? allPlans
        : allPlans.where((p) {
            return p.title.toLowerCase().contains(_searchQuery) ||
                p.destination.toLowerCase().contains(_searchQuery) ||
                p.creatorName.toLowerCase().contains(_searchQuery) ||
                (p.style ?? '').toLowerCase().contains(_searchQuery);
          }).toList();

    if (plans.isEmpty) {
      return EmptyState(
        title: _searchQuery.isEmpty ? 'No travel plans' : 'No travel plans match "$_searchQuery"',
        message: _searchQuery.isEmpty ? 'No travel plans posted yet.' : 'Try adjusting your search query.',
      );
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

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showPlanDetailsDialog(p),
            borderRadius: BorderRadius.circular(12),
            child: Card(
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
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 4: REELS FEED TAB
  // -------------------------------------------------------------

  Widget _buildReelsTab(List<StrangerReelItem> allReels, bool isMobile) {
    final reels = _searchQuery.isEmpty
        ? allReels
        : allReels.where((r) {
            return r.title.toLowerCase().contains(_searchQuery) ||
                r.userName.toLowerCase().contains(_searchQuery) ||
                (r.description ?? '').toLowerCase().contains(_searchQuery);
          }).toList();

    if (reels.isEmpty) {
      return EmptyState(
        title: _searchQuery.isEmpty ? 'No reels published' : 'No reels match "$_searchQuery"',
        message: _searchQuery.isEmpty ? 'No stranger video reels found.' : 'Try adjusting your search query.',
      );
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

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showReelDetailsDialog(r),
            borderRadius: BorderRadius.circular(12),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    r.thumbnailUrl ?? 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.black87),
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
            ),
          ),
        );
      },
    );
  }
}
