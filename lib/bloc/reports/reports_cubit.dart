import 'package:flutter_bloc/flutter_bloc.dart';
import 'reports_repo.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepo repo;

  ReportsCubit({required this.repo}) : super(ReportsInitial());

  Future<void> fetchReports({String? status}) async {
    final current = state;
    emit(ReportsLoading());
    try {
      final reports = await repo.getReports(status: status);
      final sosList = await repo.getSosIncidents();
      final config = await repo.getAppUpdateConfig();

      emit(ReportsLoaded(
        reports: reports,
        sosIncidents: sosList,
        appConfig: config,
      ));
    } catch (e) {
      if (current is ReportsLoaded) {
        emit(current);
      } else {
        emit(ReportsError(e.toString()));
      }
    }
  }

  Future<void> fetchSosIncidents({String? status, String? search}) async {
    try {
      final sosList = await repo.getSosIncidents(status: status, search: search);
      if (state is ReportsLoaded) {
        emit((state as ReportsLoaded).copyWith(sosIncidents: sosList));
      }
    } catch (_) {}
  }

  Future<bool> updateSosStatus(String incidentId, String status, String adminNotes) async {
    try {
      final ok = await repo.updateSosStatus(incidentId, status, adminNotes);
      if (ok) {
        await fetchSosIncidents();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateAppConfig(Map<String, dynamic> config) async {
    try {
      final ok = await repo.updateAppUpdateConfig(config);
      if (ok) {
        final newConfig = await repo.getAppUpdateConfig();
        if (state is ReportsLoaded) {
          emit((state as ReportsLoaded).copyWith(appConfig: newConfig));
        }
      }
      return ok;
    } catch (_) {
      return false;
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

