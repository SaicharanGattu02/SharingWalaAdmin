import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/admin_auth_cubit.dart';
import '../../bloc/auth/admin_auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/responsive_layout.dart';

class AdminHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onOpenDrawer;

  const AdminHeader({
    super.key,
    required this.title,
    this.onOpenDrawer,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.lightBorder)),
      ),
      child: Row(
        children: [
          if (isMobile) ...[
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onOpenDrawer,
            ),
            const SizedBox(width: 8),
          ],

          // Page Title & Breadcrumb
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(fontSize: isMobile ? 16 : 18),
                ),
                Text(
                  'Overview & Operations Management',
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),

          // User Profile & Logout
          BlocBuilder<AdminAuthCubit, AdminAuthState>(
            builder: (context, state) {
              String name = 'Super Admin';
              String role = 'SUPER_ADMIN';

              if (state is AdminAuthAuthenticated) {
                name = state.admin.name;
                role = state.admin.roles.isNotEmpty ? state.admin.roles.first : 'ADMIN';
              }

              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      role,
                      style: const TextStyle(
                        color: Color(0xFF9A7B00),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 14),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF0F172A),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'A',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(name, style: AppTextStyles.bodyBold.copyWith(fontSize: 13)),
                  ],
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.logout, size: 20, color: AppColors.error),
                    tooltip: 'Logout',
                    onPressed: () {
                      context.read<AdminAuthCubit>().logout();
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

