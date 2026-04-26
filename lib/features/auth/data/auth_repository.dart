import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config.dart';
import '../../../core/network/dio_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioClientProvider));
});

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<String> requestOtp(String mobile) async {
    final response = await _dio.post(
      '/api/auth/mobile/otp',
      data: {'tenantSlug': AppConfig.tenantSlug, 'mobile': mobile},
    );
    return response.data['debugCode'] as String? ?? '';
  }

  Future<AuthUser> verifyOtp(
      {required String mobile, required String code}) async {
    final response = await _dio.post(
      '/api/auth/mobile/verify',
      data: {
        'tenantSlug': AppConfig.tenantSlug,
        'mobile': mobile,
        'code': code
      },
    );
    final data = response.data as Map<String, dynamic>;
    return AuthUser(
      userId: data['userId'] as String,
      role: data['role'] as String,
      tenantSlug: data['tenantSlug'] as String,
      provider: 'backend-otp',
    );
  }

  Future<String> requestPhoneOtp(String mobile) async {
    await requestOtp(mobile);
    // Legacy method retained for UI compatibility: use mobile as verification token.
    return mobile;
  }

  Future<AuthUser> verifyPhoneOtp({
    required String verificationId,
    required String code,
  }) async {
    final user = await verifyOtp(mobile: verificationId, code: code);
    return AuthUser(
      userId: user.userId,
      role: user.role,
      tenantSlug: user.tenantSlug,
      provider: 'backend-phone',
    );
  }

  Future<void> sendEmailOtp(String email) async {
    await _dio.post(
      '/api/auth/email/otp',
      data: {'tenantSlug': AppConfig.tenantSlug, 'email': email},
    );
  }

  Future<AuthUser> verifyEmailOtp(
      {required String email, required String emailLink}) async {
    final response = await _dio.post(
      '/api/auth/email/verify',
      data: {
        'tenantSlug': AppConfig.tenantSlug,
        'email': email,
        'codeOrLink': emailLink,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return AuthUser(
      userId: data['userId'] as String,
      role: data['role'] as String,
      tenantSlug: data['tenantSlug'] as String,
      provider: 'backend-email',
    );
  }
}

class AuthUser {
  AuthUser(
      {required this.userId,
      required this.role,
      required this.tenantSlug,
      this.provider = 'backend-otp'});

  final String userId;
  final String role;
  final String tenantSlug;
  final String provider;
}
