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
}

