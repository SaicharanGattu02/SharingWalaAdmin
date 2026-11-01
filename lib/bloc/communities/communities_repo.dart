import '../../core/remote_data_source/admin_remote_data_source.dart';
import '../../models/admin_models.dart';

class CommunitiesRepo {
  final AdminRemoteDataSource remoteDataSource;

  CommunitiesRepo({required this.remoteDataSource});

  Future<List<AdminCommunityItem>> getCommunities() => remoteDataSource.getCommunities();

  Future<bool> createCommunity(Map<String, dynamic> data) => remoteDataSource.createCommunity(data);
}

