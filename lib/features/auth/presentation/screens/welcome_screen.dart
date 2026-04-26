import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: Stack(
        children: [
          // ─── Background Decorative Elements ───
          if (!isDark) ...[
            // Top Right Glow
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.06),
                ),
              ),
            ),
            // Top Left Dots (simplified)
            Positioned(
              top: 60,
              left: 30,
              child: Opacity(
                opacity: 0.2,
                child: Column(
                  children: List.generate(4, (i) => Row(
                    children: List.generate(3, (j) => Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    )),
                  )),
                ),
              ),
            ),
          ],

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // ─── Header Section ───
                  _buildLogoBox(isDark),
                  const SizedBox(height: 12),
                  Text(
                    'Gmmx',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700, // Poppins 700
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Gym Management System',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500, // Inter 500
                      color: isDark ? AppColors.textSecondaryDark : Colors.black45,
                      letterSpacing: 0.2,
                    ),
                  ),

                  // ─── Hero Section (B&W Image) ───
                  Expanded(
                    flex: 5, // Increased flex from 4 to 5
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          foregroundDecoration: BoxDecoration(
                            // Fade out edges and corners
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 0.7, // Reduced radius for a tighter fade, making center look larger
                              colors: [
                                Colors.transparent,
                                (isDark ? AppColors.backgroundDark : Colors.white).withOpacity(0.2),
                                (isDark ? AppColors.backgroundDark : Colors.white).withOpacity(0.6),
                                (isDark ? AppColors.backgroundDark : Colors.white),
                              ],
                              stops: const [0.5, 0.7, 0.9, 1.0],
                            ),
                          ),
                          child: Opacity(
                            opacity: 1.0, // Full opacity for the image asset itself
                            child: Image.asset(
                              'assets/images/welcome_bg.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              errorBuilder: (context, error, stackTrace) => 
                                const Icon(Icons.fitness_center, size: 20, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ─── Motivational Quote ───
                  _buildQuoteSection(isDark),
                  
                  const Spacer(),

                  // ─── Features Row ───
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(child: _buildFeatureItem(Icons.group_outlined, 'Members', 'All in one', isDark)),
                        Expanded(child: _buildFeatureItem(Icons.fitness_center_outlined, 'Progress', 'With ease', isDark)),
                        Expanded(child: _buildFeatureItem(Icons.trending_up_outlined, 'Growth', 'Smarter', isDark)),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ─── Action Button ───
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => context.push('/gym-lookup'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get Started',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600, // Inter 600 for buttons
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── Footer ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Powered by ',
                        style: GoogleFonts.inter(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w400),
                      ),
                      Text(
                        'Gmmx ',
                        style: GoogleFonts.inter(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Technologies',
                        style: GoogleFonts.inter(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoBox(bool isDark) {
    return Image.asset(
      'assets/images/logo-trans.png',
      height: 60, // Sized appropriately for the header
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.fitness_center, size: 40, color: AppColors.primary),
    );
  }

  Widget _buildQuoteSection(bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 30, height: 1, color: Colors.grey.withOpacity(0.2)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.format_quote_rounded, color: AppColors.primary.withOpacity(0.4), size: 20),
            ),
            Container(width: 30, height: 1, color: Colors.grey.withOpacity(0.2)),
          ],
        ),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 22, // Reduced from 28
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
              height: 1.2,
            ),
            children: [
              const TextSpan(text: 'Stay Hard.\nStay '),
              TextSpan(
                text: 'Consistent.',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 9,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
