import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/gym_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';

class GymLookupScreen extends ConsumerStatefulWidget {
  const GymLookupScreen({super.key});

  @override
  ConsumerState<GymLookupScreen> createState() => _GymLookupScreenState();
}

class _GymLookupScreenState extends ConsumerState<GymLookupScreen> {
  final _controller = TextEditingController();
  final _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % 3;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _handleLookup() async {
    final gymId = _controller.text.trim().toLowerCase();
    if (gymId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await ref.read(gymProvider.notifier).lookupGym(gymId);
    
    if (mounted) {
      if (success) {
        context.go('/login');
      } else {
        setState(() => _isLoading = false);
        final gymState = ref.read(gymProvider);
        final errorMsg = gymState.maybeWhen(
          error: (err, _) => err.toString(),
          orElse: () => 'Gym not found. Please check the ID.',
        );
        setState(() => _error = errorMsg);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // ─── Background Glow ───
          Positioned(
            bottom: -100,
            left: -50,
            right: -50,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.05),
              ),
            ),
          ),
          
          // ─── Content ───
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // ─── Logo/Icon ───
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.fitness_center_rounded, size: 48, color: AppColors.primary),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    'Welcome to GMMX',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'The ultimate gym management experience',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // ─── Lookup Card (Glass) ───
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.glassCard(isDark: isDark, radius: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Find Your Gym',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your unique Gym ID to sign in',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        TextField(
                          controller: _controller,
                          style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'e.g. titan-fitness',
                            prefixIcon: Icon(Icons.domain_rounded, 
                              color: _error != null ? AppColors.error : AppColors.primary
                            ),
                            errorText: _error,
                            filled: true,
                            fillColor: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                          onSubmitted: (_) => _handleLookup(),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLookup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 8,
                              shadowColor: AppColors.primary.withValues(alpha: 0.4),
                            ),
                            child: _isLoading 
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Continue', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 20),
                                  ],
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // ─── Footer ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have a gym ID?',
                        style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: const Text('Register Gym', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 80),
                  
                  Opacity(
                    opacity: 0.5,
                    child: Text(
                      'POWERED BY GMMX',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
