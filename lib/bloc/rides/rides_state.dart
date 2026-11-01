import 'package:equatable/equatable.dart';
import '../../models/admin_models.dart';

abstract class RidesState extends Equatable {
  const RidesState();

  @override
  List<Object?> get props => [];
}

class RidesInitial extends RidesState {}

class RidesLoading extends RidesState {}

class RidesLoaded extends RidesState {
  final List<AdminRideItem> rides;
  const RidesLoaded({required this.rides});

  @override
  List<Object?> get props => [rides];
}

class RidesError extends RidesState {
  final String message;
  const RidesError(this.message);

  @override
  List<Object?> get props => [message];
}

