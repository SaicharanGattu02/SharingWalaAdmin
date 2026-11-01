import 'package:equatable/equatable.dart';
import '../../models/admin_models.dart';

abstract class StaffState extends Equatable {
  const StaffState();

  @override
  List<Object?> get props => [];
}

class StaffInitial extends StaffState {}

class StaffLoading extends StaffState {}

class StaffLoaded extends StaffState {
  final List<AdminStaffItem> staff;
  final List<AdminAuditLogItem> auditLogs;
  const StaffLoaded({required this.staff, required this.auditLogs});

  @override
  List<Object?> get props => [staff, auditLogs];
}

class StaffError extends StaffState {
  final String message;
  const StaffError(this.message);

  @override
  List<Object?> get props => [message];
}

