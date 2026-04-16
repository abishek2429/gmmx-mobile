import 'package:flutter/material.dart';

import '../../../core/ui/app_theme.dart';
import '../../../core/ui/components.dart';
import '../../attendance/qr_attendance_page.dart';
import '../../plans/presentation/plan_list_page.dart';

class DashboardTabsPage extends StatefulWidget {
  const DashboardTabsPage({super.key});

  @override
  State<DashboardTabsPage> createState() => _DashboardTabsPageState();
}

class _DashboardTabsPageState extends State<DashboardTabsPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.darkBackground),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              _buildTabBar(),
              Expanded(
                child: TabContent(
                  selectedTab: _selectedTab,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GMMX',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Welcome back, Arjun',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconPill(
            icon: Icons.notifications_none_rounded,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications.')),
              );
            },
          ),
          const SizedBox(width: Spacing.sm),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Overview', 'Performance', 'Workouts', 'Premium'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isActive = _selectedTab == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Padding(
                padding: const EdgeInsets.only(right: Spacing.lg),
                child: Column(
                  children: [
                    Text(
                      tabs[index],
                      style: TextStyle(
                        color: isActive
                            ? AppTheme.textPrimary
                            : AppTheme.textMuted,
                        fontSize: 13,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    if (isActive)
                      Container(
                        height: 2,
                        width: 20,
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class TabContent extends StatelessWidget {
  final int selectedTab;

  const TabContent({super.key, required this.selectedTab});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _getTabContent(context, selectedTab),
    );
  }

  Widget _getTabContent(BuildContext context, int tab) {
    switch (tab) {
      case 0:
        return const _OverviewTab();
      case 1:
        return const _PerformanceTab();
      case 2:
        return const _WorkoutsTab();
      case 3:
        return const _PremiumTab();
      default:
        return const _OverviewTab();
    }
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          Spacing.lg, Spacing.md, Spacing.lg, Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            radius: 10,
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBadge('TODAY'),
                const SizedBox(height: Spacing.md),
                const Text(
                  'No workout logged',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                const Text(
                  'Start your day with a workout',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          SectionHeader(
            title: 'Quick Links',
            action: null,
          ),
          const SizedBox(height: Spacing.md),
          AppTile(
            icon: Icons.qr_code_rounded,
            title: 'Check In',
            subtitle: 'Start your workout',
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const QrAttendancePage()));
            },
          ),
          const SizedBox(height: Spacing.sm),
          AppTile(
            icon: Icons.history_toggle_off_rounded,
            title: 'Attendance',
            subtitle: '22 sessions this month',
            onTap: () {},
          ),
          const SizedBox(height: Spacing.sm),
          AppTile(
            icon: Icons.trending_up_rounded,
            title: 'Progress',
            subtitle: 'View your stats',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _PerformanceTab extends StatelessWidget {
  const _PerformanceTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          Spacing.lg, Spacing.md, Spacing.lg, Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'This Month', action: null),
          const SizedBox(height: Spacing.md),
          Row(
            children: const [
              Expanded(
                child: MetricCard(
                  label: 'WORKOUTS',
                  value: '12',
                  unit: 'sessions',
                  valueColor: Color(0xFFFF8D2F),
                ),
              ),
              SizedBox(width: Spacing.md),
              Expanded(
                child: MetricCard(
                  label: 'STREAK',
                  value: '8',
                  unit: 'days',
                  valueColor: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          AppCard(
            radius: 10,
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personal Records',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.md),
                _PRRow('Deadlift', '225 KG', '+5 KG'),
                const SizedBox(height: Spacing.md),
                _PRRow('Bench Press', '140 KG', '+10 KG'),
                const SizedBox(height: Spacing.md),
                _PRRow('Squat', '195 KG', 'Equal'),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          SectionHeader(title: 'Leaderboard', action: 'View All'),
          const SizedBox(height: Spacing.md),
          AppCard(
            radius: 10,
            padding: EdgeInsets.zero,
            child: Column(
              children: const [
                _LeaderboardRow(
                    rank: '1', name: 'Marcus T.', score: '14,200 pts'),
                Divider(
                    height: 0.5,
                    color: Color(0x1A3A4A74),
                    indent: Spacing.md,
                    endIndent: Spacing.md),
                _LeaderboardRow(
                    rank: '14',
                    name: 'You (Arjun)',
                    score: '8,450 pts',
                    isActive: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _PRRow(String label, String value, String change) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Text(
          change,
          style: TextStyle(
            color: change == 'Equal'
                ? AppTheme.textMuted
                : const Color(0xFF10B981),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _WorkoutsTab extends StatelessWidget {
  const _WorkoutsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          Spacing.lg, Spacing.md, Spacing.lg, Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Recent Workouts', action: 'View All'),
          const SizedBox(height: Spacing.md),
          AppTile(
            icon: Icons.fitness_center_rounded,
            title: 'Leg Day',
            subtitle: 'Yesterday at 6:30 PM • 45 mins',
            onTap: () {},
          ),
          const SizedBox(height: Spacing.sm),
          AppTile(
            icon: Icons.fitness_center_rounded,
            title: 'Chest & Triceps',
            subtitle: '2 days ago • 50 mins',
            onTap: () {},
          ),
          const SizedBox(height: Spacing.sm),
          AppTile(
            icon: Icons.fitness_center_rounded,
            title: 'Back & Biceps',
            subtitle: '3 days ago • 55 mins',
            onTap: () {},
          ),
          const SizedBox(height: Spacing.lg),
          SectionHeader(title: 'Payment History', action: null),
          const SizedBox(height: Spacing.md),
          AppTile(
            icon: Icons.payments_outlined,
            title: 'Premium Membership',
            subtitle: 'Last paid on Sep 20 • ₹5,000',
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PlanListPage()));
            },
          ),
        ],
      ),
    );
  }
}

class _PremiumTab extends StatelessWidget {
  const _PremiumTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          Spacing.lg, Spacing.md, Spacing.lg, Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            radius: 10,
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ELITE ACCESS',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                const Text(
                  'Premium Plus',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Renewal in 14 days',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          value: 0.66,
                          minHeight: 6,
                          backgroundColor: Color(0xFF2A3B63),
                          valueColor: AlwaysStoppedAnimation(AppTheme.accent),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          SectionHeader(title: 'Benefits', action: null),
          const SizedBox(height: Spacing.md),
          AppCard(
            radius: 10,
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              children: [
                _BenefitRow('Unlimited Workouts', true),
                const SizedBox(height: Spacing.md),
                _BenefitRow('Personal Trainer Access', true),
                const SizedBox(height: Spacing.md),
                _BenefitRow('Priority Support', true),
                const SizedBox(height: Spacing.md),
                _BenefitRow('Advanced Analytics', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _BenefitRow(String label, bool included) {
    return Row(
      children: [
        Icon(
          included ? Icons.check_circle : Icons.circle_outlined,
          size: 16,
          color: included ? const Color(0xFF10B981) : AppTheme.textMuted,
        ),
        const SizedBox(width: Spacing.md),
        Text(
          label,
          style: TextStyle(
            color: included ? AppTheme.textPrimary : AppTheme.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final String rank;
  final String name;
  final String score;
  final bool isActive;

  const _LeaderboardRow({
    required this.rank,
    required this.name,
    required this.score,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isActive
          ? AppTheme.accent.withValues(alpha: 0.06)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md, vertical: Spacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              rank,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          CircleAvatar(
            radius: 12,
            backgroundColor: isActive
                ? AppTheme.accent.withValues(alpha: 0.2)
                : AppTheme.surface.withValues(alpha: 0.8),
            child: Text(
              name[0],
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            score,
            style: const TextStyle(
              color: AppTheme.accent,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
