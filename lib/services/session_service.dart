import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Manages login session persistence (Remember Me)
class SessionService {
  static const _keyUser = 'gmmx_session_user';
  static const _keyLoggedIn = 'gmmx_logged_in';

  final SharedPreferences _prefs;

  SessionService(this._prefs);

  /// Check if user is logged in
  bool get isLoggedIn => _prefs.getBool(_keyLoggedIn) ?? false;

  /// Save user session
  Future<void> saveSession(UserModel user) async {
    await _prefs.setString(_keyUser, json.encode(user.toJson()));
    await _prefs.setBool(_keyLoggedIn, true);
  }

  /// Get the logged-in user
  UserModel? getLoggedInUser() {
    final userJson = _prefs.getString(_keyUser);
    if (userJson == null) return null;

    try {
      final data = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Clear session (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_keyUser);
    await _prefs.setBool(_keyLoggedIn, false);
  }
}
