import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth/admin_auth_cubit.dart';
import 'bloc/auth/admin_auth_repo.dart';
import 'bloc/banners/banners_cubit.dart';
import 'bloc/banners/banners_repo.dart';
import 'bloc/communities/communities_cubit.dart';
import 'bloc/communities/communities_repo.dart';
import 'bloc/dashboard/dashboard_cubit.dart';
import 'bloc/dashboard/dashboard_repo.dart';
import 'bloc/drivers/drivers_cubit.dart';
import 'bloc/drivers/drivers_repo.dart';
import 'bloc/pricing/pricing_cubit.dart';
import 'bloc/pricing/pricing_repo.dart';
import 'bloc/reports/reports_cubit.dart';
import 'bloc/reports/reports_repo.dart';
import 'bloc/rides/rides_cubit.dart';
import 'bloc/rides/rides_repo.dart';
import 'bloc/staff/staff_cubit.dart';
import 'bloc/staff/staff_repo.dart';
import 'bloc/stranger/stranger_cubit.dart';
import 'bloc/stranger/stranger_repo.dart';
import 'bloc/users/users_cubit.dart';
import 'bloc/users/users_repo.dart';
import 'bloc/vehicles/vehicles_cubit.dart';
import 'bloc/vehicles/vehicles_repo.dart';
import 'core/remote_data_source/admin_remote_data_source.dart';

class StateInjector extends StatelessWidget {
  final Widget child;

  const StateInjector({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final remoteDataSource = AdminRemoteDataSourceImpl();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AdminAuthRepo(remoteDataSource: remoteDataSource)),
        RepositoryProvider(create: (_) => DashboardRepo(remoteDataSource: remoteDataSource)),
        RepositoryProvider(create: (_) => UsersRepo(remoteDataSource: remoteDataSource)),
        RepositoryProvider(create: (_) => DriversRepo(remoteDataSource: remoteDataSource)),
        RepositoryProvider(create: (_) => VehiclesRepo(remoteDataSource: remoteDataSource)),
        RepositoryProvider(create: (_) => RidesRepo(remoteDataSource: remoteDataSource)),
        RepositoryProvider(create: (_) => ReportsRepo(remoteDataSource: remoteDataSource)),
        RepositoryProvider(create: (_) => CommunitiesRepo(remoteDataSource: remoteDataSource)),
        RepositoryProvider(create: (_) => PricingRepo(remoteDataSource: remoteDataSource)),
        RepositoryProvider(create: (_) => BannersRepo(remoteDataSource: remoteDataSource)),
        RepositoryProvider(create: (_) => StaffRepo(remoteDataSource: remoteDataSource)),
        RepositoryProvider(create: (_) => StrangerRepo(remoteDataSource: remoteDataSource)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (ctx) => AdminAuthCubit(repo: ctx.read<AdminAuthRepo>())..checkAuthStatus()),
          BlocProvider(create: (ctx) => DashboardCubit(repo: ctx.read<DashboardRepo>())),
          BlocProvider(create: (ctx) => UsersCubit(repo: ctx.read<UsersRepo>())),
          BlocProvider(create: (ctx) => DriversCubit(repo: ctx.read<DriversRepo>())),
          BlocProvider(create: (ctx) => VehiclesCubit(repo: ctx.read<VehiclesRepo>())),
          BlocProvider(create: (ctx) => RidesCubit(repo: ctx.read<RidesRepo>())),
          BlocProvider(create: (ctx) => ReportsCubit(repo: ctx.read<ReportsRepo>())),
          BlocProvider(create: (ctx) => CommunitiesCubit(repo: ctx.read<CommunitiesRepo>())),
          BlocProvider(create: (ctx) => PricingCubit(repo: ctx.read<PricingRepo>())),
          BlocProvider(create: (ctx) => BannersCubit(repo: ctx.read<BannersRepo>())),
          BlocProvider(create: (ctx) => StaffCubit(repo: ctx.read<StaffRepo>())),
          BlocProvider(create: (ctx) => StrangerCubit(repo: ctx.read<StrangerRepo>())),
        ],
        child: child,
      ),
    );
  }
}

