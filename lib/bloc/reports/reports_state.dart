import 'package:equatable/equatable.dart';
import '../../models/admin_models.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<AdminReportItem> reports;
  const ReportsLoaded({required this.reports});

  @override
  List<Object?> get props => [reports];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}

