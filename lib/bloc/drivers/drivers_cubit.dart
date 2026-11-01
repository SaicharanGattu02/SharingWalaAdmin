import 'package:flutter_bloc/flutter_bloc.dart';
import 'drivers_repo.dart';
import 'drivers_state.dart';

class DriversCubit extends Cubit<DriversState> {
  final DriversRepo repo;

  DriversCubit({required this.repo}) : super(DriversInitial());

  Future<void> fetchDrivers({String? status, String? search}) async {
    emit(DriversLoading());
    try {
      final drivers = await repo.getDrivers(status: status, search: search);
      emit(DriversLoaded(drivers: drivers));
    } catch (e) {
      emit(DriversError(e.toString()));
    }
  }

  Future<bool> verifyDriver(String driverId, String status, {String? reason}) async {
    try {
      final ok = await repo.verifyDriver(driverId, status, reason: reason);
      if (ok) {
        await fetchDrivers();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }
}

