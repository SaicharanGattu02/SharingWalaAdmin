import 'package:equatable/equatable.dart';
import '../../models/admin_models.dart';

abstract class AdminAuthState extends Equatable {
  const AdminAuthState();

  @override
  List<Object?> get props => [];
}

class AdminAuthInitial extends AdminAuthState {}

class AdminAuthLoading extends AdminAuthState {}

class AdminAuthOtpRequired extends AdminAuthState {
  final String tempToken;
  final String maskedPhone;
  final String phone;
  final String message;

  const AdminAuthOtpRequired({
    required this.tempToken,
    required this.maskedPhone,
    required this.phone,
    required this.message,
  });

  @override
  List<Object?> get props => [tempToken, maskedPhone, phone, message];
}

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

