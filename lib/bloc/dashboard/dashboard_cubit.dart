import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_repo.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepo repo;

  DashboardCubit({required this.repo}) : super(DashboardInitial());

  Future<void> fetchDashboardStats() async {
    emit(DashboardLoading());
    try {
      final stats = await repo.getStats();
      emit(DashboardLoaded(stats: stats));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}

