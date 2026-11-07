import 'package:go_router/go_router.dart';
import '../presentation/auth/admin_login_screen.dart';
import '../presentation/banners/banners_screen.dart';
import '../presentation/communities/communities_screen.dart';
import '../presentation/dashboard/dashboard_screen.dart';
import '../presentation/drivers/drivers_screen.dart';
import '../presentation/pricing/pricing_screen.dart';
import '../presentation/reports/reports_screen.dart';
import '../presentation/rides/rides_screen.dart';
import '../presentation/stranger/stranger_screen.dart';
import '../presentation/shell/admin_shell.dart';
import '../presentation/staff/staff_screen.dart';
import '../presentation/users/users_screen.dart';
import '../presentation/vehicles/vehicles_screen.dart';
import '../services/admin_auth_service.dart';

class AdminRouter {
  static final router = GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) async {
      final isAuth = await AdminAuthService.isAuthenticated();
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuth && !isLoggingIn) {
        return '/login';
      }

      if (isAuth && isLoggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),

      // Shell Route wrapping all dashboard sections
      ShellRoute(
        builder: (context, state, child) {
          final loc = state.matchedLocation;
          String title = 'Dashboard';

          if (loc.startsWith('/sos')) {
            title = 'Emergency SOS Command Center';
          } else if (loc.startsWith('/users')) {
            title = 'Users Directory';
          } else if (loc.startsWith('/drivers')) {
            title = 'Driver Verification';
          } else if (loc.startsWith('/vehicles')) {
            title = 'Vehicles Compliance';
          } else if (loc.startsWith('/rides')) {
            title = 'Rides & Trips';
          } else if (loc.startsWith('/stranger')) {
            title = 'Stranger Section (Trips, Meetups, Plans & Reels)';
          } else if (loc.startsWith('/reports')) {
            title = 'Trust & Safety Reports';
          } else if (loc.startsWith('/communities')) {
            title = 'Corporate Communities';
          } else if (loc.startsWith('/pricing')) {
            title = 'Pricing Rules & Caps';
          } else if (loc.startsWith('/banners')) {
            title = 'Promotional Banners';
          } else if (loc.startsWith('/staff')) {
            title = 'Staff Management & Audit';
          }

          return AdminShell(
            currentRoute: loc,
            title: title,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/sos',
            builder: (context, state) => const ReportsScreen(initialTabIndex: 0),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersScreen(),
          ),
          GoRoute(
            path: '/drivers',
            builder: (context, state) => const DriversScreen(),
          ),
          GoRoute(
            path: '/vehicles',
            builder: (context, state) => const VehiclesScreen(),
          ),
          GoRoute(
            path: '/rides',
            builder: (context, state) => const RidesScreen(),
          ),
          GoRoute(
            path: '/stranger',
            builder: (context, state) => const StrangerScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(initialTabIndex: 1),
          ),
          GoRoute(
            path: '/communities',
            builder: (context, state) => const CommunitiesScreen(),
          ),
          GoRoute(
            path: '/pricing',
            builder: (context, state) => const PricingScreen(),
          ),
          GoRoute(
            path: '/banners',
            builder: (context, state) => const BannersScreen(),
          ),
          GoRoute(
            path: '/staff',
            builder: (context, state) => const StaffScreen(),
          ),
        ],
      ),
    ],
  );
}
