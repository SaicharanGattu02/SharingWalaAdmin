import 'package:flutter_bloc/flutter_bloc.dart';
import 'vehicles_repo.dart';
import 'vehicles_state.dart';

class VehiclesCubit extends Cubit<VehiclesState> {
  final VehiclesRepo repo;

  VehiclesCubit({required this.repo}) : super(VehiclesInitial());

  Future<void> fetchVehicles({String? status, String? vehicleType}) async {
    emit(VehiclesLoading());
    try {
      final list = await repo.getVehicles(status: status, vehicleType: vehicleType);
      emit(VehiclesLoaded(vehicles: list));
    } catch (e) {
      emit(VehiclesError(e.toString()));
    }
  }

  Future<bool> verifyVehicle(String vehicleId, String status, {String? reason}) async {
    try {
      final ok = await repo.verifyVehicle(vehicleId, status, reason: reason);
      if (ok) {
        await fetchVehicles();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }
}

