import '../../core/remote_data_source/admin_remote_data_source.dart';
import '../../models/admin_models.dart';

class DriversRepo {
  final AdminRemoteDataSource remoteDataSource;

  DriversRepo({required this.remoteDataSource});

  Future<List<AdminDriverItem>> getDrivers({String? status, String? search}) {
    return remoteDataSource.getDrivers(status: status, search: search);
  }

  Future<bool> verifyDriver(String driverId, String status, {String? reason}) {
    return remoteDataSource.verifyDriver(driverId, status, reason: reason);
  }
}

