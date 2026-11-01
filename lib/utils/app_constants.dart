/// Application constants for strings, timeouts, and configurations
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // API Constants
  static const int apiTimeout = 60; // seconds
  static const int maxRetryAttempts = 3;

  // Authentication Messages
  static const String otpSentSuccess = 'OTP sent successfully.';
  static const String otpVerifiedSuccess = 'OTP Verified successfully.';
  static const String logoutSuccess = 'Logged out successfully.';
  static const String invalidOtpError = 'Invalid OTP. Please try again.';
  static const String connectionTimeoutError =
      'Connection timed out. Please try again later.';
  static const String noInternetError =
      'No Internet connection. Please try again later.';
  static const String connectionFailedError =
      'Connection failed. Please check the server.';
  static const String serverUnavailableError =
      'Server is currently unavailable. Please try again later.';
  static const String serverTimeoutError =
      'Server response timed out. Please try again later.';
  static const String hostLookupFailedError = 'Unable to reach server';

  // SharedPreferences Keys
  static const String introductionKey = 'introduction';
  static const String userOnboardingKey = 'user_onboarding';
  static const String onboardingStatusKey = 'onboardingStatus';
  static const String locationPermissionAskedKey = 'location_permission_asked';

  // API Endpoints
  static const String sendOtpEndpoint = 'api/v1/users/user-otp-send/';
  static const String resendOtpEndpoint = 'api/v1/users/user-otp-resend/';
  static const String verifyOtpEndpoint = 'api/v1/users/otp-verify/';
  static const String logoutEndpoint = 'user/v1/logout/';
  static const String refreshTokenEndpoint = 'user/v1/login_refresh/';

  // App Configuration
  static const String appName = 'Share2Go';
  static const String appFontFamily = 'Figtree';
  static const int statusBarColor = 0xFFF4F7FF;

  // Design System
  static const double designWidth = 390.0;
  static const double designHeight = 844.0;

  // Error Messages
  static const String unexpectedError = 'An unexpected error occurred';
  static const String initializationError = 'Error initializing app';
  static const String connectivityInitError =
      'Failed to initialize connectivity service';

  // HTTP Status Codes
  static const int httpOk = 200;
  static const int httpCreated = 201;
  static const int httpBadRequest = 400;
  static const int httpUnauthorized = 401;
  static const int httpForbidden = 403;
  static const int httpNotFound = 404;
  static const int httpInternalServerError = 500;
}
