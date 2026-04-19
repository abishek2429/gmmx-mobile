import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AttendanceMarkingPage extends StatelessWidget {
  const AttendanceMarkingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('MORNING SESSION', style: TextStyle(color: AppColors.textMuted, letterSpacing: 1.1, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFEFD9DF), borderRadius: BorderRadius.circular(999)),
                    child: const Text('CARRYING THE LOGS', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Welcome back,\n', style: TextStyle(color: AppColors.textMain, fontSize: 42, fontWeight: FontWeight.w800, height: 0.98)),
                    TextSpan(text: 'Aditya', style: TextStyle(color: AppColors.primary, fontSize: 52, fontWeight: FontWeight.w900, height: 0.95)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '"They don\'t know me son!" - Stay hard.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 18),
              _statusCard(),
              const SizedBox(height: 18),
              _radarCard(),
              const SizedBox(height: 24),
              _checkInButton(),
              const SizedBox(height: 22),
              _recentLogsCard(),
              const SizedBox(height: 22),
              Center(
                child: Column(
                  children: [
                    const Text('Struggling to sync?', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Forgot phone?', style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.badge_outlined),
                      label: const Text('ADMIN: MANUAL OVERRIDE', style: TextStyle(fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF68606B),
                        side: const BorderSide(color: Color(0xFFB5ABB0), style: BorderStyle.solid),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _forecastCard(),
              const SizedBox(height: 14),
              Row(
                children: const [
                  Expanded(child: _LightInfoCard(label: 'PEAK HOURS', value: '06:00 AM -\n09:00 AM', tint: AppColors.surfaceLight, icon: Icons.schedule_rounded)),
                  SizedBox(width: 12),
                  Expanded(child: _LightInfoCard(label: 'LIVE LOAD', value: '24 Members\nIn-Studio', tint: Color(0xFFD7DEEC), icon: Icons.groups_2_outlined)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        const Text('GMMX', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 34, letterSpacing: -0.8)),
        const Spacer(),
        IconButton(onPressed: () {}, icon: const Icon(Icons.nightlight_round, color: Color(0xFF6B7690))),
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF6B7690))),
      ],
    );
  }

  Widget _statusCard() {
    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFF0DFDD),
            child: Icon(Icons.location_off_rounded, color: Color(0xFFC1472E)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Current Status\n', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                  TextSpan(text: 'Not in gym area', style: TextStyle(color: AppColors.textMain, fontSize: 17, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          Text('Session\n--:--:--', textAlign: TextAlign.end, style: TextStyle(color: Color(0xFFB4B5BA), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _radarCard() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(colors: [Color(0xFF7B93A3), Color(0xFF70899A)]),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: Center(
              child: Icon(Icons.radar_rounded, size: 160, color: Color(0x44FFFFFF)),
            ),
          ),
          Positioned(
            right: 22,
            top: 48,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
              child: const Text('TITAN GYM HQ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 11)),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFE7E9EC), borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.my_location_rounded, color: Color(0xFF6B5C63)),
                  SizedBox(width: 10),
                  Text('Approx. 240m from the entry zone', style: TextStyle(color: Color(0xFF6B5C63), fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _checkInButton() {
    return Center(
      child: Container(
        width: 258,
        height: 258,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [Color(0xFFF194A3), Color(0xFFF28EA0)]),
          boxShadow: [
            BoxShadow(color: const Color(0xFFD85E78).withValues(alpha: 0.25), blurRadius: 18),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint_rounded, size: 64, color: Color(0xFF2F3139)),
            SizedBox(height: 12),
            Text('Check In', style: TextStyle(color: Color(0xFF2F3139), fontSize: 44, fontWeight: FontWeight.w800, letterSpacing: -0.8)),
            Text('TITAN GYM HQ', style: TextStyle(color: Color(0xFF5E5F66), fontWeight: FontWeight.w700, letterSpacing: 1.1)),
          ],
        ),
      ),
    );
  }

  Widget _recentLogsCard() {
    const dotGreen = Color(0xFF23B969);
    const dotRed = Color(0xFFD14367);
    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.all(16),
      child: const Column(
        children: [
          Row(
            children: [
              Text('Recent Logs', style: TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.w700)),
              Spacer(),
              Text('LAST 3 DAYS', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
          SizedBox(height: 12),
          _LogRow(title: 'Yesterday', time: '06:12 AM', duration: '1h 45m', color: dotGreen),
          _LogRow(title: 'Mon, 12 Oct', time: '05:58 AM', duration: '2h 10m', color: dotGreen),
          _LogRow(title: 'Sun, 11 Oct', time: 'Missed Session', duration: '', color: dotRed),
        ],
      ),
    );
  }

  Widget _forecastCard() {
    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('Peak Hour Forecast', style: TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.w700)),
              Spacer(),
              Icon(Icons.north_east_rounded, color: Color(0xFF6B5F64)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _bar(0.40, const Color(0xFFCFA2B0)),
                _bar(0.75, const Color(0xFFC34D6C)),
                _bar(0.80, const Color(0xFFB81E4B)),
                _bar(0.68, const Color(0xFFC34D6C)),
                _bar(0.30, const Color(0xFFCFA2B0)),
                _bar(0.24, const Color(0xFFD8DCE6)),
                _bar(0.55, const Color(0xFFD19AA9)),
                _bar(0.70, const Color(0xFFC34D6C)),
                _bar(0.40, const Color(0xFFCFA2B0)),
                _bar(0.16, const Color(0xFFD8DCE6)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('04 AM', style: TextStyle(color: Color(0xFF615B61), fontSize: 12, fontWeight: FontWeight.w700)),
              Text('08 AM', style: TextStyle(color: Color(0xFF615B61), fontSize: 12, fontWeight: FontWeight.w700)),
              Text('12 PM', style: TextStyle(color: Color(0xFF615B61), fontSize: 12, fontWeight: FontWeight.w700)),
              Text('04 PM', style: TextStyle(color: Color(0xFF615B61), fontSize: 12, fontWeight: FontWeight.w700)),
              Text('08 PM', style: TextStyle(color: Color(0xFF615B61), fontSize: 12, fontWeight: FontWeight.w700)),
              Text('11 PM', style: TextStyle(color: Color(0xFF615B61), fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bar(double ratio, Color color) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: ratio,
          widthFactor: 0.86,
          child: Container(
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
          ),
        ),
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  final String title;
  final String time;
  final String duration;
  final Color color;

  const _LogRow({
    required this.title,
    required this.time,
    required this.duration,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(color: AppColors.textMain, fontSize: 15))),
          Text(time, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          if (duration.isNotEmpty) ...[
            const Text(' • ', style: TextStyle(color: AppColors.textMuted)),
            Text(duration, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          ],
        ],
      ),
    );
  }
}

class _LightInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color tint;
  final IconData icon;

  const _LightInfoCard({
    required this.label,
    required this.value,
    required this.tint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(26)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF6F6870), size: 26),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Color(0xFF88838A), fontWeight: FontWeight.w700, letterSpacing: 1.0)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Color(0xFF4A5060), fontSize: 20, fontWeight: FontWeight.w700, height: 1.05)),
        ],
      ),
    );
  }
}
