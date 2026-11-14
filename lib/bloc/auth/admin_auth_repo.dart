import '../../core/remote_data_source/admin_remote_data_source.dart';
import '../../models/admin_models.dart';
import '../../services/admin_auth_service.dart';

class AdminAuthRepo {
  final AdminRemoteDataSource remoteDataSource;

  AdminAuthRepo({required this.remoteDataSource});

  Future<AdminLoginStepResult> login({required String email, required String password}) async {
    final result = await remoteDataSource.login(email: email, password: password);
    if (!result.requiresOtp && result.authResponse != null) {
      await AdminAuthService.saveAuth(
        accessToken: result.authResponse!.accessToken,
        refreshToken: result.authResponse!.refreshToken,
        adminData: result.authResponse!.admin.toJson(),
      );
    }
    return result;
  }

  Future<AdminAuthResponse> verifyOtp({required String tempToken, required String otp}) async {
    final response = await remoteDataSource.verifyOtp(tempToken: tempToken, otp: otp);
    await AdminAuthService.saveAuth(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      adminData: response.admin.toJson(),
    );
    return response;
  }

  Future<bool> resendOtp({required String tempToken}) async {
    return await remoteDataSource.resendOtp(tempToken: tempToken);
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

