import 'package:flutter/material.dart';

import '../features/attendance/qr_attendance_page.dart';
import '../features/client/presentation/client_list_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/plans/presentation/plan_list_page.dart';
import '../features/profile/presentation/profile_settings_page.dart';
import 'ui/app_theme.dart';
import 'ui/components.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(gradient: AppTheme.darkBackground),
          ),
          Positioned.fill(
            child: IndexedStack(
              index: selectedIndex,
              children: items.map((e) => e.page).toList(),
            ),
          ),
          Positioned(
            left: Spacing.lg,
            right: Spacing.lg,
            bottom: Spacing.lg,
            child: SafeArea(
              top: false,
              child: _buildNavigationBar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1734).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.06), width: 0.5),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = selectedIndex == index;
          return Expanded(
            child: _buildNavButton(item, isActive, index),
          );
        }),
      ),
    );
  }

  Widget _buildNavButton(_NavItem item, bool isActive, int index) {
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: Spacing.xs),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.accent.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 18,
              color: isActive ? AppTheme.accent : AppTheme.textMuted,
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              item.label,
              style: TextStyle(
                color: isActive ? AppTheme.textPrimary : AppTheme.textMuted,
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
