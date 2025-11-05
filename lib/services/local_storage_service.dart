import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static const String _userKey = 'logged_in_user';
  static const String _loginTimeKey = 'login_time';

  // Save user data to local storage
  static Future<bool> saveUser(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(userData);
      final loginTime = DateTime.now().millisecondsSinceEpoch;

      await prefs.setString(_userKey, userJson);
      await prefs.setInt(_loginTimeKey, loginTime);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get saved user data from local storage
  static Future<Map<String, dynamic>?> getSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson == null) {
        return null;
      }

      // Check if login is still valid (optional: expire after 30 days)
      final loginTime = prefs.getInt(_loginTimeKey) ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final daysSinceLogin = (currentTime - loginTime) / (1000 * 60 * 60 * 24);

      if (daysSinceLogin > 30) {
        // Login expired, clear data
        await clearUser();
        return null;
      }

      return json.decode(userJson);
    } catch (e) {
      return null;
    }
  }

  // Clear user data from local storage (logout)
  static Future<bool> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_loginTimeKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    final user = await getSavedUser();
    return user != null;
  }

  // Get user info for display
  static Future<String> getUserInfo() async {
    final user = await getSavedUser();
    if (user != null) {
      final loginTime = await SharedPreferences.getInstance().then(
        (prefs) => prefs.getInt(_loginTimeKey) ?? 0,
      );
      final loginDate = DateTime.fromMillisecondsSinceEpoch(loginTime);
      return 'Logged in as: ${user['Name']} (${user['Employee ID']}) - ${_formatDate(loginDate)}';
    }
    return 'Not logged in';
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
