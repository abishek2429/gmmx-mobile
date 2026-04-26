import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'package:gmmx_mobile/core/theme/app_colors.dart';
import 'package:gmmx_mobile/core/providers/theme_provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _features = [
    {
      'title': 'All-in-One Management',
      'desc':
          'Effortlessly manage members, trainers, and staff from a single unified dashboard.',
      'icon': '🏢'
    },
    {
      'title': 'Smart Attendance',
      'desc':
          'Modern QR-based attendance tracking for members and trainers with real-time logs.',
      'icon': '📱'
    },
    {
      'title': 'Financial Insights',
      'desc':
          'Track payments, memberships, and revenue growth with deep analytical reports.',
      'icon': '📈'
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();

    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _features.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutQuint,
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // ─── Background Ambient Glow ───
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(isDark ? 0.08 : 0.05),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                             MediaQuery.of(context).padding.top - 
                             MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // ─── Logo Section ───
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Image.network(
                                'https://api.gmmx.app/logo-gmmx.png',
                                height: 60,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.fitness_center,
                                        size: 40, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'GMMX',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // ─── Carousel Section ───
                      SizedBox(
                        height: 280,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (int page) {
                            setState(() {
                              _currentPage = page;
                            });
                          },
                          itemCount: _features.length,
                          itemBuilder: (context, index) {
                            final feature = _features[index];
                            return AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                double value = 1.0;
                                if (_pageController.position.haveDimensions) {
                                  value = _pageController.page! - index;
                                  value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                                }
                                return Opacity(
                                  opacity: value,
                                  child: Transform.scale(
                                    scale: 0.9 + (value * 0.1),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 40),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            feature['icon']!,
                                            style: const TextStyle(fontSize: 64),
                                          ),
                                          const SizedBox(height: 24),
                                          Text(
                                            feature['title']!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w800,
                                              color: isDark
                                                  ? Colors.white
                                                  : AppColors.textPrimary,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            feature['desc']!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: isDark
                                                  ? AppColors.textSecondaryDark
                                                  : AppColors.textSecondary,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // ─── Dots Indicator ───
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _features.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // ─── Action Buttons ───
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: FButton(
                                onPress: () => context.push('/gym-lookup'),
                                child: const Text('Get Started'),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ─── Footer ───
                      Column(
                        children: [
                          Text(
                            'Powered by Gmmx Technologies',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildDot(isDark),
                              const SizedBox(width: 8),
                              Text(
                                'SaaS Edition 2026',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isDark) {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}
