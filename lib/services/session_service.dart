import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../core/providers/theme_provider.dart';

final sessionServiceProvider = Provider<SessionService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SessionService(prefs);
});

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

  /// Get the stored gym slug for quick login
  String? getStoredGymSlug() {
    return _prefs.getString('gmmx_last_gym_slug');
  }

  /// Save the gym slug for future sessions
  Future<void> saveGymSlug(String slug) async {
    await _prefs.setString('gmmx_last_gym_slug', slug);
  }
}
