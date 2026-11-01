import '../../core/remote_data_source/admin_remote_data_source.dart';
import '../../models/admin_models.dart';

class DashboardRepo {
  final AdminRemoteDataSource remoteDataSource;

  DashboardRepo({required this.remoteDataSource});

  Future<DashboardStats> getStats() => remoteDataSource.getDashboardStats();
}

