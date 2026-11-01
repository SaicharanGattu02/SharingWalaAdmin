class AdminEndpoints {
  // Base URLs
  static const String baseUrl = 'http://localhost:5000/api/v1/admin';

  // Auth
  static const String login = '$baseUrl/auth/login';
  static const String refresh = '$baseUrl/auth/refresh';
  static const String me = '$baseUrl/auth/me';
  static const String logout = '$baseUrl/auth/logout';
  static const String changePassword = '$baseUrl/auth/change-password';

  // Dashboard
  static const String dashboardStats = '$baseUrl/dashboard/stats';
  static const String dashboardCharts = '$baseUrl/dashboard/charts';
  static const String dashboardActivity = '$baseUrl/dashboard/recent-activity';

  // Users
  static const String users = '$baseUrl/users';
  static String userDetails(String id) => '$baseUrl/users/$id';
  static String updateUserStatus(String id) => '$baseUrl/users/$id/status';

  // Drivers & Documents
  static const String drivers = '$baseUrl/drivers';
  static String driverDetails(String id) => '$baseUrl/drivers/$id';
  static String verifyDriver(String id) => '$baseUrl/drivers/$id/verify';
  static String verifyDriverDoc(String id) => '$baseUrl/driver-documents/$id/verify';

  // Vehicles
  static const String vehicles = '$baseUrl/vehicles';
  static String vehicleDetails(String id) => '$baseUrl/vehicles/$id';
  static String verifyVehicle(String id) => '$baseUrl/vehicles/$id/verify';
  static String verifyVehicleInsurance(String id) => '$baseUrl/vehicle-insurances/$id/verify';

  // Rides & Trips
  static const String rides = '$baseUrl/rides';
  static String rideDetails(String id) => '$baseUrl/rides/$id';
  static String cancelRide(String id) => '$baseUrl/rides/$id/cancel';
  static const String trips = '$baseUrl/trips';

  // Bookings
  static const String bookings = '$baseUrl/bookings';
  static String bookingDetails(String id) => '$baseUrl/bookings/$id';
  static String updateBookingStatus(String id) => '$baseUrl/bookings/$id/status';

  // Reports (Trust & Safety)
  static const String reports = '$baseUrl/reports';
  static String reportDetails(String id) => '$baseUrl/reports/$id';
  static String resolveReport(String id) => '$baseUrl/reports/$id/resolve';

  // Communities
  static const String communities = '$baseUrl/communities';
  static String communityDetails(String id) => '$baseUrl/communities/$id';

  // Pricing Rules
  static const String pricingRules = '$baseUrl/pricing-rules';
  static String pricingRuleDetails(String id) => '$baseUrl/pricing-rules/$id';

  // Banners
  static const String banners = '$baseUrl/banners';
  static String bannerDetails(String id) => '$baseUrl/banners/$id';

  // Staff & RBAC
  static const String staff = '$baseUrl/staff';
  static String staffDetails(String id) => '$baseUrl/staff/$id';
  static const String roles = '$baseUrl/roles';
  static const String auditLogs = '$baseUrl/audit-logs';

  // Stranger Mode (Trips, Meetups, Plans, Reels)
  static const String strangerStats = '$baseUrl/stranger/stats';
  static const String strangerTrips = '$baseUrl/stranger/trips';
  static String strangerTripDetails(String id) => '$baseUrl/stranger/trips/$id';
  static const String strangerMeetups = '$baseUrl/stranger/meetups';
  static String strangerMeetupDetails(String id) => '$baseUrl/stranger/meetups/$id';
  static const String strangerPlans = '$baseUrl/stranger/plans';
  static String strangerPlanDetails(String id) => '$baseUrl/stranger/plans/$id';
  static const String strangerReels = '$baseUrl/stranger/reels';
  static String strangerReelDetails(String id) => '$baseUrl/stranger/reels/$id';
}

