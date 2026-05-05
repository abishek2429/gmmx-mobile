import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
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
  String _countryCode = '+91';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final state = GoRouterState.of(context);
    final pathSlug = state.pathParameters['slug'] ?? '';
    final gym = ref.read(gymProvider).value;
    
    // Always prioritize the URL slug if available (source of truth for web/deep links)
    String gymId = pathSlug.isNotEmpty ? pathSlug : (gym?.subdomain ?? '');
    
    if (gymId.isEmpty) {
      _showError('Gym information missing. Please go back and try again.');
      return;
    }

    // If the URL slug differs from loaded gym, trigger a quick lookup to sync state
    if (pathSlug.isNotEmpty && gym?.subdomain != pathSlug) {
      ref.read(gymProvider.notifier).lookupGym(pathSlug);
    }

    if (_mobileController.text.trim().isEmpty || _pinController.text.trim().length < 4) {
      _showError('Please enter valid mobile and 4-digit PIN');
      return;
    }

    final mobile = _mobileController.text.trim();
    final fullMobile = '$_countryCode$mobile';
    
    final deviceId = await ref.read(deviceIdServiceProvider).getDeviceId();

    final user = await ref.read(authControllerProvider.notifier).login(
      gymId: gymId,
      identifier: fullMobile,
      pin: _pinController.text.trim(),
      deviceId: deviceId,
    );

    if (user != null && mounted) {
      context.go('/$gymId/${user.normalizedRole}');
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: gymState.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
          data: (gym) {
            if (gym == null) return const SizedBox.shrink();
            
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 
                                 MediaQuery.of(context).padding.top - 
                                 MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
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
                                  child: Image.asset(
                                    'assets/images/logo-trans.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, _, __) => 
                                      const Icon(Icons.fitness_center, color: AppColors.primary, size: 40),
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
                            
                            if (authState.errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  authState.errorMessage!,
                                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // ─── Login As Prompt ───
                            if (authState.lastUser != null && authState.user == null) ...[
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(isDark ? 0.1 : 0.05),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Welcome Back!',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Login as ${authState.lastUser!.fullName}?',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      authState.lastUser!.email ?? authState.lastUser!.phone ?? '',
                                      style: TextStyle(fontSize: 12, color: isDark ? Colors.grey : Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 20),
                                    FButton(
                                      onPress: () => ref.read(authControllerProvider.notifier).quickLogin(),
                                      child: const Text('Yes, continue'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Option to use a different account
                                        ref.read(authControllerProvider.notifier).reset();
                                      },
                                      child: const Text('Use a different account', style: TextStyle(fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              const Row(
                                children: [
                                  Expanded(child: Divider()),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('or sign in with', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ),
                                  Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 32),
                            ],
                            
                            // ─── Login Form ───
                            Theme(
                              data: Theme.of(context).copyWith(
                                inputDecorationTheme: InputDecorationTheme(
                                  filled: true,
                                  fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                              ),
                              child: IntlPhoneField(
                                controller: _mobileController,
                                initialCountryCode: 'IN',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                dropdownTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  labelText: 'Mobile Number',
                                  labelStyle: TextStyle(
                                    color: isDark ? Colors.grey : Colors.grey[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  hintText: '99447XXXXX',
                                  counterText: '', // Hide default counter
                                ),
                                onChanged: (phone) {
                                  setState(() {
                                    _countryCode = '+${phone.countryCode}';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            if (!_showPinField)
                              FButton(
                                onPress: () => setState(() => _showPinField = true),
                                child: const Text('Continue with PIN'),
                              )
                            else ...[
                              FTextField.password(
                                control: FTextFieldControl.managed(controller: _pinController),
                                label: const Text('4-Digit PIN'),
                                hint: '••••',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please contact your gym administrator to reset your PIN.')),
                                    );
                                  },
                                  child: Text(
                                    'Forgot PIN?',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              FButton(
                                onPress: authState.isVerifying ? null : _handleLogin,
                                child: authState.isVerifying 
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Sign In'),
                              ),
                            ],
                            
                            const Spacer(),
                            
                            const Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('or', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
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
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

enum LoginMethod { pin, google }
