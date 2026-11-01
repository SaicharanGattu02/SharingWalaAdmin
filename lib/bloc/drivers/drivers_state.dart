import 'package:equatable/equatable.dart';
import '../../models/admin_models.dart';

abstract class DriversState extends Equatable {
  const DriversState();

  @override
  List<Object?> get props => [];
}

class DriversInitial extends DriversState {}

class DriversLoading extends DriversState {}

class DriversLoaded extends DriversState {
  final List<AdminDriverItem> drivers;
  const DriversLoaded({required this.drivers});

  @override
  List<Object?> get props => [drivers];
}

class DriversError extends DriversState {
  final String message;
  const DriversError(this.message);

  @override
  List<Object?> get props => [message];
}

