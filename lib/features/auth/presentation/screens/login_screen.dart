import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/device_id_service.dart';
import '../../providers/gym_provider.dart';
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
  bool _canBiometric = false;
  LoginMethod _selectedLoginMethod = LoginMethod.pin;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  void _checkBiometrics() async {
    final available = await ref.read(biometricServiceProvider).isBiometricAvailable();
    setState(() => _canBiometric = available);
  }

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
      context.go('/${user.normalizedRole}/home');
    }
  }

  void _handleBiometric() async {
    final authenticated = await ref.read(biometricServiceProvider).authenticate();
    if (authenticated) {
      // In a real app, you'd store a secure token for biometric login
      // For MVP, we'll show a message
      _showError('Biometric login requires a previous successful PIN login.');
    }
  }

  void _handleGoogleLogin() async {
    final user = await ref.read(authControllerProvider.notifier).googleLogin();
    if (user != null && mounted) {
      context.go('/${user.normalizedRole}/home');
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
      body: Stack(
        children: [
          // ─── Background Glow ───
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.04),
              ),
            ),
          ),

          SafeArea(
            child: gymState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
              data: (gym) {
                if (gym == null) return const SizedBox.shrink();
                
                return Column(
                  children: [
                    // ─── Header ───
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios_new_rounded, 
                              color: isDark ? Colors.white70 : AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              ref.read(gymProvider.notifier).clearGym();
                              context.go('/gym-lookup');
                            },
                          ),
                          const Spacer(),
                          if (gym.logoUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(gym.logoUrl!, height: 32, width: 32, fit: BoxFit.cover),
                            ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            
                            // ─── Gym Brand ───
                            if (gym.logoUrl != null)
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  image: DecorationImage(image: NetworkImage(gym.logoUrl!), fit: BoxFit.cover),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.fitness_center_rounded, size: 56, color: AppColors.primary),
                              ),
                            
                            const SizedBox(height: 24),
                            
                            Text(
                              gym.displayName ?? gym.name,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Gym ID: ${gym.subdomain}',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 48),

                            // ─── Login Card ───
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: AppTheme.glassCard(isDark: isDark, radius: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextField(
                                    controller: _mobileController,
                                    keyboardType: TextInputType.phone,
                                    style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                                    decoration: InputDecoration(
                                      labelText: 'Mobile Number',
                                      prefixIcon: const Icon(Icons.phone_iphone_rounded, color: AppColors.primary),
                                      filled: true,
                                      fillColor: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SegmentedButton<LoginMethod>(
                                    segments: const <ButtonSegment<LoginMethod>>[
                                      ButtonSegment<LoginMethod>(
                                        value: LoginMethod.pin,
                                        label: Text('PIN Login'),
                                        icon: Icon(Icons.pin),
                                      ),
                                      ButtonSegment<LoginMethod>(
                                        value: LoginMethod.google,
                                        label: Text('Google Login'),
                                        icon: Icon(Icons.g_mobiledata_rounded),
                                      ),
                                    ],
                                    selected: <LoginMethod>{_selectedLoginMethod},
                                    onSelectionChanged: (selection) {
                                      setState(() {
                                        _selectedLoginMethod = selection.first;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  if (_selectedLoginMethod == LoginMethod.pin) ...[
                                  TextField(
                                    controller: _pinController,
                                    keyboardType: TextInputType.number,
                                    obscureText: true,
                                    style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                                    inputFormatters: [LengthLimitingTextInputFormatter(4)],
                                    decoration: InputDecoration(
                                      labelText: '4-Digit PIN',
                                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                                      filled: true,
                                      fillColor: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: authState.isVerifying ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        elevation: 8,
                                        shadowColor: AppColors.primary.withValues(alpha: 0.4),
                                      ),
                                      child: authState.isVerifying
                                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                        : const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                    ),
                                  ),
                                  if (_canBiometric) ...[
                                    const SizedBox(height: 20),
                                    OutlinedButton.icon(
                                      onPressed: _handleBiometric,
                                      icon: const Icon(Icons.fingerprint_rounded, size: 24),
                                      label: const Text('Use Biometrics', style: TextStyle(fontWeight: FontWeight.bold)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                                        foregroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                    ),
                                  ],
                                  ] else ...[
                                  SizedBox(
                                    height: 56,
                                    child: OutlinedButton.icon(
                                      onPressed: authState.isGoogleVerifying ? null : _handleGoogleLogin,
                                      icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
                                      label: const Text('Sign in with Google', style: TextStyle(fontWeight: FontWeight.bold)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                                        foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                    ),
                                  ),
                                  ],
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.black12)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'OR',
                                          style: TextStyle(
                                            color: isDark ? Colors.white54 : Colors.black54,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.black12)),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  OutlinedButton.icon(
                                    onPressed: authState.isGoogleVerifying ? null : _handleGoogleLogin,
                                    icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
                                    label: const Text('Sign in with Google', style: TextStyle(fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                                      foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            
                            if (authState.errorMessage != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.error.withOpacity(0.2)),
                                ),
                                child: Text(
                                  authState.errorMessage!,
                                  style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum LoginMethod { pin, google }
