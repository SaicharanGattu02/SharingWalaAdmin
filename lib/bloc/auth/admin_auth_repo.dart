import '../../core/remote_data_source/admin_remote_data_source.dart';
import '../../models/admin_models.dart';
import '../../services/admin_auth_service.dart';

class AdminAuthRepo {
  final AdminRemoteDataSource remoteDataSource;

  AdminAuthRepo({required this.remoteDataSource});

  Future<AdminAuthResponse> login({required String email, required String password}) async {
    final response = await remoteDataSource.login(email: email, password: password);
    await AdminAuthService.saveAuth(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      adminData: response.admin.toJson(),
    );
    return response;
  }

  Future<void> logout() async {
    await AdminAuthService.clearAuth();
  }

  Future<AdminProfile?> checkCurrentSession() async {
    final isAuth = await AdminAuthService.isAuthenticated();
    if (!isAuth) return null;
    final data = await AdminAuthService.getAdminData();
    if (data == null) return null;
    return AdminProfile.fromJson(data);
  }
}

