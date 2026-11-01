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
  final List<AdminSosIncidentItem> sosIncidents;
  final AppUpdateConfigModel? appConfig;

  const ReportsLoaded({
    required this.reports,
    this.sosIncidents = const [],
    this.appConfig,
  });

  ReportsLoaded copyWith({
    List<AdminReportItem>? reports,
    List<AdminSosIncidentItem>? sosIncidents,
    AppUpdateConfigModel? appConfig,
  }) {
    return ReportsLoaded(
      reports: reports ?? this.reports,
      sosIncidents: sosIncidents ?? this.sosIncidents,
      appConfig: appConfig ?? this.appConfig,
    );
  }

  @override
  List<Object?> get props => [reports, sosIncidents, appConfig];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}

