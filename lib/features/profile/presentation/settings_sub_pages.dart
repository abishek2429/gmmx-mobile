import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    return _SettingsShell(
      title: 'Notifications',
      isDark: isDark,
      children: [
        _buildToggleTile('Push Notifications', 'Receive alerts on your device', true, isDark),
        _buildToggleTile('Email Notifications', 'Receive updates via email', true, isDark),
        _buildToggleTile('Workout Reminders', 'Get reminded of your sessions', false, isDark),
        _buildToggleTile('Attendance Alerts', 'Alert when member checks in', true, isDark),
      ],
    );
  }

  Widget _buildToggleTile(String title, String subtitle, bool initialValue, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(isDark: isDark, radius: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Switch(
            value: initialValue,
            onChanged: (v) {},
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class PrivacySecurityPage extends ConsumerWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    return _SettingsShell(
      title: 'Privacy & Security',
      isDark: isDark,
      children: [
        _buildActionTile('Change PIN', Icons.lock_outline_rounded, isDark),
        _buildActionTile('Two-Factor Authentication', Icons.security_rounded, isDark),
        _buildActionTile('Data Privacy Policy', Icons.privacy_tip_outlined, isDark),
        _buildActionTile('Logged-in Devices', Icons.devices_rounded, isDark),
      ],
    );
  }

  Widget _buildActionTile(String title, IconData icon, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(isDark: isDark, radius: 20),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}

class HelpSupportPage extends ConsumerWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    return _SettingsShell(
      title: 'Help & Support',
      isDark: isDark,
      children: [
        _buildActionTile('Contact Support', Icons.support_agent_rounded, isDark),
        _buildActionTile('FAQ', Icons.question_answer_outlined, isDark),
        _buildActionTile('Report a Bug', Icons.bug_report_outlined, isDark),
        _buildActionTile('About GMMX', Icons.info_outline_rounded, isDark),
      ],
    );
  }

  Widget _buildActionTile(String title, IconData icon, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(isDark: isDark, radius: 20),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}

class _SettingsShell extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<Widget> children;

  const _SettingsShell({
    required this.title,
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.pageBackground(isDark: isDark),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: AppTheme.foregroundGlow(isDark: isDark),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.textPrimary, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: children,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
