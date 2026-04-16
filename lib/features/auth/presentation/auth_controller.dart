import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthState>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<AuthState>> {
  AuthController(this._repository) : super(const AsyncData(AuthState()));

  final AuthRepository _repository;

  Future<void> requestBackendOtp(String mobile) async {
    state = const AsyncLoading();
    try {
      final debugCode = await _repository.requestOtp(mobile);
      state = AsyncData(AuthState(mobile: mobile, debugCode: debugCode));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<AuthUser?> verifyBackendOtp(String code) async {
    final current = state.asData?.value;
    if (current == null || current.mobile.isEmpty) {
      return null;
    }

    state = const AsyncLoading();
    try {
      final user =
          await _repository.verifyOtp(mobile: current.mobile, code: code);
      state = AsyncData(AuthState(
          mobile: current.mobile, debugCode: current.debugCode, user: user));
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<void> requestFirebasePhoneOtp(String mobile) async {
    state = const AsyncLoading();
    try {
      final verificationId = await _repository.requestFirebasePhoneOtp(mobile);
      state = AsyncData(
          AuthState(mobile: mobile, firebaseVerificationId: verificationId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<AuthUser?> verifyFirebasePhoneOtp(String code) async {
    final current = state.asData?.value;
    if (current == null || current.firebaseVerificationId.isEmpty) {
      return null;
    }

    state = const AsyncLoading();
    try {
      final user = await _repository.verifyFirebasePhoneOtp(
        verificationId: current.firebaseVerificationId,
        code: code,
      );
      state = AsyncData(
        AuthState(
          mobile: current.mobile,
          firebaseVerificationId: current.firebaseVerificationId,
          user: user,
        ),
      );
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<void> sendEmailOtpLink(String email) async {
    state = const AsyncLoading();
    try {
      await _repository.sendEmailOtpLink(email);
      state = AsyncData(AuthState(email: email));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<AuthUser?> verifyEmailOtpLink(String emailLink) async {
    final current = state.asData?.value;
    if (current == null || current.email.isEmpty) {
      return null;
    }

    state = const AsyncLoading();
    try {
      final user = await _repository.verifyEmailOtpLink(
          email: current.email, emailLink: emailLink);
      state = AsyncData(AuthState(email: current.email, user: user));
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

class AuthState {
  const AuthState({
    this.mobile = '',
    this.email = '',
    this.debugCode = '',
    this.firebaseVerificationId = '',
    this.user,
  });

  final String mobile;
  final String email;
  final String debugCode;
  final String firebaseVerificationId;
  final AuthUser? user;
}
