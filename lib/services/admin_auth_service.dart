import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAuthService {
  static const String _keyToken = 'admin_access_token';
  static const String _keyRefreshToken = 'admin_refresh_token';
  static const String _keyAdminData = 'admin_user_data';

  static Future<void> saveAuth({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> adminData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
    await prefs.setString(_keyAdminData, jsonEncode(adminData));
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  static Future<Map<String, dynamic>?> getAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAdminData);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> updateTokens(String accessToken, [String? refreshToken]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_keyRefreshToken, refreshToken);
    }
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyAdminData);
    await prefs.clear(); // Complete purge of all local storage keys
  }
}

