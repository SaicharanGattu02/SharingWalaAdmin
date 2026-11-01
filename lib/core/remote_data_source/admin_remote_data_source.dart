import 'package:dio/dio.dart';
import '../../models/admin_models.dart';
import '../../services/api_client.dart';
import '../api_config/admin_endpoints.dart';

abstract class AdminRemoteDataSource {
  Future<AdminAuthResponse> login({required String email, required String password});
  Future<DashboardStats> getDashboardStats();
  Future<List<AdminUserItem>> getUsers({String? search, String? status, String? role});
  Future<bool> updateUserStatus(String userId, String status, {String? reason});
  Future<List<AdminDriverItem>> getDrivers({String? status, String? search});
  Future<bool> verifyDriver(String driverId, String status, {String? reason});
  Future<List<AdminVehicleItem>> getVehicles({String? status, String? vehicleType});
  Future<bool> verifyVehicle(String vehicleId, String status, {String? reason});
  Future<List<AdminRideItem>> getRides({String? status, String? search});
  Future<bool> cancelRide(String rideId, String reason);
  Future<List<AdminReportItem>> getReports({String? status});
  Future<bool> resolveReport(String reportId, String status, String adminNotes, {bool penalize = false, String penalty = 'NONE'});
  Future<List<AdminCommunityItem>> getCommunities();
  Future<bool> createCommunity(Map<String, dynamic> data);
  Future<List<AdminPricingRuleItem>> getPricingRules();
  Future<bool> updatePricingRule(String id, Map<String, dynamic> data);
  Future<List<AdminBannerItem>> getBanners();
  Future<bool> createBanner(Map<String, dynamic> data);
  Future<bool> updateBanner(String id, Map<String, dynamic> data);
  Future<bool> deleteBanner(String id);
  Future<List<AdminStaffItem>> getStaff();
  Future<List<AdminAuditLogItem>> getAuditLogs();

  // Stranger Section
  Future<StrangerStats> getStrangerStats();
  Future<List<StrangerTripItem>> getStrangerTrips();
  Future<bool> deleteStrangerTrip(String id);
  Future<List<StrangerMeetupItem>> getStrangerMeetups();
  Future<bool> deleteStrangerMeetup(String id);
  Future<List<StrangerPlanItem>> getStrangerPlans();
  Future<bool> deleteStrangerPlan(String id);
  Future<List<StrangerReelItem>> getStrangerReels();
  Future<bool> deleteStrangerReel(String id);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final Dio dio = ApiClient.dio;

