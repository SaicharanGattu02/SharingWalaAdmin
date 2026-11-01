import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/banners/banners_cubit.dart';
import '../../bloc/banners/banners_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/status_badge.dart';

class BannersScreen extends StatefulWidget {
  const BannersScreen({super.key});

  @override
  State<BannersScreen> createState() => _BannersScreenState();
}

class _BannersScreenState extends State<BannersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BannersCubit>().fetchBanners();
  }

  void _showCreateBannerDialog() {
    final titleCtrl = TextEditingController();
    final subCtrl = TextEditingController();
    final imgCtrl = TextEditingController();
    String role = 'ALL';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Publish Promotional Banner', style: AppTextStyles.h3),
                    const SizedBox(height: 16),
                    TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Banner Headline')),
                    const SizedBox(height: 12),
                    TextField(controller: subCtrl, decoration: const InputDecoration(labelText: 'Subtitle / Tagline')),
                    const SizedBox(height: 12),
                    TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'Image CDN URL')),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: role,
                      decoration: const InputDecoration(labelText: 'Target Audience'),
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('All Users & Drivers')),
                        DropdownMenuItem(value: 'USER', child: Text('Commuters / Passengers Only')),
                        DropdownMenuItem(value: 'RIDER', child: Text('Drivers / Hosts Only')),
                        DropdownMenuItem(value: 'STRANGER', child: Text('Stranger Mode Only')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => role = val);
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            final title = titleCtrl.text.trim();
                            final img = imgCtrl.text.trim();
                            if (title.isEmpty || img.isEmpty) return;
                            Navigator.pop(context);
                            await context.read<BannersCubit>().createBanner({
                              'title': title,
                              'subtitle': subCtrl.text.trim(),
                              'imageUrl': img,
                              'targetRole': role,
                              'category': 'PROMOTION',
                              'isActive': true,
                            });
                          },
                          child: const Text('Publish Banner'),
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
                Text('Hero Carousel & Promotional Banners', style: AppTextStyles.h3),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _showCreateBannerDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Banner'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<BannersCubit, BannersState>(
                builder: (context, state) {
                  if (state is BannersLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  if (state is BannersError) {
                    return EmptyState(
                      title: 'Error loading banners',
                      message: state.message,
                      onRetry: () => context.read<BannersCubit>().fetchBanners(),
                    );
                  }

                  if (state is BannersLoaded) {
                    final banners = state.banners;

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 1 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: isMobile ? 1.8 : 2.0,
                      ),
                      itemCount: banners.length,
                      itemBuilder: (context, i) {
                        final b = banners[i];

                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 110,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  image: DecorationImage(
                                    image: NetworkImage(b.imageUrl),
                                    fit: BoxFit.cover,
                                    onError: (_, __) {},
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  alignment: Alignment.topRight,
                                  child: StatusBadge(status: b.targetRole),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(b.title, style: AppTextStyles.bodyBold.copyWith(fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Text(b.subtitle ?? '', style: AppTextStyles.caption, maxLines: 1),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        StatusBadge(status: b.isActive ? 'ACTIVE' : 'INACTIVE'),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                          onPressed: () => context.read<BannersCubit>().deleteBanner(b.id),
                                        ),
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
