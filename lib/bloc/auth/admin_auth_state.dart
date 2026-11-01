import 'package:equatable/equatable.dart';
import '../../models/admin_models.dart';

abstract class AdminAuthState extends Equatable {
  const AdminAuthState();

  @override
  List<Object?> get props => [];
}

class AdminAuthInitial extends AdminAuthState {}

class AdminAuthLoading extends AdminAuthState {}

class AdminAuthAuthenticated extends AdminAuthState {
  final AdminProfile admin;
  const AdminAuthAuthenticated({required this.admin});

  @override
  List<Object?> get props => [admin];
}

class AdminAuthUnauthenticated extends AdminAuthState {}

class AdminAuthError extends AdminAuthState {
  final String message;
  const AdminAuthError(this.message);

  @override
  List<Object?> get props => [message];
}

