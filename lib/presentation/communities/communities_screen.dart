import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/communities/communities_cubit.dart';
import '../../bloc/communities/communities_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/status_badge.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CommunitiesCubit>().fetchCommunities();
  }

  void _showCreateCommunityDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final domainCtrl = TextEditingController();
    String type = 'OFFICE';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create Verified Community', style: AppTextStyles.h3),
                    const SizedBox(height: 16),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Community Name')),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: type,
                      decoration: const InputDecoration(labelText: 'Community Type'),
                      items: const [
                        DropdownMenuItem(value: 'OFFICE', child: Text('Corporate / Office Hub')),
                        DropdownMenuItem(value: 'COLLEGE', child: Text('College / University Campus')),
                        DropdownMenuItem(value: 'APARTMENT', child: Text('Gated Apartment / Township')),
                        DropdownMenuItem(value: 'LOCAL_COMMUNITY', child: Text('Local Commute Group')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => type = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: domainCtrl, decoration: const InputDecoration(labelText: 'Work Domain (e.g. @microsoft.com)')),
                    const SizedBox(height: 12),
                    TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description')),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            final name = nameCtrl.text.trim();
                            if (name.isEmpty) return;
                            Navigator.pop(context);
                            await context.read<CommunitiesCubit>().createCommunity({
                              'name': name,
                              'type': type,
                              'description': descCtrl.text.trim(),
                              'domainRestriction': domainCtrl.text.trim().isNotEmpty ? domainCtrl.text.trim() : null,
                            });
                          },
                          child: const Text('Create Community'),
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
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Text('Verified Corporate & Campus Hubs', style: AppTextStyles.h3),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _showCreateCommunityDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Community'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<CommunitiesCubit, CommunitiesState>(
                builder: (context, state) {
                  if (state is CommunitiesLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  if (state is CommunitiesError) {
                    return EmptyState(
                      title: 'Error loading communities',
                      message: state.message,
                      onRetry: () => context.read<CommunitiesCubit>().fetchCommunities(),
                    );
                  }

                  if (state is CommunitiesLoaded) {
                    final list = state.communities;
                    if (list.isEmpty) {
                      return const EmptyState(
                        title: 'No communities yet',
                        message: 'Create the first corporate or campus community.',
                      );
                    }

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 1 : 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: isMobile ? 2.2 : 1.6,
                      ),
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final c = list[i];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.business, color: Color(0xFF0F172A), size: 20),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        c.name,
                                        style: AppTextStyles.bodyBold.copyWith(fontSize: 15),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    StatusBadge(status: c.isActive ? 'ACTIVE' : 'INACTIVE'),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  c.description ?? 'Daily commute carpool and bikepool network for verified commuters.',
                                  style: AppTextStyles.caption,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Type: ${c.type}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text('${c.membersCount} Members', style: TextStyle(color: Colors.blue.shade800, fontSize: 11, fontWeight: FontWeight.bold)),
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

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
