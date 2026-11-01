import 'package:equatable/equatable.dart';
import '../../models/admin_models.dart';

abstract class VehiclesState extends Equatable {
  const VehiclesState();

  @override
  List<Object?> get props => [];
}

class VehiclesInitial extends VehiclesState {}

class VehiclesLoading extends VehiclesState {}

class VehiclesLoaded extends VehiclesState {
  final List<AdminVehicleItem> vehicles;
  const VehiclesLoaded({required this.vehicles});

  @override
  List<Object?> get props => [vehicles];
}

class VehiclesError extends VehiclesState {
  final String message;
  const VehiclesError(this.message);

  @override
  List<Object?> get props => [message];
}

