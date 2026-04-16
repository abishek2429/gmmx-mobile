import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/home_page.dart';
import 'auth_controller.dart';

enum LoginMode { backendOtp, firebasePhone, firebaseEmailOtp }

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final emailLinkController = TextEditingController();
  bool otpRequested = false;
  LoginMode loginMode = LoginMode.backendOtp;

  @override
  void dispose() {
    mobileController.dispose();
    emailController.dispose();
    otpController.dispose();
    emailLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final authState = auth.asData?.value;
    final errorText = auth.hasError
        ? auth.error.toString().replaceFirst('Exception: ', '')
        : null;

    ref.listen(authControllerProvider, (previous, next) {
      final user = next.asData?.value.user;
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0f172a), // Dark navy base
              const Color(0xFF1a0f1f), // Dark with rose tint
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          // Add rose accent overlay
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF5C73), Color(0xFFFF8FA3)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: const Text(
                            'GMMX',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Secure access to gym operations',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SegmentedButton<LoginMode>(
                          style: ButtonStyle(
                            foregroundColor: WidgetStatePropertyAll(
                                Colors.white.withValues(alpha: 0.95)),
                            backgroundColor: WidgetStateProperty.resolveWith(
                              (states) {
                                if (states.contains(WidgetState.selected)) {
                                  return const Color(0xFFFF5C73);
                                }
                                return const Color(0x22000000);
                              },
                            ),
                            textStyle: const WidgetStatePropertyAll(
                              TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          segments: const [
                            ButtonSegment(
                              value: LoginMode.backendOtp,
                              icon: Icon(Icons.verified_rounded),
                              label: Text('OTP'),
                            ),
                            ButtonSegment(
                              value: LoginMode.firebasePhone,
                              icon: Icon(Icons.phone_android_rounded),
                              label: Text('Phone'),
                            ),
                            ButtonSegment(
                              value: LoginMode.firebaseEmailOtp,
                              icon: Icon(Icons.mail_outline_rounded),
                              label: Text('Email'),
                            ),
                          ],
                          selected: {loginMode},
                          onSelectionChanged: (selection) {
                            setState(() {
                              loginMode = selection.first;
                              otpRequested = false;
                              otpController.clear();
                              emailLinkController.clear();
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        if (loginMode != LoginMode.firebaseEmailOtp)
                          TextField(
                            controller: mobileController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration('Mobile Number'),
                          ),
                        if (loginMode == LoginMode.firebaseEmailOtp)
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration('Email Address'),
                          ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: otpRequested
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: loginMode != LoginMode.firebaseEmailOtp
                                      ? TextField(
                                          controller: otpController,
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(
                                              color: Colors.white),
                                          decoration:
                                              _inputDecoration('6-digit OTP'),
                                        )
                                      : TextField(
                                          controller: emailLinkController,
                                          keyboardType: TextInputType.url,
                                          style: const TextStyle(
                                              color: Colors.white),
                                          decoration: _inputDecoration(
                                              'Paste email sign-in link'),
                                          maxLines: 2,
                                        ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF5C73), Color(0xFFFF8FA3)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF5C73)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(52),
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 18),
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: auth.isLoading
                                  ? null
                                  : () => _onPrimaryActionPressed(),
                              icon: Icon(otpRequested
                                  ? Icons.verified_rounded
                                  : Icons.send_rounded),
                              label: Text(auth.isLoading
                                  ? 'Please wait...'
                                  : (otpRequested ? 'Verify OTP' : 'Send OTP')),
                            ),
                          ),
                        ),
                        if (otpRequested) ...[
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: auth.isLoading
                                ? null
                                : () {
                                    setState(() {
                                      otpRequested = false;
                                      otpController.clear();
                                      emailLinkController.clear();
                                    });
                                  },
                            child: const Text('Change number/method'),
                          ),
                        ],
                        const SizedBox(height: 8),
                        if (loginMode == LoginMode.backendOtp)
                          Text(
                            'Debug OTP: ${authState?.debugCode.isNotEmpty == true ? authState!.debugCode : '-'}',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85)),
                          ),
                        if (loginMode == LoginMode.firebasePhone)
                          Text(
                            'Firebase verification id: ${authState?.firebaseVerificationId.isNotEmpty == true ? 'received' : 'pending'}',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85)),
                          ),
                        if (loginMode == LoginMode.firebaseEmailOtp)
                          Text(
                            'Email link sent to: ${authState?.email.isNotEmpty == true ? authState!.email : '-'}',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85)),
                          ),
                        if (loginMode == LoginMode.firebasePhone)
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0x1A3b82f6),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: const Color(0x443b82f6)),
                            ),
                            child: const Text(
                              '💡 Tip: Firebase phone auth requires configuration in Firebase Console. Enable Phone provider, add your SMS region, and register your device SHA fingerprints.',
                              style: TextStyle(
                                  color: Color(0xFF93c5fd), fontSize: 12.5),
                            ),
                          ),
                        if (loginMode == LoginMode.backendOtp)
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0x1A10b981),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: const Color(0x4410b981)),
                            ),
                            child: const Text(
                              '✓ OTP works for all numbers connected to your gym. Debug OTP shown below for development.',
                              style: TextStyle(
                                  color: Color(0xFFA7f3d0), fontSize: 12.5),
                            ),
                          ),
                        if (errorText != null)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0x1Aef4444),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0x44ef4444)),
                            ),
                            child: Text(
                              '⚠ $errorText',
                              style: const TextStyle(
                                  color: Color(0xFFfca5a5),
                                  fontWeight: FontWeight.w600),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFFFF5C73),
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
    );
  }

  Future<void> _onPrimaryActionPressed() async {
    final controller = ref.read(authControllerProvider.notifier);

    if (!otpRequested) {
      switch (loginMode) {
        case LoginMode.backendOtp:
          await controller.requestBackendOtp(mobileController.text.trim());
          break;
        case LoginMode.firebasePhone:
          await controller
              .requestFirebasePhoneOtp(mobileController.text.trim());
          break;
        case LoginMode.firebaseEmailOtp:
          await controller.sendEmailOtpLink(emailController.text.trim());
          break;
      }

      if (!mounted) return;

      final next = ref.read(authControllerProvider);
      final data = next.asData?.value;
      final requestSucceeded = !next.hasError &&
          switch (loginMode) {
            LoginMode.backendOtp => (data?.mobile.isNotEmpty ?? false),
            LoginMode.firebasePhone =>
              (data?.firebaseVerificationId.isNotEmpty ?? false),
            LoginMode.firebaseEmailOtp => (data?.email.isNotEmpty ?? false),
          };

      setState(() {
        otpRequested = requestSucceeded;
      });
      return;
    }

    switch (loginMode) {
      case LoginMode.backendOtp:
        await controller.verifyBackendOtp(otpController.text.trim());
        break;
      case LoginMode.firebasePhone:
        await controller.verifyFirebasePhoneOtp(otpController.text.trim());
        break;
      case LoginMode.firebaseEmailOtp:
        await controller.verifyEmailOtpLink(emailLinkController.text.trim());
        break;
    }
  }
}
