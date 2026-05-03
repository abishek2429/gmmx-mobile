import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/session_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _splashDuration = Duration(seconds: 3);
  static const _pulseDuration = Duration(milliseconds: 800);
  static const _logoAsset = 'assets/images/logo-trans.png';
  
  double _scale = 1.0;
  bool _showText = false;
  Timer? _pulseTimer;

  @override
  void initState() {
    super.initState();
    _startAnimations();
    _navigateToNext();
  }

  void _startAnimations() {
    // Initial delay for tagline fade-in
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _showText = true);
    });

    // Start pulse animation
    _pulseTimer = Timer.periodic(_pulseDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_scale == 1.0) {
          _scale = 0.9;
        } else if (_scale == 0.9) {
          _scale = 0.95;
        } else {
          _scale = 1.0;
        }
      });
    });
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(_splashDuration);
    if (!mounted) return;

    final sessionService = ref.read(sessionServiceProvider);
    final user = sessionService.getLoggedInUser();

    if (user != null) {
      final gymSlug = sessionService.getStoredGymSlug();
      if (gymSlug != null) {
        context.go('/$gymSlug/${user.normalizedRole}');
        return;
      }
      context.go('/login');
    } else {
      context.go('/welcome');
    }
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    super.dispose();
  }

  String _getTagline(String? role) {
    if (role == null) return "Train Smart. Track Better.";
    final r = role.toLowerCase().replaceAll('role_', '');
    if (r == 'owner') return "Managing your gym...";
    if (r == 'member' || r == 'client') return "Getting your workout ready...";
    return "Train Smart. Track Better.";
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionServiceProvider).getLoggedInUser();
    final tagline = _getTagline(user?.role);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFEEF2), // Very light pink
              Color(0xFFFFF8FA), // Near white
              AppColors.primary,  // #FF5C73
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Subtle glow behind logo
            AnimatedScale(
              scale: _scale * 1.2,
              duration: _pulseDuration,
              curve: Curves.easeInOut,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
            
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulsing Logo
                AnimatedScale(
                  scale: _scale,
                  duration: _pulseDuration,
                  curve: Curves.easeInOut,
                  child: Container(
                    height: 140,
                    width: 140,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      _logoAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, _, __) => const Icon(
                        Icons.fitness_center_rounded,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // App Name
                const Text(
                  'GMMX',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -1,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Tagline Fade-in
                AnimatedOpacity(
                  opacity: _showText ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 1000),
                  child: Text(
                    tagline,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A).withOpacity(0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
