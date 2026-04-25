import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../dashboard_controller.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/plan_provider.dart';
import '../../../../core/widgets/upgrade_gate.dart';
import '../../../../models/plan_model.dart';
import '../../../../services/session_service.dart';
import '../../../auth/presentation/auth_controller.dart';

class OwnerDashboard extends ConsumerStatefulWidget {
  const OwnerDashboard({super.key});

  @override
  ConsumerState<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends ConsumerState<OwnerDashboard>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final prefs = ref.watch(sharedPreferencesProvider);
    final session = SessionService(prefs);
    final user = session.getLoggedInUser();
    final statsAsync = ref.watch(ownerStatsProvider);
    final plan = ref.watch(currentPlanProvider);
    final canAddTrainers = ref.watch(canAccessFeatureProvider(GatedFeature.addTrainers));

    return Scaffold(
      body: Container(
        decoration: AppTheme.pageBackground(isDark: isDark),
        child: Stack(
          children: [
            // Background Glow
            Positioned.fill(
              child: DecoratedBox(
                decoration: AppTheme.foregroundGlow(isDark: isDark),
              ),
            ),
            SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  // ignore: unused_result
                  ref.refresh(ownerStatsProvider);
                },
                color: AppColors.primary,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: _buildHeader(isDark, user?.fullName ?? 'Owner'),
                      ),
                    ),

                    // Plan usage banner
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: statsAsync.when(
                          data: (stats) => PlanUsageBanner(
                            currentCount: int.tryParse(stats?.totalMembers ?? '0') ?? 0,
                            isDark: isDark,
                          ),
                          loading: () => PlanUsageBanner(currentCount: 0, isDark: isDark),
                          error: (_, __) => PlanUsageBanner(currentCount: 0, isDark: isDark),
                        ),
                      ),
                    ),

                    // Stats grid
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                        child: statsAsync.when(
                          data: (stats) => _buildStatsGrid(isDark, stats, plan),
                          loading: () => _buildStatsGrid(isDark, null, plan),
                          error: (_, __) => _buildStatsGrid(isDark, null, plan),
                        ),
                      ),
                    ),

                    // Revenue chart
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                        child: _buildRevenueChart(isDark),
                      ),
                    ),

                    // Quick actions
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                        child: _buildQuickActions(isDark, plan, canAddTrainers),
                      ),
                    ),

                    // Recent activity
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 32, 20, 100),
                        child: _buildRecentActivity(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, String name) {
    return Row(
      children: [
        // Avatar with Glow
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'O',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GOOD ${_getGreeting().toUpperCase()} 👋',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        // Dark mode toggle
        GestureDetector(
          onTap: () => ref.read(themeModeProvider.notifier).toggle(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: AppTheme.glassButton(isDark: isDark),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(bool isDark, OwnerStats? realStats, GymPlan plan) {
    final canSeeRevenue = plan.isAtLeast(GymPlan.starter);
    
    final stats = [
      _StatData(
        'Total Members',
        realStats?.totalMembers ?? '0',
        Icons.people_rounded,
        AppColors.primary,
        true,
      ),
      _StatData(
        'Active Trainers',
        realStats?.activeTrainers ?? '0',
        Icons.fitness_center_rounded,
        AppColors.info,
        true,
      ),
      _StatData(
        'Monthly Revenue',
        canSeeRevenue ? (realStats?.monthlyRevenue ?? '₹0') : '🔒',
        Icons.payments_rounded,
        AppColors.success,
        canSeeRevenue,
      ),
      _StatData(
        'New This Month',
        canSeeRevenue ? (realStats?.newMembersThisMonth ?? '0') : '🔒',
        Icons.trending_up_rounded,
        AppColors.warning,
        canSeeRevenue,
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard(stats[0], isDark, 0)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard(stats[1], isDark, 1)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard(stats[2], isDark, 2)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard(stats[3], isDark, 3)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(_StatData data, bool isDark, int index) {
    final delay = index * 0.12;
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final progress = ((_staggerController.value - delay) / 0.4).clamp(0.0, 1.0);
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - progress)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: !data.isAccessible
            ? () => context.push('/owner/plans')
            : null,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration(isDark: isDark, radius: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: data.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(data.icon, color: data.color, size: 20),
                  ),
                  if (!data.isAccessible)
                    Icon(Icons.lock_rounded, size: 14, color: AppColors.planStarter),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                data.value,
                style: TextStyle(
                  fontSize: data.isAccessible ? 24 : 18,
                  fontWeight: FontWeight.w900,
                  color: data.isAccessible
                      ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
                      : (isDark ? AppColors.textHintDark : AppColors.textHint),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.isAccessible ? data.label : 'Upgrade to view',
                style: TextStyle(
                  fontSize: 11,
                  color: data.isAccessible
                      ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
                      : AppColors.planStarter,
                  fontWeight: data.isAccessible ? FontWeight.w700 : FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueChart(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WEEKLY REVENUE',
                    style: TextStyle(
                      color: Colors.white70, 
                      fontSize: 10, 
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '₹4,20,000',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('+12%', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3), FlSpot(1, 1.5), FlSpot(2, 5),
                      FlSpot(3, 2.5), FlSpot(4, 4), FlSpot(5, 3), FlSpot(6, 4.5),
                    ],
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.white.withValues(alpha: 0.15),
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

  Widget _buildQuickActions(bool isDark, GymPlan plan, bool canAddTrainers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.person_add_alt_1_rounded,
                label: 'Member',
                color: AppColors.primary,
                isDark: isDark,
                onTap: () => context.push('/owner/members/add'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: canAddTrainers
                  ? _buildActionCard(
                      icon: Icons.fitness_center_rounded,
                      label: 'Trainer',
                      color: AppColors.info,
                      isDark: isDark,
                      onTap: () => context.push('/owner/trainers/add'),
                    )
                  : _buildLockedActionCard(
                      icon: Icons.fitness_center_rounded,
                      label: 'Trainer',
                      requiredPlan: GymPlan.starter,
                      isDark: isDark,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Scan',
                color: AppColors.success,
                isDark: isDark,
                onTap: () => context.push('/scanner'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.analytics_rounded,
                label: 'Reports',
                color: Colors.orange,
                isDark: isDark,
                onTap: () => _showReportsDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.chat_bubble_rounded,
                label: 'Broadcast',
                color: Colors.purple,
                isDark: isDark,
                onTap: () => _showBroadcastDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: AppTheme.cardDecoration(isDark: isDark, radius: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedActionCard({
    required IconData icon,
    required String label,
    required GymPlan requiredPlan,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => context.push('/owner/plans'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: AppTheme.cardDecoration(isDark: isDark, radius: 24).copyWith(
          border: Border.all(
            color: requiredPlan.color.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: requiredPlan.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: requiredPlan.color.withValues(alpha: 0.5), size: 24),
                ),
                Positioned(
                  top: -4, right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: requiredPlan.gradient),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        width: 2,
                      ),
                    ),
                    child: const Icon(Icons.lock_rounded, size: 10, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textHintDark : AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(bool isDark) {
    final activities = [
      _Activity('New Member Joined', 'Rahul Sharma • Platinum Plan', Icons.person_add_rounded, '2m ago'),
      _Activity('Payment Received', '₹5,000 from Priya Singh', Icons.payments_rounded, '15m ago'),
      _Activity('Trainer Added', 'Mike Coach joined the team', Icons.fitness_center_rounded, '1h ago'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            Text(
              'VIEW ALL',
              style: TextStyle(
                fontSize: 11, 
                fontWeight: FontWeight.w900, 
                color: AppColors.primary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...activities.map((a) => _buildActivityTile(a, isDark)),
      ],
    );
  }

  Widget _buildActivityTile(_Activity activity, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(isDark: isDark, radius: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(activity.icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity.time,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textHintDark : AppColors.textHint,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _showReportsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: ref.watch(themeModeProvider) == ThemeMode.dark ? const Color(0xFF080810) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('DOWNLOAD REPORTS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
            const SizedBox(height: 24),
            _reportOption('Monthly Revenue Report', Icons.picture_as_pdf_rounded, Colors.red),
            _reportOption('Member Attendance Log', Icons.table_chart_rounded, Colors.green),
            _reportOption('Trainer Performance', Icons.analytics_rounded, Colors.blue),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _reportOption(String title, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.download_rounded, size: 20),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating report...')));
      },
    );
  }

  void _showBroadcastDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('BROADCAST MESSAGE'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Enter message to all members...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Broadcasting via WhatsApp...')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('SEND', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

class _StatData {
  final String label, value;
  final IconData icon;
  final Color color;
  final bool isAccessible;
  _StatData(this.label, this.value, this.icon, this.color, this.isAccessible);
}

class _Activity {
  final String title, subtitle, time;
  final IconData icon;
  _Activity(this.title, this.subtitle, this.icon, this.time);
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Icon(icon, size: 19, color: color),
      ),
    );
  }
}
