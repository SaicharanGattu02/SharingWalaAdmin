import 'package:equatable/equatable.dart';
import '../../models/admin_models.dart';

abstract class StrangerState extends Equatable {
  const StrangerState();

  @override
  List<Object?> get props => [];
}

class StrangerInitial extends StrangerState {}

class StrangerLoading extends StrangerState {}

class StrangerLoaded extends StrangerState {
  final StrangerStats stats;
  final List<StrangerTripItem> trips;
  final List<StrangerMeetupItem> meetups;
  final List<StrangerPlanItem> plans;
  final List<StrangerReelItem> reels;

  const StrangerLoaded({
    required this.stats,
    required this.trips,
    required this.meetups,
    required this.plans,
    required this.reels,
  });

  @override
  List<Object?> get props => [stats, trips, meetups, plans, reels];
}

class StrangerError extends StrangerState {
  final String message;
  const StrangerError(this.message);

  @override
  List<Object?> get props => [message];
}

