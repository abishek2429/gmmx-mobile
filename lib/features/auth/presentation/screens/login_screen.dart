import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:gmmx_mobile/features/auth/providers/gym_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/device_id_service.dart';
import '../auth_controller.dart';
import '../../../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _mobileController = TextEditingController();
  final _pinController = TextEditingController();
  bool _showPinField = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final mobile = _mobileController.text.trim();
    final pin = _pinController.text.trim();
    final gym = ref.read(gymProvider).value;

    if (mobile.isEmpty || pin.length < 4 || gym == null) {
      _showError('Please enter valid mobile and 4-digit PIN');
      return;
    }

    final deviceId = await ref.read(deviceIdServiceProvider).getDeviceId();

    final user = await ref.read(authControllerProvider.notifier).login(
      gymId: gym.subdomain,
      identifier: mobile,
      pin: pin,
      deviceId: deviceId,
    );

    if (user != null && mounted) {
      final slug = gym.subdomain;
      context.go('/$slug/${user.normalizedRole}');
    }
  }

  void _handleGoogleLogin() async {
    final user = await ref.read(authControllerProvider.notifier).googleLogin();
    if (user != null && mounted) {
      final gym = ref.read(gymProvider).value;
      final slug = gym?.subdomain ?? 'dashboard';
      context.go('/$slug/${user.normalizedRole}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final gymState = ref.watch(gymProvider);
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: gymState.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
          data: (gym) {
            if (gym == null) return const SizedBox.shrink();
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      onPressed: () {
                        ref.read(gymProvider.notifier).clearGym();
                        context.go('/gym-lookup');
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // ─── Branding ───
                  Center(
                    child: Hero(
                      tag: 'gym-logo',
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            gym.logoUrl ?? 'https://api.gmmx.app/logo-gmmx.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, _, __) => 
                              const Icon(Icons.fitness_center, color: AppColors.primary, size: 40),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    gym.displayName ?? gym.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 40),
                  
                  // ─── Login Form ───
                  FTextField(
                    control: FTextFieldControl.managed(controller: _mobileController),
                    label: const Text('Mobile Number'),
                    hint: 'Enter your mobile number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  
                  if (!_showPinField)
                    FButton(
                      onPress: () => setState(() => _showPinField = true),
                      child: const Text('Continue with OTP/PIN'),
                    )
                  else ...[
                    FTextField(
                      control: FTextFieldControl.managed(controller: _pinController),
                      label: const Text('4-Digit PIN'),
                      hint: '••••',
                      obscureText: true,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),
                    FButton(
                      onPress: authState.isVerifying ? null : _handleLogin,
                      child: authState.isVerifying 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Sign In'),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // ─── Google Sign In ───
                  FButton(
                    onPress: authState.isGoogleVerifying ? null : _handleGoogleLogin,
                    variant: FButtonVariant.outline,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.g_mobiledata_rounded, size: 28),
                        SizedBox(width: 8),
                        Text('Sign up with Google'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Center(
                    child: Text(
                      'Powered by Gmmx Technologies',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

enum LoginMethod { pin, google }
