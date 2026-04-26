import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gmmx_mobile/core/theme/app_colors.dart';
import 'package:gmmx_mobile/core/theme/app_theme.dart';
import 'package:gmmx_mobile/core/providers/theme_provider.dart';
import 'package:gmmx_mobile/core/providers/plan_provider.dart';
import 'package:gmmx_mobile/models/plan_model.dart';
import 'package:gmmx_mobile/services/session_service.dart';
import 'package:gmmx_mobile/features/auth/presentation/auth_controller.dart';
import 'package:gmmx_mobile/features/auth/providers/gym_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final prefs = ref.watch(sharedPreferencesProvider);
    final session = SessionService(prefs);
    final user = session.getLoggedInUser();
    final plan = ref.watch(currentPlanProvider);
    final role = user?.normalizedRole ?? 'owner';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header gradient
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(isDark ? 0.25 : 0.12),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryHover],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            (user?.fullName.isNotEmpty ?? false)
                                ? user!.fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.fullName ?? 'User',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.mobile ?? user?.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _roleGradient(role),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _roleLabel(role),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plan card (Owner only)
                      if (role == 'owner') ...[
                        _SectionHeader(title: 'Your Plan', isDark: isDark),
                        _PlanStatusCard(plan: plan, isDark: isDark),
                        const SizedBox(height: 24),
                      ],

                      // Settings section
                      _SectionHeader(title: 'Settings', isDark: isDark),
                      _SettingsCard(
                        isDark: isDark,
                        items: [
                          _SettingsItem(
                            icon: Icons.palette_rounded,
                            label: 'Appearance',
                            trailing: Consumer(builder: (ctx, r, _) {
                              final isDarkMode = r.watch(themeModeProvider) == ThemeMode.dark;
                              return GestureDetector(
                                onTap: () => r.read(themeModeProvider.notifier).toggle(),
                                child: Container(
                                  width: 48,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? AppColors.primary : AppColors.borderLight,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: AnimatedAlign(
                                    duration: const Duration(milliseconds: 200),
                                    alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            onTap: null,
                          ),
                          _SettingsItem(
                            icon: Icons.notifications_rounded,
                            label: 'Notifications',
                            trailing: Icon(Icons.chevron_right_rounded,
                                size: 18,
                                color: isDark ? AppColors.textHintDark : AppColors.textHint),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Notification settings coming soon!')),
                              );
                            },
                          ),
                          _SettingsItem(
                            icon: Icons.lock_rounded,
                            label: 'Privacy & Security',
                            trailing: Icon(Icons.chevron_right_rounded,
                                size: 18,
                                color: isDark ? AppColors.textHintDark : AppColors.textHint),
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.help_outline_rounded,
                            label: 'Help & Support',
                            trailing: Icon(Icons.chevron_right_rounded,
                                size: 18,
                                color: isDark ? AppColors.textHintDark : AppColors.textHint),
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Danger zone
                      _SectionHeader(title: 'Account', isDark: isDark),
                      _SettingsCard(
                        isDark: isDark,
                        items: [
                          _SettingsItem(
                            icon: Icons.logout_rounded,
                            label: 'Logout',
                            labelColor: AppColors.error,
                            iconColor: AppColors.error,
                            trailing: const SizedBox.shrink(),
                            onTap: () {
                              ref.read(authControllerProvider.notifier).logout();
                              context.go('/');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Version
                      Center(
                        child: Text(
                          'GMMX v1.0.0 · Made with ❤️ in India',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textHintDark : AppColors.textHint,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _roleGradient(String role) {
    switch (role) {
      case 'trainer': return [const Color(0xFF1D4ED8), const Color(0xFF3B82F6)];
      case 'client':  return [const Color(0xFF059669), const Color(0xFF10B981)];
      default:        return [AppColors.primary, AppColors.primaryHover]; // owner
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'trainer': return '🏋️ TRAINER';
      case 'client':  return '💪 MEMBER';
      default:        return '👑 GYM OWNER';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.isDark});
  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _PlanStatusCard extends ConsumerWidget {
  const _PlanStatusCard({required this.plan, required this.isDark});
  final GymPlan plan;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: plan.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: plan.color.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${plan.displayName} PLAN',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  plan.memberLimitLabel,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          if (plan != GymPlan.pro)
            GestureDetector(
              onTap: () {
                final gym = ref.read(gymProvider).value;
                final slug = gym?.subdomain ?? 'dashboard';
                context.push('/$slug/owner/plans');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Upgrade',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.isDark, required this.items});
  final bool isDark;
  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              _buildTile(context, e.value),
              if (!isLast) Divider(
                height: 1,
                indent: 56,
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTile(BuildContext context, _SettingsItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: (item.iconColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.icon,
                size: 18,
                color: item.iconColor ?? AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: item.labelColor ??
                      (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                ),
              ),
            ),
            item.trailing,
          ],
        ),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;
  final Color? labelColor;
  final Color? iconColor;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
    this.labelColor,
    this.iconColor,
  });
}
