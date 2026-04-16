import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'role_selection_page.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  const OtpVerificationPage({
    super.key,
    required this.mobile,
  });

  final String mobile;

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final otpController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  int resendCountdown = 0;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void handleVerifyOtp() {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      setState(() => errorMessage = 'Please enter the OTP');
      return;
    }

    if (otp.length != 6 || !RegExp(r'^\d+$').hasMatch(otp)) {
      setState(
          () => errorMessage = 'Please enter a valid 6-digit OTP');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => RoleSelectionPage(mobile: widget.mobile),
          ),
        );
      }
    });
  }

  void handleResendOtp() {
    setState(() {
      resendCountdown = 30;
      errorMessage = null;
    });

    Future.delayed(const Duration(seconds: 1), () {
      for (int i = 29; i >= 0; i--) {
        Future.delayed(Duration(seconds: 30 - i), () {
          if (mounted) {
            setState(() => resendCountdown = i);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0f172a),
              const Color(0xFF1a0f1f),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        foregroundDecoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              const Color(0xFFFF5C73).withValues(alpha: 0.06),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  elevation: 0,
                  color: const Color(0x1AFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: const Color(0xFFFF5C73).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Back Button
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Header
                        const Text(
                          'Verify OTP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We sent a code to +91 ${widget.mobile}',
                          style: const TextStyle(
                            color: Color(0xFFB0B9C1),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // OTP Input
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'OTP Code',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: otpController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 6,
                              enabled: !isLoading,
                              decoration: InputDecoration(
                                hintText: '000000',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 18,
                                  letterSpacing: 8,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF1E293B),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF334155),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFFF5C73),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                counterText: '',
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                letterSpacing: 8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        // Error Message
                        if (errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7F1D1D),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFDC2626).withValues(
                                  alpha: 0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFFCA5A5),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Verify Button
                        FilledButton(
                          onPressed: isLoading ? null : handleVerifyOtp,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5C73),
                            disabledBackgroundColor: const Color(0xFFFF5C73)
                                .withValues(alpha: 0.5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Verify OTP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 16),

                        // Resend OTP
                        Center(
                          child: TextButton(
                            onPressed: resendCountdown == 0
                                ? handleResendOtp
                                : null,
                            child: Text(
                              resendCountdown == 0
                                  ? 'Didn\'t receive code? Resend'
                                  : 'Resend in ${resendCountdown}s',
                              style: TextStyle(
                                color: resendCountdown == 0
                                    ? const Color(0xFFFF5C73)
                                    : const Color(0xFF64748B),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Info Box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A5F).withValues(
                              alpha: 0.4,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF3B82F6).withValues(
                                alpha: 0.2,
                              ),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            '✓ Check your SMS for the code\n✓ Code is valid for 10 minutes\n✓ Don\'t share this code with anyone',
                            style: TextStyle(
                              color: Color(0xFFADD7F6),
                              fontSize: 12,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
