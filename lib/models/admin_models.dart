double _toDouble(dynamic val, [double defaultVal = 0.0]) {
  if (val == null) return defaultVal;
  if (val is num) return val.toDouble();
  if (val is String) {
    return double.tryParse(val) ?? defaultVal;
  }
  return defaultVal;
}

int _toInt(dynamic val, [int defaultVal = 0]) {
  if (val == null) return defaultVal;
  if (val is num) return val.toInt();
  if (val is String) {
    return int.tryParse(val) ?? (double.tryParse(val)?.toInt() ?? defaultVal);
  }
  return defaultVal;
}

// ==============================================================================
// 1. ADMIN AUTH & USER PROFILE MODEL
// ==============================================================================

class AdminProfile {
  final String id;
  final String name;
  final String email;
  final List<String> roles;
  final List<String> permissions;

  AdminProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
    required this.permissions,
  });

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    return AdminProfile(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      permissions: (json['permissions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'roles': roles,
        'permissions': permissions,
      };
}

class AdminAuthResponse {
  final String accessToken;
  final String refreshToken;
  final AdminProfile admin;

  AdminAuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.admin,
  });

  factory AdminAuthResponse.fromJson(Map<String, dynamic> json) {
    return AdminAuthResponse(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      admin: AdminProfile.fromJson(json['admin'] as Map<String, dynamic>? ?? {}),
    );
  }
}

// ==============================================================================
// 2. DASHBOARD STATS MODEL
// ==============================================================================

class DashboardStats {
  final int totalUsers;
  final int activeUsers;
  final int suspendedUsers;
  final int totalDrivers;
  final int pendingDrivers;
  final int totalVehicles;
  final int pendingVehicles;
  final int activeRides;
  final int completedRides;
  final int totalBookings;
  final int openReports;
  final int totalCommunities;

  DashboardStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.suspendedUsers,
    required this.totalDrivers,
    required this.pendingDrivers,
    required this.totalVehicles,
    required this.pendingVehicles,
    required this.activeRides,
    required this.completedRides,
    required this.totalBookings,
    required this.openReports,
    required this.totalCommunities,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final users = json['users'] as Map<String, dynamic>? ?? {};
    final drivers = json['drivers'] as Map<String, dynamic>? ?? {};
    final vehicles = json['vehicles'] as Map<String, dynamic>? ?? {};
    final rides = json['rides'] as Map<String, dynamic>? ?? {};
    final bookings = json['bookings'] as Map<String, dynamic>? ?? {};
    final trust = json['trustAndSafety'] as Map<String, dynamic>? ?? {};
    final comms = json['communities'] as Map<String, dynamic>? ?? {};

    return DashboardStats(
      totalUsers: _toInt(users['total']),
      activeUsers: _toInt(users['active']),
      suspendedUsers: _toInt(users['suspended']),
      totalDrivers: _toInt(drivers['total']),
      pendingDrivers: _toInt(drivers['pendingVerification']),
      totalVehicles: _toInt(vehicles['total']),
      pendingVehicles: _toInt(vehicles['pendingVerification']),
      activeRides: _toInt(rides['active']),
      completedRides: _toInt(rides['completed']),
      totalBookings: _toInt(bookings['total']),
      openReports: _toInt(trust['openReports']),
      totalCommunities: _toInt(comms['total']),
    );
  }
}

// ==============================================================================
// 3. ADMIN USER MODEL
// ==============================================================================

class AdminUserItem {
  final String id;
  final String username;
  final String displayName;
  final String phone;
  final String? email;
  final String status;
  final String role;
  final bool isDriver;
  final String gender;
  final String? createdAt;

  AdminUserItem({
    required this.id,
    required this.username,
    required this.displayName,
    required this.phone,
    this.email,
    required this.status,
    required this.role,
    required this.isDriver,
    required this.gender,
    this.createdAt,
  });

  factory AdminUserItem.fromJson(Map<String, dynamic> json) {
    return AdminUserItem(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? 'User',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      status: json['status']?.toString() ?? 'ACTIVE',
      role: json['role']?.toString() ?? 'USER',
      isDriver: json['isDriver'] == true,
      gender: json['gender']?.toString() ?? 'PREFER_NOT_TO_SAY',
      createdAt: json['createdAt']?.toString(),
    );
  }
}

// ==============================================================================
// 4. ADMIN DRIVER MODEL
// ==============================================================================

