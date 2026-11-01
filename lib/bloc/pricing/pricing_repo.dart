import '../../core/remote_data_source/admin_remote_data_source.dart';
import '../../models/admin_models.dart';

class PricingRepo {
  final AdminRemoteDataSource remoteDataSource;

  PricingRepo({required this.remoteDataSource});

  Future<List<AdminPricingRuleItem>> getPricingRules() => remoteDataSource.getPricingRules();

  Future<bool> updatePricingRule(String id, Map<String, dynamic> data) =>
      remoteDataSource.updatePricingRule(id, data);
}

