import 'package:flutter_bloc/flutter_bloc.dart';
import 'reports_repo.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepo repo;

  ReportsCubit({required this.repo}) : super(ReportsInitial());

  Future<void> fetchReports({String? status}) async {
    emit(ReportsLoading());
    try {
      final list = await repo.getReports(status: status);
      emit(ReportsLoaded(reports: list));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }

  Future<bool> resolveReport(
    String reportId,
    String status,
    String adminNotes, {
    bool penalize = false,
    String penalty = 'NONE',
  }) async {
    try {
      final ok = await repo.resolveReport(reportId, status, adminNotes, penalize: penalize, penalty: penalty);
      if (ok) {
        await fetchReports();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }
}

