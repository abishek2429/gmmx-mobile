import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import '../../../services/session_service.dart';
import '../../../models/user_model.dart';
import '../../../core/providers/theme_provider.dart';

import '../../../core/network/dio_client.dart';

/// Provides the real auth service
final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AuthService(dio);
});

/// Provides the session service
final sessionServiceProvider = Provider<SessionService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SessionService(prefs);
});

/// Auth state
class AuthState {
  final String identifier;
  final bool otpSent;
  final bool isLoading;
  final bool isVerifying;
  final bool isSendingOtp;
  final bool isGoogleVerifying;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.identifier = '',
    this.otpSent = false,
    this.isLoading = false,
    this.isVerifying = false,
    this.isSendingOtp = false,
    this.isGoogleVerifying = false,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    String? identifier,
    bool? otpSent,
    bool? isLoading,
    bool? isVerifying,
    bool? isSendingOtp,
    bool? isGoogleVerifying,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      identifier: identifier ?? this.identifier,
      otpSent: otpSent ?? this.otpSent,
      isLoading: isLoading ?? this.isLoading,
      isVerifying: isVerifying ?? this.isVerifying,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isGoogleVerifying: isGoogleVerifying ?? this.isGoogleVerifying,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

/// Auth controller using real backend
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref.watch(authServiceProvider),
    ref.watch(sessionServiceProvider),
  );
});

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;
  final SessionService _sessionService;

  AuthController(this._authService, this._sessionService)
      : super(const AuthState());

  /// Login with PIN
  Future<UserModel?> login({
    required String gymId,
    required String identifier,
    required String pin,
    String? deviceId,
  }) async {
    state = state.copyWith(isVerifying: true, errorMessage: null, identifier: identifier);

    try {
      final user = await _authService.login(
        gymId: gymId,
        identifier: identifier,
        pin: pin,
        deviceId: deviceId,
      );
      
      if (user == null) {
        state = state.copyWith(
          isVerifying: false,
          errorMessage: 'Invalid PIN. Try again.',
        );
        return null;
      }

      // Save session
      await _sessionService.saveSession(user);

      state = state.copyWith(
        isVerifying: false,
        user: user,
      );

      return user;
    } catch (e) {
      state = state.copyWith(
        isVerifying: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  /// Google Login
  Future<UserModel?> googleLogin() async {
    state = state.copyWith(isGoogleVerifying: true, errorMessage: null);

    try {
      final user = await _authService.loginWithGoogle();
      
      if (user == null) {
        state = state.copyWith(
          isGoogleVerifying: false,
        );
        return null;
      }

      // Save session
      await _sessionService.saveSession(user);

      state = state.copyWith(
        isGoogleVerifying: false,
        user: user,
      );

      return user;
    } catch (e) {
      state = state.copyWith(
        isGoogleVerifying: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  /// Send OTP
  Future<bool> sendOtp(String identifier) async {
    state = state.copyWith(isSendingOtp: true, errorMessage: null, identifier: identifier);
    try {
      await _authService.sendOtp(identifier);
      state = state.copyWith(isSendingOtp: false, otpSent: true);
      return true;
    } catch (e) {
      state = state.copyWith(isSendingOtp: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isVerifying: true, errorMessage: null);
    try {
      await _authService.verifyOtp(state.identifier, otp);
      state = state.copyWith(isVerifying: false);
      return true;
    } catch (e) {
      state = state.copyWith(isVerifying: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      await _sessionService.clearSession();
      state = const AuthState();
    }
  }

  /// Reset state for new login attempt
  void reset() {
    state = const AuthState();
  }
}
