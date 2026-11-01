import '../../core/remote_data_source/admin_remote_data_source.dart';
import '../../models/admin_models.dart';

class BannersRepo {
  final AdminRemoteDataSource remoteDataSource;

  BannersRepo({required this.remoteDataSource});

  Future<List<AdminBannerItem>> getBanners() => remoteDataSource.getBanners();

  Future<bool> createBanner(Map<String, dynamic> data) => remoteDataSource.createBanner(data);

  Future<bool> updateBanner(String id, Map<String, dynamic> data) => remoteDataSource.updateBanner(id, data);

  Future<bool> deleteBanner(String id) => remoteDataSource.deleteBanner(id);
}

