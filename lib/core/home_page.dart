import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/attendance/qr_attendance_page.dart';
import '../features/client/presentation/client_list_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/plans/presentation/plan_list_page.dart';
import '../features/profile/presentation/profile_settings_page.dart';
import 'providers/theme_provider.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'widgets/gmmx_components.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int selectedIndex = 0;

  final List<_NavItem> items = const [
    _NavItem(
        label: 'Dashboard',
        icon: Icons.grid_view_rounded,
        page: DashboardPage()),
    _NavItem(
        label: 'Members', icon: Icons.groups_rounded, page: ClientListPage()),
    _NavItem(
        label: 'Attendance',
        icon: Icons.location_on_rounded,
        page: QrAttendancePage()),
    _NavItem(
        label: 'Payments', icon: Icons.payments_rounded, page: PlanListPage()),
    _NavItem(
        label: 'Profile',
        icon: Icons.person_rounded,
        page: ProfileSettingsPage()),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF010C2B), Color(0xFF03081F), Color(0xFF00081E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFFFFF5F6), Color(0xFFFFF0F2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(gradient: bgGradient),
          ),
          Positioned.fill(
            child: IndexedStack(
              index: selectedIndex,
              children: items.map((e) => e.page).toList(),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: _buildNavigationBar(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar(bool isDark) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
          horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0C1734).withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ...List.generate(items.length, (index) {
            final item = items[index];
            final isActive = selectedIndex == index;
            return Expanded(
              child: _buildNavButton(item, isActive, index, isDark),
            );
          }),
          const SizedBox(width: 2),
          _buildThemeToggle(isDark),
        ],
      ),
    );
  }

  Widget _buildNavButton(_NavItem item, bool isActive, int index, bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 18,
              color: isActive ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                color: isActive ? AppColors.textMain : AppColors.textMuted,
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(bool isDark) {
    return GestureDetector(
      onTap: () => ref.read(themeModeProvider.notifier).toggle(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: isDark ? AppColors.primary : AppColors.textMain,
          size: 16,
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final Widget page;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.page,
  });
}