class AdminDriverItem {
  final String id;
  final String licenseNumber;
  final String? licenseExpiryDate;
  final String verificationStatus;
  final String driverName;
  final String driverPhone;
  final String? driverEmail;
  final int vehiclesCount;
  final String? licenseFrontUrl;
  final String? licenseBackUrl;
  final String? selfieUrl;
  final String? userAvatarUrl;
  final String? rejectedReason;

  AdminDriverItem({
    required this.id,
    required this.licenseNumber,
    this.licenseExpiryDate,
    required this.verificationStatus,
    required this.driverName,
    required this.driverPhone,
    this.driverEmail,
    required this.vehiclesCount,
    this.licenseFrontUrl,
    this.licenseBackUrl,
    this.selfieUrl,
    this.userAvatarUrl,
    this.rejectedReason,
  });

  factory AdminDriverItem.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final vehicles = json['vehicles'] as List<dynamic>? ?? [];
    final docs = json['documents'] as List<dynamic>? ?? [];

    String? dlFront;
    String? dlBack;
    String? selfie;

    for (final doc in docs) {
      if (doc is Map) {
        final docType = doc['documentType']?.toString();
        final docNum = doc['documentNumber']?.toString();
        final url = doc['fileUrl']?.toString();
        if (docType == 'DRIVING_LICENSE') {
          dlFront ??= url;
        } else if (docNum == 'LIVE_CAMERA_SELFIE' || docType == 'OTHER') {
          selfie ??= url;
        }
      }
    }

    selfie ??= user['avatarUrl']?.toString();

    return AdminDriverItem(
      id: json['id']?.toString() ?? '',
      licenseNumber: json['licenseNumber']?.toString() ?? '',
      licenseExpiryDate: json['licenseExpiryDate']?.toString(),
      verificationStatus: json['verificationStatus']?.toString() ?? 'PENDING',
      driverName: user['displayName']?.toString() ?? 'Driver',
      driverPhone: user['phone']?.toString() ?? '',
      driverEmail: user['email']?.toString(),
      vehiclesCount: vehicles.length,
      licenseFrontUrl: dlFront,
      licenseBackUrl: dlBack,
      selfieUrl: selfie,
      userAvatarUrl: user['avatarUrl']?.toString(),
      rejectedReason: json['rejectedReason']?.toString(),
    );
  }
}

// ==============================================================================
// 5. ADMIN VEHICLE MODEL
// ==============================================================================

class AdminVehicleItem {
  final String id;
  final String registrationNumber;
  final String vehicleType;
  final String make;
  final String model;
  final String status;
  final String? driverName;

  AdminVehicleItem({
    required this.id,
    required this.registrationNumber,
    required this.vehicleType,
    required this.make,
    required this.model,
    required this.status,
    this.driverName,
  });

  factory AdminVehicleItem.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'] as Map<String, dynamic>? ?? {};
    final user = driver['user'] as Map<String, dynamic>? ?? {};

    return AdminVehicleItem(
      id: json['id']?.toString() ?? '',
      registrationNumber: json['registrationNumber']?.toString() ?? '',
      vehicleType: json['vehicleType']?.toString() ?? 'CAR',
      make: json['make']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      driverName: user['displayName']?.toString() ?? 'Driver',
    );
  }
}

// ==============================================================================
// 6. ADMIN RIDE MODEL
// ==============================================================================

class AdminRideItem {
  final String id;
  final String startLocationName;
  final String endLocationName;
  final String departureAt;
  final String status;
  final int totalSeats;
  final int availableSeats;
  final String? driverName;

  AdminRideItem({
    required this.id,
    required this.startLocationName,
    required this.endLocationName,
    required this.departureAt,
    required this.status,
    required this.totalSeats,
    required this.availableSeats,
    this.driverName,
  });

  factory AdminRideItem.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'] as Map<String, dynamic>? ?? {};
    final user = driver['user'] as Map<String, dynamic>? ?? {};

    return AdminRideItem(
      id: json['id']?.toString() ?? '',
      startLocationName: json['startLocationName']?.toString() ?? '',
      endLocationName: json['endLocationName']?.toString() ?? '',
      departureAt: json['departureAt']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PUBLISHED',
      totalSeats: _toInt(json['totalSeats']),
      availableSeats: _toInt(json['availableSeats']),
      driverName: user['displayName']?.toString() ?? 'Driver',
    );
  }
}

// ==============================================================================
// 7. ADMIN SAFETY REPORT MODEL
// ==============================================================================

class AdminReportItem {
  final String id;
  final String reason;
  final String description;
  final String status;
  final String? adminNotes;
  final String reporterName;
  final String reportedUserName;
  final String createdAt;

