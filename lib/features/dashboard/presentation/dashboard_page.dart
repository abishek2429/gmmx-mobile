import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gmmx_components.dart';
import '../../attendance/qr_attendance_page.dart';
import '../../plans/presentation/plan_list_page.dart';
import '../../../core/widgets/responsive_layout.dart';
import './web/web_dashboard_shell.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fabController;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);

    return ResponsiveLayout(
      mobile: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnimatedTopBar(context, isDark),
                const SizedBox(height: 24),
                _buildHeroCard(isDark),
                const SizedBox(height: 24),
                _buildPrimaryActions(context, isDark),
                const SizedBox(height: 24),
                _buildStatGrid(isDark),
                const SizedBox(height: 24),
                _buildRecentSessions(isDark),
                const SizedBox(height: 24),
                _buildLeaderboardCard(isDark),
                const SizedBox(height: 24),
                _buildPremiumCard(context, isDark),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 120,
            child: _buildFloatingMenu(context),
          ),
        ],
      ),
      web: _buildWebContent(isDark),
    );
  }

  Widget _buildWebContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPIs Grid
        Row(
          children: [
            Expanded(child: _buildStatItem('Total Members', '128', '+12 this month', Icons.people_rounded)),
            const SizedBox(width: 24),
            Expanded(child: _buildStatItem('Active Trainers', '24', '+3 this month', Icons.fitness_center_rounded)),
            const SizedBox(width: 24),
            Expanded(child: _buildStatItem('Revenue', '₹48,500', '+18% this month', Icons.payments_rounded)),
            const SizedBox(width: 24),
            Expanded(child: _buildStatItem('Growth Rate', '32%', '+5% this month', Icons.trending_up_rounded)),
          ],
        ),
        const SizedBox(height: 32),
        // Charts and other sections will go here
        const Text('Welcome to GMMX Premium Web Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, String change, IconData icon) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard(radius: 20, isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              Text(change, style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// Animated top bar with parallax effect
  Widget _buildAnimatedTopBar(BuildContext context, bool isDark) {
    final parallaxOffset = _scrollOffset * 0.5;

    return Transform.translate(
      offset: Offset(0, parallaxOffset),
      child: Opacity(
        opacity: 1 - (_scrollOffset / 300).clamp(0, 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GMMX',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Welcome back, Arjun',
                  style: TextStyle(
                    color: isDark ? AppColors.textMuted : AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No new notifications')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: AppTheme.glassButton(isDark: isDark),
                    child: Icon(Icons.notifications_rounded,
                        size: 18,
                        color:
                            isDark ? AppColors.textMuted : AppColors.textMuted),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primarySoft],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
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

  /// Hero card with today's status
  Widget _buildHeroCard(bool isDark) {
    return AnimatedBuilder(
      animation: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fabController, curve: Curves.easeOut),
      ),
      builder: (context, child) {
        return GlassCard(
          isDark: isDark,
          radius: 20,
          padding: const EdgeInsets.all(16),
          onTap: null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Status',
                        style: TextStyle(
                          color:
                              isDark ? AppColors.textMuted : AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'No session logged yet',
                        style: TextStyle(
                          color: AppColors.textMain,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.local_fire_department_rounded,
                            size: 14, color: AppColors.primary),
                        SizedBox(width: 2),
                        Text(
                          'STREAK 12',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Start your workout to continue your 12-day streak. You\'re on fire! 🔥',
                style: TextStyle(
                  color: isDark ? AppColors.textMuted : AppColors.textMuted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Primary action buttons with glass effect
  Widget _buildPrimaryActions(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: GlassButton(
            label: 'Check In',
            icon: Icons.qr_code_2_rounded,
            isDark: isDark,
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const QrAttendancePage(),
                  transitionsBuilder: (_, animation, __, child) =>
                      SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GlassButton(
            label: 'Attendance',
            icon: Icons.history_rounded,
            isDark: isDark,
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const QrAttendancePage(),
                  transitionsBuilder: (_, animation, __, child) =>
                      SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Animated metric cards grid
  Widget _buildStatGrid(bool isDark) {
    final metrics = [
      ('STREAK', '12', 'days', const Color(0xFFFF8D2F)),
      ('PR DEADLIFT', '225 KG', 'personal best', AppColors.primary),
      ('THIS WEEK', '4', 'workouts', const Color(0xFF10B981)),
      ('AVG DURATION', '49m', 'per session', AppColors.primarySoft),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedMetricCard(
                label: metrics[0].$1,
                value: metrics[0].$2,
                unit: metrics[0].$3,
                valueColor: metrics[0].$4,
                delayMs: 100,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedMetricCard(
                label: metrics[1].$1,
                value: metrics[1].$2,
                unit: metrics[1].$3,
                valueColor: metrics[1].$4,
                delayMs: 150,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AnimatedMetricCard(
                label: metrics[2].$1,
                value: metrics[2].$2,
                unit: metrics[2].$3,
                valueColor: metrics[2].$4,
                delayMs: 200,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedMetricCard(
                label: metrics[3].$1,
                value: metrics[3].$2,
                unit: metrics[3].$3,
                valueColor: metrics[3].$4,
                delayMs: 250,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Recent sessions with swipe gesture
  Widget _buildRecentSessions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Sessions',
          action: 'VIEW ALL',
          onActionTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening all sessions...')),
            );
          },
        ),
        const SizedBox(height: 8),
        _buildSwipeableSessionRow(
          isDark,
          'Leg Day',
          'Yesterday • 52 mins',
          '💪',
          Colors.blue,
        ),
        const SizedBox(height: 4),
        _buildSwipeableSessionRow(
          isDark,
          'Push Workout',
          '2 days ago • 48 mins',
          '🦾',
          Colors.orange,
        ),
        const SizedBox(height: 4),
        _buildSwipeableSessionRow(
          isDark,
          'Cardio Session',
          '3 days ago • 35 mins',
          '🏃',
          Colors.green,
        ),
      ],
    );
  }

  /// Swipeable session row with animation
  Widget _buildSwipeableSessionRow(
    bool isDark,
    String title,
    String subtitle,
    String emoji,
    Color accentColor,
  ) {
    return GestureDetector(
      onLongPress: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Long pressed: $title'),
            duration: const Duration(milliseconds: 800),
          ),
        );
      },
      child: GlassCard(
        isDark: isDark,
        radius: 12,
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? AppColors.textMuted : AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'DONE',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Leaderboard with animation
  Widget _buildLeaderboardCard(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Top Performers',
          action: 'VIEW ALL',
        ),
        const SizedBox(height: 8),
        GlassCard(
          isDark: isDark,
          radius: 16,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildLeaderboardEntry(
                isDark,
                '🥇',
                'Marcus T.',
                '14,200 pts',
                0,
                isTop: true,
              ),
              const Divider(
                height: 0.5,
                thickness: 1,
              ),
              _buildLeaderboardEntry(
                isDark,
                '🥈',
                'Sarah M.',
                '13,450 pts',
                1,
              ),
              const Divider(
                height: 0.5,
                thickness: 1,
              ),
              _buildLeaderboardEntry(
                isDark,
                '👤',
                'You (Arjun)',
                '8,450 pts',
                14,
                isCurrentUser: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Single leaderboard entry
  Widget _buildLeaderboardEntry(
    bool isDark,
    String medal,
    String name,
    String score,
    int rank, {
    bool isTop = false,
    bool isCurrentUser = false,
  }) {
    return Container(
      color: isCurrentUser
          ? AppColors.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      child: Row(
        children: [
          Text(
            medal,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rank #$rank',
                  style: TextStyle(
                    color: isDark ? AppColors.textMuted : AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            score,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Premium card with CTA
  Widget _buildPremiumCard(BuildContext context, bool isDark) {
    return GlassCard(
      isDark: isDark,
      radius: 16,
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const PlanListPage(),
            transitionsBuilder: (_, animation, __, child) => ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Premium Membership',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Unlock exclusive features',
                    style: TextStyle(
                      color: isDark ? AppColors.textMain : AppColors.textMain,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.star_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const PlanListPage(),
                  transitionsBuilder: (_, animation, __, child) =>
                      SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primarySoft],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Upgrade Now',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Floating action button with menu
  Widget _buildFloatingMenu(BuildContext context) {
    return AnimatedFAB(
      actions: [
        FABAction(
          label: 'New Session',
          icon: Icons.fitness_center_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Starting new session...')),
            );
          },
        ),
        FABAction(
          label: 'Goal',
          icon: Icons.flag_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Setting goals...')),
            );
          },
        ),
        FABAction(
          label: 'Invite',
          icon: Icons.person_add_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Inviting friends...')),
            );
          },
        ),
      ],
    );
  }
}
