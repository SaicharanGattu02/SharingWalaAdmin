import 'package:flutter_bloc/flutter_bloc.dart';
import 'rides_repo.dart';
import 'rides_state.dart';

class RidesCubit extends Cubit<RidesState> {
  final RidesRepo repo;

  RidesCubit({required this.repo}) : super(RidesInitial());

  Future<void> fetchRides({String? status, String? search}) async {
    emit(RidesLoading());
    try {
      final list = await repo.getRides(status: status, search: search);
      emit(RidesLoaded(rides: list));
    } catch (e) {
      emit(RidesError(e.toString()));
    }
  }

  Future<bool> cancelRide(String rideId, String reason) async {
    try {
      final ok = await repo.cancelRide(rideId, reason);
      if (ok) {
        await fetchRides();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }
}