  AdminReportItem({
    required this.id,
    required this.reason,
    required this.description,
    required this.status,
    this.adminNotes,
    required this.reporterName,
    required this.reportedUserName,
    required this.createdAt,
  });

  factory AdminReportItem.fromJson(Map<String, dynamic> json) {
    final reporter = json['reporter'] as Map<String, dynamic>? ?? {};
    final reported = json['reportedUser'] as Map<String, dynamic>? ?? {};

    return AdminReportItem(
      id: json['id']?.toString() ?? '',
      reason: json['reason']?.toString() ?? 'OTHER',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'OPEN',
      adminNotes: json['adminNotes']?.toString(),
      reporterName: reporter['displayName']?.toString() ?? 'User',
      reportedUserName: reported['displayName']?.toString() ?? 'User',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

// ==============================================================================
// 8. ADMIN COMMUNITY MODEL
// ==============================================================================

class AdminCommunityItem {
  final String id;
  final String name;
  final String type;
  final String? description;
  final String? domainRestriction;
  final bool isActive;
  final int membersCount;

  AdminCommunityItem({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.domainRestriction,
    required this.isActive,
    required this.membersCount,
  });

  factory AdminCommunityItem.fromJson(Map<String, dynamic> json) {
    final count = json['_count'] as Map<String, dynamic>? ?? {};
    return AdminCommunityItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'OFFICE',
      description: json['description']?.toString(),
      domainRestriction: json['domainRestriction']?.toString(),
      isActive: json['isActive'] == true,
      membersCount: _toInt(count['members']),
    );
  }
}

// ==============================================================================
// 9. ADMIN PRICING RULE MODEL
// ==============================================================================

class AdminPricingRuleItem {
  final String id;
  final String vehicleType;
  final double minimumDistanceKm;
  final double maximumDistanceKm;
  final double ratePerKm;
  final double maxContributionPerKm;
  final bool isActive;

  AdminPricingRuleItem({
    required this.id,
    required this.vehicleType,
    required this.minimumDistanceKm,
    required this.maximumDistanceKm,
    required this.ratePerKm,
    required this.maxContributionPerKm,
    required this.isActive,
  });

  factory AdminPricingRuleItem.fromJson(Map<String, dynamic> json) {
    return AdminPricingRuleItem(
      id: json['id']?.toString() ?? '',
      vehicleType: json['vehicleType']?.toString() ?? 'CAR',
      minimumDistanceKm: _toDouble(json['minimumDistanceKm'], 1.0),
      maximumDistanceKm: _toDouble(json['maximumDistanceKm'], 1000.0),
      ratePerKm: _toDouble(json['ratePerKm'], 3.5),
      maxContributionPerKm: _toDouble(json['maxContributionPerKm'], 5.0),
      isActive: json['isActive'] == true || json['isActive']?.toString() == 'true',
    );
  }
}

// ==============================================================================
// 10. ADMIN BANNER MODEL
// ==============================================================================

class AdminBannerItem {
  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String targetRole;
  final String category;
  final String ctaText;
  final bool isActive;
  final int priority;

  AdminBannerItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    required this.targetRole,
    required this.category,
    required this.ctaText,
    required this.isActive,
    required this.priority,
  });

  factory AdminBannerItem.fromJson(Map<String, dynamic> json) {
    return AdminBannerItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      imageUrl: json['imageUrl']?.toString() ?? '',
      targetRole: json['targetRole']?.toString() ?? 'ALL',
      category: json['category']?.toString() ?? 'PROMO',
      ctaText: json['ctaText']?.toString() ?? 'Learn More',
      isActive: json['isActive'] == true,
      priority: _toInt(json['priority'], 1),
    );
  }
}

// ==============================================================================
// 11. ADMIN STAFF & AUDIT LOG MODEL
// ==============================================================================

class AdminStaffItem {
  final String id;
  final String name;
  final String email;
  final bool isActive;
  final List<String> roles;

  AdminStaffItem({
    required this.id,
    required this.name,
    required this.email,
    required this.isActive,
    required this.roles,
  });

