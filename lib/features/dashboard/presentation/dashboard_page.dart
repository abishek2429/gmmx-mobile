import 'package:flutter/material.dart';

import '../../../core/ui/app_theme.dart';
import '../../../core/ui/components.dart';
import '../../attendance/qr_attendance_page.dart';
import '../../plans/presentation/plan_list_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.darkBackground),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                Spacing.lg, Spacing.md, Spacing.lg, 112),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(context),
                const SizedBox(height: Spacing.lg),
                _buildHero(),
                const SizedBox(height: Spacing.lg),
                _buildPrimaryActions(context),
                const SizedBox(height: Spacing.md),
                _buildStatGrid(),
                const SizedBox(height: Spacing.xl),
                const SectionHeader(title: 'Recent Sessions', action: null),
                const SizedBox(height: Spacing.sm),
                const _SessionRow(
                    title: 'Leg Day',
                    subtitle: 'Yesterday • 52 mins',
                    badge: 'DONE'),
                const SizedBox(height: Spacing.sm),
                const _SessionRow(
                    title: 'Push Workout',
                    subtitle: '2 days ago • 48 mins',
                    badge: 'DONE'),
                const SizedBox(height: Spacing.lg),
                const SectionHeader(title: 'Leaderboard', action: 'VIEW ALL'),
                const SizedBox(height: Spacing.sm),
                _buildLeaderboard(),
                const SizedBox(height: Spacing.lg),
                AppTile(
                  icon: Icons.payments_outlined,
                  title: 'Plan & Payments',
                  subtitle: 'Premium Plus • Renewal in 14 days',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PlanListPage()),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        const Text(
          'GMMX',
          style: TextStyle(
            color: AppTheme.accent,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
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
        const CircleAvatar(
          radius: 14,
          backgroundColor: AppTheme.surfaceSoft,
          child: Text('A',
              style: TextStyle(fontSize: 11, color: AppTheme.textPrimary)),
        )
      ],
    );
  }

  Widget _buildHero() {
    return AppCard(
      radius: 10,
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today',
                  style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(height: Spacing.xs),
                Text(
                  'No session logged yet',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: Spacing.xs),
                Text(
                  'Start your workout to continue your streak.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          AppBadge('STREAK 12'),
        ],
      ),
    );
  }

  Widget _buildPrimaryActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppTile(
            icon: Icons.qr_code_rounded,
            title: 'Check In',
            subtitle: 'Scan QR and enter gym',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QrAttendancePage()),
              );
            },
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: AppTile(
            icon: Icons.history_toggle_off_rounded,
            title: 'Attendance',
            subtitle: '22 sessions this month',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QrAttendancePage()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatGrid() {
    return Column(
      children: const [
        Row(
          children: [
            Expanded(
                child: MetricCard(
                    label: 'STREAK',
                    value: '12',
                    unit: 'days',
                    valueColor: Color(0xFFFF8D2F))),
            SizedBox(width: Spacing.sm),
            Expanded(
                child: MetricCard(
                    label: 'PR DEADLIFT',
                    value: '225 KG',
                    unit: 'personal best',
                    valueColor: Color(0xFFFF3E67))),
          ],
        ),
        SizedBox(height: Spacing.sm),
        Row(
          children: [
            Expanded(
                child: MetricCard(
                    label: 'THIS WEEK',
                    value: '4',
                    unit: 'workouts',
                    valueColor: Color(0xFF10B981))),
            SizedBox(width: Spacing.sm),
            Expanded(
                child: MetricCard(
                    label: 'AVG DURATION',
                    value: '49m',
                    unit: 'per session',
                    valueColor: AppTheme.accentSoft)),
          ],
        ),
      ],
    );
  }

  Widget _buildLeaderboard() {
    return AppCard(
      radius: 10,
      padding: EdgeInsets.zero,
      child: Column(
        children: const [
          _LeaderboardRow(rank: '1', name: 'Marcus T.', score: '14,200 pts'),
          Divider(
            height: 0.5,
            color: Color(0x1A3A4A74),
            indent: Spacing.md,
            endIndent: Spacing.md,
          ),
          _LeaderboardRow(
            rank: '14',
            name: 'You (Arjun)',
            score: '8,450 pts',
            isActive: true,
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;

  const _SessionRow(
      {required this.title, required this.subtitle, required this.badge});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 10,
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md, vertical: Spacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: Spacing.xs),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          AppBadge(badge),
        ],
      ),
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
