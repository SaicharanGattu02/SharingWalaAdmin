import 'package:flutter_bloc/flutter_bloc.dart';
import 'stranger_repo.dart';
import 'stranger_state.dart';

class StrangerCubit extends Cubit<StrangerState> {
  final StrangerRepo repo;

  StrangerCubit({required this.repo}) : super(StrangerInitial());

  Future<void> fetchAllStrangerData() async {
    emit(StrangerLoading());
    try {
      final stats = await repo.getStats();
      final trips = await repo.getTrips();
      final meetups = await repo.getMeetups();
      final plans = await repo.getPlans();
      final reels = await repo.getReels();

      emit(StrangerLoaded(
        stats: stats,
        trips: trips,
        meetups: meetups,
        plans: plans,
        reels: reels,
      ));
    } catch (e) {
      emit(StrangerError(e.toString()));
    }
  }

  Future<bool> deleteTrip(String id) async {
    try {
      final ok = await repo.deleteTrip(id);
      if (ok) await fetchAllStrangerData();
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteMeetup(String id) async {
    try {
      final ok = await repo.deleteMeetup(id);
      if (ok) await fetchAllStrangerData();
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deletePlan(String id) async {
    try {
      final ok = await repo.deletePlan(id);
      if (ok) await fetchAllStrangerData();
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createReel(Map<String, dynamic> data) async {
    try {
      final ok = await repo.createReel(data);
      if (ok) await fetchAllStrangerData();
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteReel(String id) async {
    try {
      final ok = await repo.deleteReel(id);
      if (ok) await fetchAllStrangerData();
      return ok;
    } catch (_) {
      return false;
    }
  }
}