  factory AdminStaffItem.fromJson(Map<String, dynamic> json) {
    return AdminStaffItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      isActive: json['isActive'] == true,
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class AdminAuditLogItem {
  final String id;
  final String action;
  final String entityType;
  final String entityId;
  final String adminName;
  final String? ipAddress;
  final String createdAt;

  AdminAuditLogItem({
    required this.id,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.adminName,
    this.ipAddress,
    required this.createdAt,
  });

  factory AdminAuditLogItem.fromJson(Map<String, dynamic> json) {
    final admin = json['admin'] as Map<String, dynamic>? ?? {};
    return AdminAuditLogItem(
      id: json['id']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      entityType: json['entityType']?.toString() ?? '',
      entityId: json['entityId']?.toString() ?? '',
      adminName: admin['name']?.toString() ?? 'Admin',
      ipAddress: json['ipAddress']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

// ==============================================================================
// 12. STRANGER SECTION MODELS (Trips, Meetups, Plans, Reels)
// ==============================================================================

class StrangerStats {
  final int totalTrips;
  final int totalMeetups;
  final int totalPlans;
  final int totalReels;

  StrangerStats({
    required this.totalTrips,
    required this.totalMeetups,
    required this.totalPlans,
    required this.totalReels,
  });

  factory StrangerStats.fromJson(Map<String, dynamic> json) {
    return StrangerStats(
      totalTrips: _toInt(json['totalTrips']),
      totalMeetups: _toInt(json['totalMeetups']),
      totalPlans: _toInt(json['totalPlans']),
      totalReels: _toInt(json['totalReels']),
    );
  }
}

class StrangerTripItem {
  final String id;
  final String origin;
  final String destination;
  final String date;
  final String time;
  final String mode;
  final String vibe;
  final String hostName;
  final String? hostAvatar;
  final int availableSeats;
  final int totalSeats;
  final double pricePerPerson;
  final String status;
  final List<String> interests;

  StrangerTripItem({
    required this.id,
    required this.origin,
    required this.destination,
    required this.date,
    required this.time,
    required this.mode,
    required this.vibe,
    required this.hostName,
    this.hostAvatar,
    required this.availableSeats,
    required this.totalSeats,
    required this.pricePerPerson,
    required this.status,
    required this.interests,
  });

  factory StrangerTripItem.fromJson(Map<String, dynamic> json) {
    return StrangerTripItem(
      id: json['id']?.toString() ?? '',
      origin: json['origin']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      mode: json['mode']?.toString() ?? 'carpool',
      vibe: json['vibe']?.toString() ?? 'roadTrip',
      hostName: json['hostName']?.toString() ?? 'Host',
      hostAvatar: json['hostAvatar']?.toString(),
      availableSeats: _toInt(json['availableSeats'], 1),
      totalSeats: _toInt(json['totalSeats'], 3),
      pricePerPerson: _toDouble(json['pricePerPerson']),
      status: json['status']?.toString() ?? 'PUBLISHED',
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class StrangerMeetupItem {
  final String id;
  final String title;
  final String location;
  final String date;
  final String time;
  final String category;
  final String hostName;
  final int rsvpCount;
  final int maxParticipants;
  final String? description;

  StrangerMeetupItem({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.category,
    required this.hostName,
    required this.rsvpCount,
    required this.maxParticipants,
    this.description,
  });

  factory StrangerMeetupItem.fromJson(Map<String, dynamic> json) {
    final attendees = json['attendees'] as List<dynamic>? ?? [];

    return StrangerMeetupItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Social Meetup',
      location: json['location']?.toString() ?? json['venue']?.toString() ?? 'Location',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Social',
      hostName: json['hostName']?.toString() ?? 'Host',
      rsvpCount: attendees.isNotEmpty ? attendees.length : _toInt(json['rsvpCount'], 1),
      maxParticipants: _toInt(json['maxParticipants'], 10),
      description: json['description']?.toString(),
    );
  }
}

class StrangerPlanItem {
  final String id;
  final String title;
  final String destination;
  final String date;
  final String? style;
  final String creatorName;
  final int companionsCount;
  final double budget;

  StrangerPlanItem({
    required this.id,
    required this.title,
    required this.destination,
    required this.date,
    this.style,
    required this.creatorName,
    required this.companionsCount,
    required this.budget,
  });

  factory StrangerPlanItem.fromJson(Map<String, dynamic> json) {
    return StrangerPlanItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Travel Plan',
      destination: json['destination']?.toString() ?? json['endLocation']?.toString() ?? '',
      date: json['date']?.toString() ?? json['departureDate']?.toString() ?? '',
      style: json['style']?.toString() ?? json['tripStyle']?.toString() ?? 'Road Trip',
      creatorName: json['creatorName']?.toString() ?? json['userName']?.toString() ?? 'Traveler',
      companionsCount: _toInt(json['companionsCount'] ?? json['currentCompanions'], 1),
      budget: _toDouble(json['budget'] ?? json['budgetEstimate'], 0.0),
    );
  }
}

class StrangerReelItem {
  final String id;
  final String title;
  final String? description;
  final String videoUrl;
  final String? thumbnailUrl;
  final String userName;
  final String? userAvatar;
  final int likesCount;
  final int commentsCount;

  StrangerReelItem({
    required this.id,
    required this.title,
    this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.userName,
    this.userAvatar,
    required this.likesCount,
    required this.commentsCount,
  });

  factory StrangerReelItem.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};

    return StrangerReelItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['caption']?.toString() ?? 'Travel Reel',
      description: json['description']?.toString(),
      videoUrl: json['videoUrl']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? json['coverUrl']?.toString() ?? 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=80',
      userName: user['name']?.toString() ?? json['userName']?.toString() ?? 'Creator',
      userAvatar: user['avatar']?.toString() ?? json['userAvatar']?.toString(),
      likesCount: _toInt(json['likesCount'] ?? json['likes']),
      commentsCount: _toInt(json['commentsCount'] ?? json['comments']),
    );
  }
}

class AdminSosIncidentItem {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String? userEmail;
  final String? rideId;
  final String? driverName;
  final String? driverPhone;
  final String? vehiclePlate;
  final String? vehicleModel;
  final double latitude;
  final double longitude;
  final String address;
  final String emergencyType;
  final String? notes;
  final String status;
  final String? adminNotes;
  final String? resolvedBy;
  final String? resolvedAt;
  final String createdAt;
  final String updatedAt;

  const AdminSosIncidentItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    this.userEmail,
    this.rideId,
    this.driverName,
    this.driverPhone,
    this.vehiclePlate,
    this.vehicleModel,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.emergencyType,
    this.notes,
    required this.status,
    this.adminNotes,
    this.resolvedBy,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminSosIncidentItem.fromJson(Map<String, dynamic> json) {
    final rideDetails = json['rideDetails'] as Map<String, dynamic>? ?? {};

    return AdminSosIncidentItem(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? 'SharingWala User',
      userPhone: json['userPhone']?.toString() ?? 'N/A',
      userEmail: json['userEmail']?.toString(),
      rideId: json['rideId']?.toString(),
      driverName: rideDetails['driverName']?.toString() ?? json['driverName']?.toString(),
      driverPhone: rideDetails['driverPhone']?.toString() ?? json['driverPhone']?.toString(),
      vehiclePlate: rideDetails['vehiclePlate']?.toString() ?? json['vehiclePlate']?.toString(),
      vehicleModel: rideDetails['vehicleModel']?.toString() ?? json['vehicleModel']?.toString(),
      latitude: _toDouble(json['latitude']) != 0 ? _toDouble(json['latitude']) : 17.448293,
      longitude: _toDouble(json['longitude']) != 0 ? _toDouble(json['longitude']) : 78.391487,
      address: json['address']?.toString() ?? 'Live Coordinates',
      emergencyType: json['emergencyType']?.toString() ?? 'SAFETY_THREAT',
      notes: json['notes']?.toString(),
      status: json['status']?.toString().toUpperCase() ?? 'ACTIVE',
      adminNotes: json['adminNotes']?.toString(),
      resolvedBy: json['resolvedBy']?.toString(),
      resolvedAt: json['resolvedAt']?.toString(),
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}

class AppUpdateConfigModel {
  final String latestVersion;
  final String minSupportedVersion;
  final bool forceUpdate;
  final String title;
  final String message;
  final List<String> releaseNotes;
  final String storeUrl;
  final bool enabled;

  const AppUpdateConfigModel({
    required this.latestVersion,
    required this.minSupportedVersion,
    required this.forceUpdate,
    required this.title,
    required this.message,
    required this.releaseNotes,
    required this.storeUrl,
    required this.enabled,
  });

  factory AppUpdateConfigModel.fromJson(Map<String, dynamic> json) {
    return AppUpdateConfigModel(
      latestVersion: json['latestVersion']?.toString() ?? '1.0.0',
      minSupportedVersion: json['minSupportedVersion']?.toString() ?? '1.0.0',
      forceUpdate: json['forceUpdate'] == true,
      title: json['title']?.toString() ?? 'App Update Available',
      message: json['message']?.toString() ?? '',
      releaseNotes: (json['releaseNotes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      storeUrl: json['storeUrl']?.toString() ?? '',
      enabled: json['enabled'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
        'latestVersion': latestVersion,
        'minSupportedVersion': minSupportedVersion,
        'forceUpdate': forceUpdate,
        'title': title,
        'message': message,
        'releaseNotes': releaseNotes,
        'storeUrl': storeUrl,
        'enabled': enabled,
      };
}


