import '../../core/remote_data_source/admin_remote_data_source.dart';
import '../../models/admin_models.dart';

class StaffRepo {
  final AdminRemoteDataSource remoteDataSource;

  StaffRepo({required this.remoteDataSource});

  Future<List<AdminStaffItem>> getStaff() => remoteDataSource.getStaff();

  Future<List<AdminAuditLogItem>> getAuditLogs() => remoteDataSource.getAuditLogs();
}

