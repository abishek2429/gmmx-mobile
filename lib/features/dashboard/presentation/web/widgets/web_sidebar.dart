import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/providers/theme_provider.dart';

class WebSidebar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const WebSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    
    return Container(
      width: 260,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B0E14) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.05) : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // ─── Logo ───
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: AppTheme.primaryGradient(radius: 10),
                  child: const Center(
                    child: Icon(Icons.fitness_center_rounded, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'GMMX',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ─── Menu Items ───
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _SidebarItem(
                  label: 'Home',
                  icon: Icons.grid_view_rounded,
                  isActive: selectedIndex == 0,
                  onTap: () => onItemSelected(0),
                  isDark: isDark,
                ),
                _SidebarItem(
                  label: 'Members',
                  icon: Icons.people_outline_rounded,
                  isActive: selectedIndex == 1,
                  onTap: () => onItemSelected(1),
                  isDark: isDark,
                ),
                _SidebarItem(
                  label: 'Trainers',
                  icon: Icons.fitness_center_rounded,
                  isActive: selectedIndex == 2,
                  onTap: () => onItemSelected(2),
                  isDark: isDark,
                ),
                _SidebarItem(
                  label: 'Finance',
                  icon: Icons.account_balance_wallet_outlined,
                  isActive: selectedIndex == 3,
                  onTap: () => onItemSelected(3),
                  isDark: isDark,
                ),
                _SidebarItem(
                  label: 'Reports',
                  icon: Icons.bar_chart_rounded,
                  isActive: selectedIndex == 4,
                  onTap: () => onItemSelected(4),
                  isDark: isDark,
                ),
                _SidebarItem(
                  label: 'Broadcast',
                  icon: Icons.campaign_outlined,
                  isActive: selectedIndex == 5,
                  onTap: () => onItemSelected(5),
                  isDark: isDark,
                ),
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'SYSTEM',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _SidebarItem(
                  label: 'Settings',
                  icon: Icons.settings_outlined,
                  isActive: selectedIndex == 6,
                  onTap: () => onItemSelected(6),
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // ─── User Profile Card ───
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.glassCard(radius: 16, isDark: isDark),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: const Text('N', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Nitheesh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Gym Owner', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_vert_rounded, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;

  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.primary.withOpacity(0.1)
                : (isHovered ? (widget.isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02)) : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isActive
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: widget.isActive ? AppColors.primary : (isHovered ? AppColors.primary.withOpacity(0.7) : Colors.grey),
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontWeight: widget.isActive ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                  color: widget.isActive ? AppColors.textPrimaryDark : (isHovered ? AppColors.textPrimaryDark.withOpacity(0.9) : Colors.grey),
                ),
              ),
              if (widget.isActive) ...[
                const Spacer(),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.primary, blurRadius: 4),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