  @override
  Future<AdminAuthResponse> login({required String email, required String password}) async {
    final response = await dio.post(
      AdminEndpoints.login,
      data: {'email': email, 'password': password},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return AdminAuthResponse.fromJson(data);
  }

  @override
  Future<DashboardStats> getDashboardStats() async {
    final response = await dio.get(AdminEndpoints.dashboardStats);
    final data = response.data['data'] as Map<String, dynamic>;
    return DashboardStats.fromJson(data);
  }

  @override
  Future<List<AdminUserItem>> getUsers({String? search, String? status, String? role}) async {
    final query = <String, dynamic>{};
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (role != null && role.isNotEmpty) query['role'] = role;

    final response = await dio.get(AdminEndpoints.users, queryParameters: query);
    final list = response.data['data']['users'] as List<dynamic>? ?? [];
    return list.map((e) => AdminUserItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<bool> updateUserStatus(String userId, String status, {String? reason}) async {
    final response = await dio.patch(
      AdminEndpoints.updateUserStatus(userId),
      data: {'status': status, if (reason != null) 'reason': reason},
    );
    return response.statusCode == 200;
  }

  @override
  Future<List<AdminDriverItem>> getDrivers({String? status, String? search}) async {
    final query = <String, dynamic>{};
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (search != null && search.isNotEmpty) query['search'] = search;

    final response = await dio.get(AdminEndpoints.drivers, queryParameters: query);
    final list = response.data['data']['drivers'] as List<dynamic>? ?? [];
    return list.map((e) => AdminDriverItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<bool> verifyDriver(String driverId, String status, {String? reason}) async {
    final response = await dio.patch(
      AdminEndpoints.verifyDriver(driverId),
      data: {'status': status, if (reason != null) 'rejectionReason': reason},
    );
    return response.statusCode == 200;
  }

  @override
  Future<List<AdminVehicleItem>> getVehicles({String? status, String? vehicleType}) async {
    final query = <String, dynamic>{};
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (vehicleType != null && vehicleType.isNotEmpty) query['vehicleType'] = vehicleType;

    final response = await dio.get(AdminEndpoints.vehicles, queryParameters: query);
    final list = response.data['data']['vehicles'] as List<dynamic>? ?? [];
    return list.map((e) => AdminVehicleItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<bool> verifyVehicle(String vehicleId, String status, {String? reason}) async {
    final response = await dio.patch(
      AdminEndpoints.verifyVehicle(vehicleId),
      data: {'status': status, if (reason != null) 'rejectionReason': reason},
    );
    return response.statusCode == 200;
  }

  @override
  Future<List<AdminRideItem>> getRides({String? status, String? search}) async {
    final query = <String, dynamic>{};
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (search != null && search.isNotEmpty) query['search'] = search;

    final response = await dio.get(AdminEndpoints.rides, queryParameters: query);
    final list = response.data['data']['rides'] as List<dynamic>? ?? [];
    return list.map((e) => AdminRideItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<bool> cancelRide(String rideId, String reason) async {
    final response = await dio.post(
      AdminEndpoints.cancelRide(rideId),
      data: {'cancellationReason': reason},
    );
    return response.statusCode == 200;
  }

  @override
  Future<List<AdminReportItem>> getReports({String? status}) async {
    final query = <String, dynamic>{};
    if (status != null && status.isNotEmpty) query['status'] = status;

    final response = await dio.get(AdminEndpoints.reports, queryParameters: query);
    final list = response.data['data']['reports'] as List<dynamic>? ?? [];
    return list.map((e) => AdminReportItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<bool> resolveReport(String reportId, String status, String adminNotes, {bool penalize = false, String penalty = 'NONE'}) async {
    final response = await dio.patch(
      AdminEndpoints.resolveReport(reportId),
      data: {
        'status': status,
        'adminNotes': adminNotes,
        'penalizeUser': penalize,
        'penalizeAction': penalty,
      },
    );
    return response.statusCode == 200;
  }

  @override
  Future<List<AdminCommunityItem>> getCommunities() async {
    final response = await dio.get(AdminEndpoints.communities);
    final list = response.data['data']['communities'] as List<dynamic>? ?? [];
    return list.map((e) => AdminCommunityItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<bool> createCommunity(Map<String, dynamic> data) async {
    final response = await dio.post(AdminEndpoints.communities, data: data);
    return response.statusCode == 201 || response.statusCode == 200;
  }

  @override
  Future<List<AdminPricingRuleItem>> getPricingRules() async {
    final response = await dio.get(AdminEndpoints.pricingRules);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => AdminPricingRuleItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<bool> updatePricingRule(String id, Map<String, dynamic> data) async {
    final response = await dio.put(AdminEndpoints.pricingRuleDetails(id), data: data);
    return response.statusCode == 200;
  }

  @override
  Future<List<AdminBannerItem>> getBanners() async {
    final response = await dio.get(AdminEndpoints.banners);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => AdminBannerItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<bool> createBanner(Map<String, dynamic> data) async {
    final response = await dio.post(AdminEndpoints.banners, data: data);
    return response.statusCode == 201 || response.statusCode == 200;
  }

  @override
  Future<bool> updateBanner(String id, Map<String, dynamic> data) async {
    final response = await dio.put(AdminEndpoints.bannerDetails(id), data: data);
    return response.statusCode == 200;
  }

  @override
  Future<bool> deleteBanner(String id) async {
    final response = await dio.delete(AdminEndpoints.bannerDetails(id));
    return response.statusCode == 200;
  }

  @override
  Future<List<AdminStaffItem>> getStaff() async {
    final response = await dio.get(AdminEndpoints.staff);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => AdminStaffItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<AdminAuditLogItem>> getAuditLogs() async {
    final response = await dio.get(AdminEndpoints.auditLogs);
    final list = response.data['data']['logs'] as List<dynamic>? ?? [];
    return list.map((e) => AdminAuditLogItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ==============================================================================
  // STRANGER SECTION IMPLEMENTATION
  // ==============================================================================

  @override
  Future<StrangerStats> getStrangerStats() async {
    final response = await dio.get(AdminEndpoints.strangerStats);
    final data = response.data['data'] as Map<String, dynamic>;
    return StrangerStats.fromJson(data);
  }

  @override
  Future<List<StrangerTripItem>> getStrangerTrips() async {
    final response = await dio.get(AdminEndpoints.strangerTrips);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => StrangerTripItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<bool> deleteStrangerTrip(String id) async {
    final response = await dio.delete(AdminEndpoints.strangerTripDetails(id));
    return response.statusCode == 200;
  }

  @override
  Future<List<StrangerMeetupItem>> getStrangerMeetups() async {
    final response = await dio.get(AdminEndpoints.strangerMeetups);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => StrangerMeetupItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<bool> deleteStrangerMeetup(String id) async {
    final response = await dio.delete(AdminEndpoints.strangerMeetupDetails(id));
    return response.statusCode == 200;
  }

  @override
  Future<List<StrangerPlanItem>> getStrangerPlans() async {
    final response = await dio.get(AdminEndpoints.strangerPlans);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => StrangerPlanItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<bool> deleteStrangerPlan(String id) async {
    final response = await dio.delete(AdminEndpoints.strangerPlanDetails(id));
    return response.statusCode == 200;
  }

  @override
  Future<List<StrangerReelItem>> getStrangerReels() async {
    final response = await dio.get(AdminEndpoints.strangerReels);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => StrangerReelItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<bool> deleteStrangerReel(String id) async {
    final response = await dio.delete(AdminEndpoints.strangerReelDetails(id));
    return response.statusCode == 200;
  }
}

