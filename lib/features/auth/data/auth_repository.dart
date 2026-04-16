import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config.dart';
import '../../../core/network.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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

  Future<String> requestFirebasePhoneOtp(String mobile) async {
    final completer = Completer<String>();
    final phoneNumber = _formatIndianPhoneNumber(mobile);

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        // Keep explicit OTP verify path so users can still confirm code entry manually.
      },
      verificationFailed: (e) {
        if (!completer.isCompleted) {
          completer.completeError(Exception(_firebaseErrorMessage(e)));
        }
      },
      codeSent: (verificationId, _) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      codeAutoRetrievalTimeout: (verificationId) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
    );

    return completer.future;
  }

  Future<AuthUser> verifyFirebasePhoneOtp({
    required String verificationId,
    required String code,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: code,
    );

    try {
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Firebase sign-in did not return a user');
      }

      return AuthUser(
        userId: user.uid,
        role: 'member',
        tenantSlug: AppConfig.tenantSlug,
        provider: 'firebase-phone',
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_firebaseErrorMessage(e));
    }
  }

  Future<void> sendEmailOtpLink(String email) async {
    final settings = ActionCodeSettings(
      url: AppConfig.firebaseEmailLinkUrl,
      handleCodeInApp: true,
      androidPackageName: AppConfig.androidPackageName,
      androidInstallApp: true,
      iOSBundleId: AppConfig.iosBundleId,
    );

    try {
      await _firebaseAuth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: settings,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_firebaseErrorMessage(e));
    }
  }

  Future<AuthUser> verifyEmailOtpLink(
      {required String email, required String emailLink}) async {
    if (!_firebaseAuth.isSignInWithEmailLink(emailLink)) {
      throw Exception('Invalid email sign-in link');
    }

    try {
      final userCredential = await _firebaseAuth.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Email OTP verification did not return a user');
      }

      return AuthUser(
        userId: user.uid,
        role: 'member',
        tenantSlug: AppConfig.tenantSlug,
        provider: 'firebase-email-link',
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_firebaseErrorMessage(e));
    }
  }

  String _firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'operation-not-allowed':
        return 'Phone authentication is disabled for this Firebase project. Enable Phone provider and allow your SMS region in Firebase Console.';
      case 'invalid-app-credential':
      case 'app-not-authorized':
        return 'Android app verification failed (SHA or Play Integrity). Add your app SHA-1 and SHA-256 fingerprints in Firebase project settings.';
      case 'too-many-requests':
        return 'Too many OTP attempts. Wait for a while and retry.';
      case 'invalid-phone-number':
        return 'Invalid phone number format. Use a valid 10-digit Indian number.';
      case 'captcha-check-failed':
        return 'reCAPTCHA verification failed. Retry with stable internet or update Google Play Services.';
      case 'network-request-failed':
        return 'Network error while contacting Firebase. Check internet connectivity and retry.';
      default:
        return e.message ??
            'Firebase authentication failed. Please verify project settings and try again.';
    }
  }

  String _formatIndianPhoneNumber(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.startsWith('91') && digitsOnly.length == 12) {
      return '+$digitsOnly';
    }
    if (digitsOnly.length == 10) {
      return '+91$digitsOnly';
    }
    if (value.startsWith('+')) {
      return value;
    }
    return '+$digitsOnly';
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
