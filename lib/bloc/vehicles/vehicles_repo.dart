import '../../core/remote_data_source/admin_remote_data_source.dart';
import '../../models/admin_models.dart';

class VehiclesRepo {
  final AdminRemoteDataSource remoteDataSource;

  VehiclesRepo({required this.remoteDataSource});

  Future<List<AdminVehicleItem>> getVehicles({String? status, String? vehicleType}) {
    return remoteDataSource.getVehicles(status: status, vehicleType: vehicleType);
  }

  Future<bool> verifyVehicle(String vehicleId, String status, {String? reason}) {
    return remoteDataSource.verifyVehicle(vehicleId, status, reason: reason);
  }
}

