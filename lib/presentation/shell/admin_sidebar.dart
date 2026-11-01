import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AdminSidebarItem {
  final String title;
  final IconData icon;
  final String route;
  final String? badge;

  const AdminSidebarItem({
    required this.title,
    required this.icon,
    required this.route,
    this.badge,
  });
}

class AdminSidebar extends StatelessWidget {
  final String currentRoute;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  const AdminSidebar({
    super.key,
    required this.currentRoute,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  static const List<AdminSidebarItem> mainItems = [
    AdminSidebarItem(title: 'Dashboard', icon: Icons.dashboard_outlined, route: '/dashboard'),
    AdminSidebarItem(title: 'Users', icon: Icons.people_outline, route: '/users'),
    AdminSidebarItem(title: 'Driver Verification', icon: Icons.verified_user_outlined, route: '/drivers'),
    AdminSidebarItem(title: 'Vehicles', icon: Icons.directions_car_outlined, route: '/vehicles'),
    AdminSidebarItem(title: 'Rides & Trips', icon: Icons.alt_route_outlined, route: '/rides'),
    AdminSidebarItem(title: 'Stranger Section', icon: Icons.explore_outlined, route: '/stranger'),
    AdminSidebarItem(title: 'Trust & Safety', icon: Icons.security_outlined, route: '/reports'),
    AdminSidebarItem(title: 'Communities', icon: Icons.corporate_fare_outlined, route: '/communities'),
    AdminSidebarItem(title: 'Pricing Rules', icon: Icons.price_change_outlined, route: '/pricing'),
    AdminSidebarItem(title: 'Banners', icon: Icons.view_carousel_outlined, route: '/banners'),
    AdminSidebarItem(title: 'Staff & Audit Logs', icon: Icons.manage_accounts_outlined, route: '/staff'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCollapsed ? 80 : 260,
      decoration: const BoxDecoration(
        color: Color(0xFF0B132B), // Modern Deep Navy / Slate
        border: Border(right: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Column(
        children: [
          // Logo & Branding
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bolt, color: Color(0xFF0F172A), size: 20),
                    ),
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SHARINGWALA',
                          style: AppTextStyles.h3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          'ADMIN CONSOLE',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Navigation Links
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: mainItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = mainItems[index];
                final isActive = currentRoute.startsWith(item.route);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      if (!isActive) {
                        context.go(item.route);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 20,
                            color: isActive ? const Color(0xFF0F172A) : Colors.white70,
                          ),
                          if (!isCollapsed) ...[
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  color: isActive ? const Color(0xFF0F172A) : Colors.white70,
                                  fontSize: 14,
                                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (item.badge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  item.badge!,
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Portal Version Footnote
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'API: v1.0.0 (Connected)',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

