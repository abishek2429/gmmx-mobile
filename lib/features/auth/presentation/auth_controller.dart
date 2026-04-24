import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/mock_auth_service.dart';
import '../../../services/session_service.dart';
import '../../../models/user_model.dart';
import '../../../core/providers/theme_provider.dart';

/// Provides the mock auth service
final mockAuthServiceProvider = Provider<MockAuthService>((ref) {
  return MockAuthService();
});

/// Provides the session service
final sessionServiceProvider = Provider<SessionService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SessionService(prefs);
});

/// Auth state
class AuthState {
  final String phone;
  final bool otpSent;
  final bool isLoading;
  final bool isVerifying;
  final UserModel? user;
  final String? errorMessage;
  final String mockOtp;

  const AuthState({
    this.phone = '',
    this.otpSent = false,
    this.isLoading = false,
    this.isVerifying = false,
    this.user,
    this.errorMessage,
    this.mockOtp = '123456',
  });

  AuthState copyWith({
    String? phone,
    bool? otpSent,
    bool? isLoading,
    bool? isVerifying,
    UserModel? user,
    String? errorMessage,
    String? mockOtp,
  }) {
    return AuthState(
      phone: phone ?? this.phone,
      otpSent: otpSent ?? this.otpSent,
      isLoading: isLoading ?? this.isLoading,
      isVerifying: isVerifying ?? this.isVerifying,
      user: user ?? this.user,
      errorMessage: errorMessage,
      mockOtp: mockOtp ?? this.mockOtp,
    );
  }
}

/// Auth controller using mock service
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref.watch(mockAuthServiceProvider),
    ref.watch(sessionServiceProvider),
  );
});

class AuthController extends StateNotifier<AuthState> {
  final MockAuthService _authService;
  final SessionService _sessionService;

  AuthController(this._authService, this._sessionService)
      : super(const AuthState());

  /// Send OTP to phone number (mocked)
  Future<void> sendOtp(String phone) async {
    state = state.copyWith(
      phone: phone,
      isLoading: true,
      errorMessage: null,
    );

    try {
      // Simulate network delay
      await _authService.simulateOtpDelay();

      // Check if user exists
      final user = await _authService.findUserByPhone(phone);
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No account found with this mobile number',
        );
        return;
      }

      // OTP "sent" successfully
      state = state.copyWith(
        isLoading: false,
        otpSent: true,
        mockOtp: user.otp,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to send OTP. Please try again.',
      );
    }
  }

  /// Verify OTP and login
  Future<UserModel?> verifyOtp(String enteredOtp) async {
    state = state.copyWith(isVerifying: true, errorMessage: null);

    try {
      await _authService.simulateVerifyDelay();

      final user = await _authService.findUserByPhone(state.phone);
      if (user == null) {
        state = state.copyWith(
          isVerifying: false,
          errorMessage: 'User not found',
        );
        return null;
      }

      if (!_authService.verifyOtp(user, enteredOtp)) {
        state = state.copyWith(
          isVerifying: false,
          errorMessage: 'Invalid OTP. Try 123456',
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
        errorMessage: 'Verification failed. Please try again.',
      );
      return null;
    }
  }

  /// Simulate Google sign-in (mock)
  Future<UserModel?> mockGoogleSignIn() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authService.simulateOtpDelay();

      // Default to the owner user for Google sign-in demo
      final user = await _authService.findUserByEmail('nitheeshmk5@gmail.com');
      if (user != null) {
        await _sessionService.saveSession(user);
        state = state.copyWith(isLoading: false, user: user);
        return user;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Google sign-in simulated — no matching account',
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Google sign-in failed',
      );
      return null;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _sessionService.clearSession();
    state = const AuthState();
  }

  /// Reset state for new login attempt
  void reset() {
    state = const AuthState();
  }
}
