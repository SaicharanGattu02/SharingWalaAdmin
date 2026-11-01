import '../../core/remote_data_source/admin_remote_data_source.dart';
import '../../models/admin_models.dart';

class RidesRepo {
  final AdminRemoteDataSource remoteDataSource;

  RidesRepo({required this.remoteDataSource});

  Future<List<AdminRideItem>> getRides({String? status, String? search}) {
    return remoteDataSource.getRides(status: status, search: search);
  }

  Future<bool> cancelRide(String rideId, String reason) {
    return remoteDataSource.cancelRide(rideId, reason);
  }
}

