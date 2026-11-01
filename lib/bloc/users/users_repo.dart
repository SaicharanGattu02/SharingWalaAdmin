import '../../core/remote_data_source/admin_remote_data_source.dart';
import '../../models/admin_models.dart';

class UsersRepo {
  final AdminRemoteDataSource remoteDataSource;

  UsersRepo({required this.remoteDataSource});

  Future<List<AdminUserItem>> getUsers({String? search, String? status, String? role}) {
    return remoteDataSource.getUsers(search: search, status: status, role: role);
  }

  Future<bool> updateUserStatus(String userId, String status, {String? reason}) {
    return remoteDataSource.updateUserStatus(userId, status, reason: reason);
  }
}

