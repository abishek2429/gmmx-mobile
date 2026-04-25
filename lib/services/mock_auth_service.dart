import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../models/tenant_model.dart';

/// Mock authentication service that reads from local sample-db.json
class MockAuthService {
  List<UserModel>? _users;
  List<TenantModel>? _tenants;

  /// Load the sample database from assets
  Future<void> _loadDatabase() async {
    if (_users != null) return;

    final jsonString = await rootBundle.loadString('assets/data/sample-db.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;

    _users = (data['users'] as List)
        .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
        .toList();

    _tenants = (data['tenants'] as List)
        .map((t) => TenantModel.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  /// Find a user by phone number
  Future<UserModel?> findUserByPhone(String phone) async {
    await _loadDatabase();
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    try {
      return _users!.firstWhere(
        (u) => u.phone == cleaned && u.isActive,
      );
    } catch (_) {
      return null;
    }
  }

  /// Find a user by email
  Future<UserModel?> findUserByEmail(String email) async {
    await _loadDatabase();
    try {
      return _users!.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase() && u.isActive,
      );
    } catch (_) {
      return null;
    }
  }

  /// Verify OTP (always "123456" in mock mode)
  bool verifyOtp(UserModel user, String enteredOtp) {
    return enteredOtp == '123456';
  }

  /// Simulate OTP sending delay (feels realistic)
  Future<void> simulateOtpDelay() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  /// Simulate OTP verification delay
  Future<void> simulateVerifyDelay() async {
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  /// Get tenant info
  Future<TenantModel?> getTenant(String tenantId) async {
    await _loadDatabase();
    try {
      return _tenants!.firstWhere((t) => t.id == tenantId);
    } catch (_) {
      return null;
    }
  }

  /// Get all users (for dashboard stats)
  Future<List<UserModel>> getAllUsers() async {
    await _loadDatabase();
    return _users ?? [];
  }

  /// Get users by role
  Future<List<UserModel>> getUsersByRole(String role) async {
    await _loadDatabase();
    return _users!.where((u) => u.role.toUpperCase() == role.toUpperCase()).toList();
  }
}
