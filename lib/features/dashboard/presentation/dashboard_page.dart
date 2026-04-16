import 'package:flutter/material.dart';

import '../../../core/ui/app_theme.dart';
import '../../attendance/qr_attendance_page.dart';
import '../../plans/presentation/plan_list_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final compact = screenWidth < 420;
    final heroTitleSize = compact ? 32.0 : 46.0;
    final heroSubtitleSize = compact ? 16.0 : 22.0;
    final pitTitleSize = compact ? 44.0 : 52.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.darkBackground),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(context),
                const SizedBox(height: 20),
                Text(
                  'Stay Hard, Arjun.',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: heroTitleSize,
                    fontWeight: FontWeight.w800,
                    height: 0.98,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No excuses. Just results.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: heroSubtitleSize, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                _challengeCard(context),
                const SizedBox(height: 20),
                _pitButton(context, pitTitleSize),
                const SizedBox(height: 20),
                _premiumCard(),
                const SizedBox(height: 14),
                Row(
                  children: const [
                    Expanded(child: _MiniMetric(title: 'STREAK', value: '12', unit: 'DAYS ALIVE', glow: Color(0xFFFF8D2F))),
                    SizedBox(width: 12),
                    Expanded(child: _MiniMetric(title: 'PERSONAL BEST', value: '225 KG', unit: 'DEADLIFT', glow: Color(0xFFFF3E67))),
                  ],
                ),
                const SizedBox(height: 24),
                _sectionHeader('LEADERBOARD', 'VIEW ALL'),
                const SizedBox(height: 10),
                _leaderboard(),
                const SizedBox(height: 18),
                _historyTile(
                  context,
                  Icons.history_toggle_off_rounded,
                  'Attendance History',
                  '22 sessions this month',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const QrAttendancePage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _historyTile(
                  context,
                  Icons.payments_outlined,
                  'Payment History',
                  'Last paid on Sep 20',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PlanListPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _liveTraffic(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        const Text(
          'GMMX',
          style: TextStyle(color: AppTheme.accent, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -0.8),
        ),
        const Spacer(),
        _iconPill(
          Icons.light_mode_outlined,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Theme controls coming soon.')),
            );
          },
        ),
        const SizedBox(width: 10),
        _iconPill(
          Icons.notifications_none_rounded,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No new notifications.')),
            );
          },
        ),
        const SizedBox(width: 10),
        const CircleAvatar(radius: 20, backgroundColor: Color(0xFF2D3A61), child: Text('A', style: TextStyle(fontWeight: FontWeight.w700))),
      ],
    );
  }

  Widget _iconPill(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppTheme.textMuted, size: 20),
        ),
      ),
    );
  }

  Widget _challengeCard(BuildContext context) {
    return Container(
      decoration: AppTheme.darkCard(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(999)),
            child: const Text('DAILY CHALLENGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 12),
          const Text(
            '"WHO\'S GONNA CARRY\nTHE BOATS AND THE LOGS?"',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.w900, height: 1.0),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('DAVID GOGGINS', style: TextStyle(color: AppTheme.textMuted, fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Challenge marked complete.')),
                  );
                },
                child: const Text('COMPLETE CHALLENGE', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pitButton(BuildContext context, double titleSize) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const QrAttendancePage()),
          );
        },
        child: Ink(
          height: 108,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.accentSoft]),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(color: AppTheme.accent.withValues(alpha: 0.45), blurRadius: 24, spreadRadius: 1),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_rounded, size: 30, color: Colors.white),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ENTER THE PIT', style: TextStyle(color: Colors.white, fontSize: titleSize, fontWeight: FontWeight.w800, height: 0.95)),
                  const Text('SCAN QR TO BEGIN WORKOUT', style: TextStyle(color: Color(0xFFFFD5DE), fontWeight: FontWeight.w700, letterSpacing: 0.6)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _premiumCard() {
    return Container(
      decoration: AppTheme.darkCard(),
      padding: const EdgeInsets.all(18),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ELITE ACCESS', style: TextStyle(color: AppTheme.textMuted, fontSize: 12, letterSpacing: 1.0, fontWeight: FontWeight.w700)),
          SizedBox(height: 6),
          Text('Premium Plus', style: TextStyle(color: AppTheme.textPrimary, fontSize: 36, fontWeight: FontWeight.w700)),
          SizedBox(height: 10),
          Row(
            children: [
              Text('Renewal in 14 days', style: TextStyle(color: AppTheme.textMuted, fontSize: 18)),
              SizedBox(width: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(99)),
                  child: LinearProgressIndicator(value: 0.66, minHeight: 8, backgroundColor: Color(0xFF2A3B63), valueColor: AlwaysStoppedAnimation(AppTheme.accent)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String action) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 38, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
        const Spacer(),
        Text(action, style: const TextStyle(color: AppTheme.accent, fontSize: 15, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _leaderboard() {
    return Container(
      decoration: AppTheme.darkCard(),
      child: Column(
        children: const [
          _BoardRow(rank: '1', name: 'Marcus T.', score: '14,200 pts'),
          Divider(height: 1, color: Color(0x223A4A74)),
          _BoardRow(rank: '14', name: 'You (Arjun)', score: '8,450 pts', active: true),
        ],
      ),
    );
  }

  Widget _historyTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: AppTheme.darkCard(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
                child: Icon(icon, color: AppTheme.textMuted),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.w700)),
                    Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 19)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _liveTraffic() {
    return Container(
      decoration: AppTheme.darkCard(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: const Row(
        children: [
          Icon(Icons.circle, color: Color(0xFF35D07F), size: 14),
          SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'LIVE TRAFFIC\n', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                  TextSpan(text: 'Currently ', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20)),
                  TextSpan(text: 'Moderate', style: TextStyle(color: AppTheme.accent, fontSize: 20, fontWeight: FontWeight.w700)),
                  TextSpan(text: ' - 12 people active', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color glow;

  const _MiniMetric({
    required this.title,
    required this.value,
    required this.unit,
    required this.glow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.darkCard(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: glow, fontSize: 20, fontWeight: FontWeight.w800)),
          Text(unit, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _BoardRow extends StatelessWidget {
  final String rank;
  final String name;
  final String score;
  final bool active;

  const _BoardRow({
    required this.rank,
    required this.name,
    required this.score,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: active ? AppTheme.accent.withValues(alpha: 0.09) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(rank, style: const TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 14,
            backgroundColor: active ? AppTheme.accent.withValues(alpha: 0.3) : const Color(0xFF273A62),
            child: Text(name[0], style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
          ),
          Text(score, style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
