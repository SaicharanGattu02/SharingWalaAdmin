import '../../core/remote_data_source/admin_remote_data_source.dart';
import '../../models/admin_models.dart';

class ReportsRepo {
  final AdminRemoteDataSource remoteDataSource;

  ReportsRepo({required this.remoteDataSource});

  Future<List<AdminReportItem>> getReports({String? status}) {
    return remoteDataSource.getReports(status: status);
  }

  Future<bool> resolveReport(
    String reportId,
    String status,
    String adminNotes, {
    bool penalize = false,
    String penalty = 'NONE',
  }) {
    return remoteDataSource.resolveReport(reportId, status, adminNotes, penalize: penalize, penalty: penalty);
  }

  // Emergency SOS Incidents
  Future<List<AdminSosIncidentItem>> getSosIncidents({String? status, String? search}) {
    return remoteDataSource.getSosIncidents(status: status, search: search);
  }

  Future<bool> updateSosStatus(String incidentId, String status, String adminNotes) {
    return remoteDataSource.updateSosStatus(incidentId, status, adminNotes);
  }

  // App Update Config
  Future<AppUpdateConfigModel?> getAppUpdateConfig() {
    return remoteDataSource.getAppUpdateConfig();
  }

  Future<bool> updateAppUpdateConfig(Map<String, dynamic> config) {
    return remoteDataSource.updateAppUpdateConfig(config);
  }
}

