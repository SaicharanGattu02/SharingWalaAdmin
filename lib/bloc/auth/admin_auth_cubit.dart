import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_client.dart';
import 'admin_auth_repo.dart';
import 'admin_auth_state.dart';

class AdminAuthCubit extends Cubit<AdminAuthState> {
  final AdminAuthRepo repo;

  AdminAuthCubit({required this.repo}) : super(AdminAuthInitial());

  Future<void> checkAuthStatus() async {
    try {
      final profile = await repo.checkCurrentSession();
      if (profile != null) {
        emit(AdminAuthAuthenticated(admin: profile));
      } else {
        emit(AdminAuthUnauthenticated());
      }
    } catch (_) {
      emit(AdminAuthUnauthenticated());
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(AdminAuthLoading());
    try {
      final result = await repo.login(email: email, password: password);
      if (result.requiresOtp) {
        emit(AdminAuthOtpRequired(
          tempToken: result.tempToken,
          maskedPhone: result.maskedPhone,
          phone: result.phone,
          message: result.message,
        ));
      } else if (result.authResponse != null) {
        emit(AdminAuthAuthenticated(admin: result.authResponse!.admin));
      } else {
        emit(const AdminAuthError('Authentication failed. Please try again.'));
      }
    } catch (e) {
      emit(AdminAuthError(ApiClient.formatError(e)));
    }
  }

  Future<void> verifyOtp({required String tempToken, required String otp}) async {
    emit(AdminAuthLoading());
    try {
      final response = await repo.verifyOtp(tempToken: tempToken, otp: otp);
      emit(AdminAuthAuthenticated(admin: response.admin));
    } catch (e) {
      emit(AdminAuthError(ApiClient.formatError(e)));
    }
  }

  Future<bool> resendOtp({required String tempToken}) async {
    try {
      return await repo.resendOtp(tempToken: tempToken);
    } catch (_) {
      return false;
    }
  }

  void cancelOtp() {
    emit(AdminAuthUnauthenticated());
  }

  Future<void> logout() async {
    await repo.logout();
    emit(AdminAuthUnauthenticated());
  }
}

