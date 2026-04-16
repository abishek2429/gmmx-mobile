import 'package:flutter/material.dart';

import '../features/attendance/qr_attendance_page.dart';
import '../features/client/presentation/client_list_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/plans/presentation/plan_list_page.dart';
import '../features/profile/presentation/profile_settings_page.dart';
import 'ui/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<_NavItem> items = const [
    _NavItem(label: 'Dashboard', icon: Icons.grid_view_rounded, page: DashboardPage()),
    _NavItem(label: 'Members', icon: Icons.groups_rounded, page: ClientListPage()),
    _NavItem(label: 'Attendance', icon: Icons.location_on_rounded, page: QrAttendancePage()),
    _NavItem(label: 'Payments', icon: Icons.payments_rounded, page: PlanListPage()),
    _NavItem(label: 'Profile', icon: Icons.person_rounded, page: ProfileSettingsPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: AppTheme.darkBackground)),
          Positioned.fill(child: IndexedStack(index: selectedIndex, children: items.map((e) => e.page).toList())),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C1734).withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000000).withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final active = selectedIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: active
                                ? AppTheme.accent.withValues(alpha: 0.18)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                item.icon,
                                size: 20,
                                color: active ? AppTheme.accent : AppTheme.textMuted,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.label,
                                style: TextStyle(
                                  color: active ? AppTheme.textPrimary : AppTheme.textMuted,
                                  fontSize: 11,
                                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
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
