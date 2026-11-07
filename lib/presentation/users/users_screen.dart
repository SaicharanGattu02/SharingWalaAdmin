import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/users/users_cubit.dart';
import '../../bloc/users/users_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/admin_models.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/status_badge.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();
  String _selectedRole = 'ALL';
  String _selectedStatus = 'ALL';

  @override
  void initState() {
    super.initState();
    context.read<UsersCubit>().fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    context.read<UsersCubit>().fetchUsers(
          search: _searchController.text.trim(),
          role: _selectedRole == 'ALL' ? null : _selectedRole,
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

  Future<void> _handleStatusChange(AdminUserItem user, String newStatus) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Change Account Status',
        message: 'Are you sure you want to change ${user.displayName}\'s account status to $newStatus?',
        confirmText: newStatus == 'ACTIVE' ? 'Activate' : 'Proceed',
        confirmColor: newStatus == 'ACTIVE' ? AppColors.success : AppColors.error,
        requireReason: newStatus != 'ACTIVE',
        reasonHint: 'Reason for suspension or block...',
      ),
    );

    if (result != null && mounted) {
      final success = await context.read<UsersCubit>().updateUserStatus(
            user.id,
            newStatus,
            reason: result['reason'] as String?,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'User status updated successfully to [$newStatus]' : 'Failed to update status'),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  void _showUserDetailsDialog(AdminUserItem user) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 540),
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
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: Text(
                          user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.displayName, style: AppTextStyles.h3),
                          Text('@${user.username}', style: AppTextStyles.caption),
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

              // Overview Box
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
                      children: [
                        Expanded(
                          child: _buildInfoItem('Phone Number', user.phone, Icons.phone_rounded),
                        ),
                        Expanded(
                          child: _buildInfoItem('Email Address', user.email ?? 'Not provided', Icons.email_rounded),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem('Gender', user.gender.replaceAll('_', ' '), Icons.person_rounded),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            'Member Since',
                            user.createdAt?.split('T').first ?? 'Verified',
                            Icons.calendar_today_rounded,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Platform Persona: ', style: TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                            StatusBadge(status: user.isDriver ? 'DRIVER' : 'COMMUTER'),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Status: ', style: TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                            StatusBadge(status: user.status),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Toolbar
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                    label: const Text('Call User'),
                    onPressed: () => _launchUrl('tel:${user.phone}'),
                  ),
                  const Spacer(),
                  if (user.status != 'ACTIVE')
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Reactivate'),
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        _handleStatusChange(user, 'ACTIVE');
                      },
                    ),
                  if (user.status == 'ACTIVE') ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.warning),
                      icon: const Icon(Icons.pause_circle_outline, size: 16),
                      label: const Text('Suspend'),
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        _handleStatusChange(user, 'SUSPENDED');
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorBg,
                        foregroundColor: AppColors.error,
                      ),
                      icon: const Icon(Icons.block, size: 16),
                      label: const Text('Block Account'),
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        _handleStatusChange(user, 'BLOCKED');
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

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1),
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
            // Controls & Filter Bar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Search Bar
                    SizedBox(
                      width: isMobile ? double.infinity : 280,
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _applyFilter(),
                        decoration: InputDecoration(
                          hintText: 'Search name, phone, email...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilter();
                            },
                          ),
                        ),
                      ),
                    ),

                    // Role Filter
                    DropdownButton<String>(
                      value: _selectedRole,
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('All Roles')),
                        DropdownMenuItem(value: 'USER', child: Text('Commuters / Passengers')),
                        DropdownMenuItem(value: 'RIDER', child: Text('Drivers / Hosts')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedRole = val);
                          _applyFilter();
                        }
                      },
                    ),

                    // Status Filter
                    DropdownButton<String>(
                      value: _selectedStatus,
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('All Statuses')),
                        DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                        DropdownMenuItem(value: 'SUSPENDED', child: Text('Suspended')),
                        DropdownMenuItem(value: 'BLOCKED', child: Text('Blocked')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedStatus = val);
                          _applyFilter();
                        }
                      },
                    ),

                    ElevatedButton.icon(
                      onPressed: _applyFilter,
                      icon: const Icon(Icons.filter_list, size: 16),
                      label: const Text('Filter'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Users List View
            Expanded(
              child: BlocBuilder<UsersCubit, UsersState>(
                builder: (context, state) {
                  if (state is UsersLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  if (state is UsersError) {
                    return EmptyState(
                      title: 'Error loading users',
                      message: state.message,
                      onRetry: _applyFilter,
                    );
                  }

                  if (state is UsersLoaded) {
                    final users = state.users;
                    if (users.isEmpty) {
                      return const EmptyState(
                        title: 'No users found',
                        message: 'Try adjusting your search criteria or role filters.',
                      );
                    }

                    if (isMobile) {
                      return ListView.separated(
                        itemCount: users.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _buildMobileUserCard(users[index]),
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
                                DataColumn(label: Text('User')),
                                DataColumn(label: Text('Phone')),
                                DataColumn(label: Text('Role')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Gender')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: users.map((u) {
                                return DataRow(cells: [
                                  DataCell(
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                                          child: Text(
                                            u.displayName.isNotEmpty ? u.displayName[0] : 'U',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(u.displayName, style: AppTextStyles.bodyBold),
                                            Text(u.email ?? '@${u.username}', style: AppTextStyles.caption),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(u.phone, style: AppTextStyles.body)),
                                  DataCell(StatusBadge(status: u.isDriver ? 'DRIVER' : 'COMMUTER')),
                                  DataCell(StatusBadge(status: u.status)),
                                  DataCell(Text(u.gender, style: AppTextStyles.caption)),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_red_eye_outlined, color: AppColors.info),
                                          tooltip: 'View Profile Details',
                                          onPressed: () => _showUserDetailsDialog(u),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert, size: 18),
                                          onSelected: (val) => _handleStatusChange(u, val),
                                          itemBuilder: (context) => [
                                            if (u.status != 'ACTIVE')
                                              const PopupMenuItem(
                                                value: 'ACTIVE',
                                                child: Text('Reactivate Account'),
                                              ),
                                            if (u.status != 'SUSPENDED')
                                              const PopupMenuItem(
                                                value: 'SUSPENDED',
                                                child: Text('Suspend Account'),
                                              ),
                                            if (u.status != 'BLOCKED')
                                              const PopupMenuItem(
                                                value: 'BLOCKED',
                                                child: Text('Block Account'),
                                              ),
                                          ],
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

  Widget _buildMobileUserCard(AdminUserItem user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    user.displayName.isNotEmpty ? user.displayName[0] : 'U',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName, style: AppTextStyles.bodyBold),
                      Text(user.phone, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                StatusBadge(status: user.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                StatusBadge(status: user.isDriver ? 'DRIVER' : 'COMMUTER'),
                const Spacer(),
                OutlinedButton.icon(
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 14),
                  label: const Text('Details'),
                  onPressed: () => _showUserDetailsDialog(user),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
