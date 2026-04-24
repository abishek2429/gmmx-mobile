import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  late AnimationController _otpRevealController;
  late Animation<double> _otpSlideAnimation;
  late Animation<double> _otpFadeAnimation;

  int _resendCountdown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _otpRevealController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _otpSlideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _otpRevealController, curve: Curves.easeOutCubic),
    );
    _otpFadeAnimation = CurvedAnimation(
      parent: _otpRevealController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _otpRevealController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _handleSendOtp() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      _showFeedback('Please enter a valid 10-digit mobile number', isError: true);
      return;
    }

    ref.read(authControllerProvider.notifier).sendOtp(phone);
  }

  void _handleVerifyOtp() {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length < 6) {
      _showFeedback('Please enter the 6-digit OTP', isError: true);
      return;
    }

    ref.read(authControllerProvider.notifier).verifyOtp(otp).then((user) {
      if (user != null && mounted) {
        _showFeedback('Welcome, ${user.fullName}!', isError: false);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.go('/${user.normalizedRole}/home');
          }
        });
      }
    });
  }

  void _handleGoogleSignIn() {
    ref.read(authControllerProvider.notifier).mockGoogleSignIn().then((user) {
      if (user != null && mounted) {
        _showFeedback('Signed in as ${user.fullName}', isError: false);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.go('/${user.normalizedRole}/home');
          }
        });
      }
    });
  }

  void _startResendTimer() {
    _resendCountdown = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) timer.cancel();
      });
    });
  }

  void _autoFillOtp() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _otpController.text = '123456';
        setState(() {});
      }
    });
  }

  void _showFeedback(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    // Listen for state changes
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      // OTP sent successfully — reveal OTP section
      if (next.otpSent && !(prev?.otpSent ?? false)) {
        _otpRevealController.forward();
        _startResendTimer();
        _autoFillOtp();
      }

      // Error handling
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        _showFeedback(next.errorMessage!, isError: true);
      }
    });

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            ref.read(authControllerProvider.notifier).reset();
            Navigator.pop(context);
          },
        ),
        actions: [
          // Dark mode toggle
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              size: 22,
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Title
              Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your mobile number to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 40),

              // Phone input
              _buildPhoneInput(isDark, authState),

              // OTP section (revealed after send)
              _buildOtpSection(isDark, authState),

              const SizedBox(height: 40),

              // OR divider
              _buildDivider(isDark),

              const SizedBox(height: 24),

              // Google sign-in button
              _buildGoogleButton(isDark, authState),

              const SizedBox(height: 40),

              // Dev hint
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.secondaryBgDark
                        : AppColors.secondaryBgLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.developer_mode_rounded,
                        size: 16,
                        color: AppColors.primary.withOpacity(0.8),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Dev: OTP is 123456',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput(bool isDark, AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),

        // Phone field with country code
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              // Country code
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                ),
                child: Text(
                  '+91',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
              ),
              // Phone input
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !authState.otpSent,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '9876543210',
                    hintStyle: TextStyle(
                      color: isDark ? AppColors.textHintDark : AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  ),
                ),
              ),
              // Edit button (after OTP sent)
              if (authState.otpSent)
                IconButton(
                  icon: Icon(
                    Icons.edit_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    ref.read(authControllerProvider.notifier).reset();
                    _otpRevealController.reverse();
                    _otpController.clear();
                    _resendTimer?.cancel();
                    setState(() => _resendCountdown = 0);
                  },
                ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Send OTP button (hidden after OTP sent)
        if (!authState.otpSent)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FButton(
              onPress: authState.isLoading ? null : _handleSendOtp,
              child: authState.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Send OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
      ],
    );
  }

  Widget _buildOtpSection(bool isDark, AuthState authState) {
    return AnimatedBuilder(
      animation: _otpRevealController,
      builder: (context, child) {
        if (_otpRevealController.value == 0 && !authState.otpSent) {
          return const SizedBox.shrink();
        }

        return Opacity(
          opacity: _otpFadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _otpSlideAnimation.value),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),

                // Success badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'OTP sent to +91 ${_phoneController.text}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Enter OTP',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // OTP input field
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 12,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: '• • • • • •',
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.textHintDark : AppColors.textHint,
                        letterSpacing: 8,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Resend link
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_resendCountdown > 0)
                      Text(
                        'Resend in ${_resendCountdown}s',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textHintDark
                              : AppColors.textHint,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          _handleSendOtp();
                          _startResendTimer();
                        },
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Verify button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FButton(
                    onPress: authState.isVerifying ? null : _handleVerifyOtp,
                    child: authState.isVerifying
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Verify & Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: isDark ? AppColors.textHintDark : AppColors.textHint,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton(bool isDark, AuthState authState) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: authState.isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.dividerLight,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google "G" icon (Material icon fallback)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.g_mobiledata,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
