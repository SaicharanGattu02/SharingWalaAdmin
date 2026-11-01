import 'package:flutter_bloc/flutter_bloc.dart';
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
      final response = await repo.login(email: email, password: password);
      emit(AdminAuthAuthenticated(admin: response.admin));
    } catch (e) {
      emit(AdminAuthError(e.toString().replaceAll('Exception:', '').trim()));
    }
  }

  Future<void> logout() async {
    await repo.logout();
    emit(AdminAuthUnauthenticated());
  }
}

