import '../../core/remote_data_source/admin_remote_data_source.dart';
import '../../models/admin_models.dart';

class StrangerRepo {
  final AdminRemoteDataSource remoteDataSource;

  StrangerRepo({required this.remoteDataSource});

  Future<StrangerStats> getStats() => remoteDataSource.getStrangerStats();

  Future<List<StrangerTripItem>> getTrips() => remoteDataSource.getStrangerTrips();

  Future<bool> deleteTrip(String id) => remoteDataSource.deleteStrangerTrip(id);

  Future<List<StrangerMeetupItem>> getMeetups() => remoteDataSource.getStrangerMeetups();

  Future<bool> deleteMeetup(String id) => remoteDataSource.deleteStrangerMeetup(id);

  Future<List<StrangerPlanItem>> getPlans() => remoteDataSource.getStrangerPlans();

  Future<bool> deletePlan(String id) => remoteDataSource.deleteStrangerPlan(id);

  Future<List<StrangerReelItem>> getReels() => remoteDataSource.getStrangerReels();

  Future<bool> deleteReel(String id) => remoteDataSource.deleteStrangerReel(id);
}

