import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../auth/providers/gym_provider.dart';

class WebQuickActions extends ConsumerWidget {
  final bool isDark;

  const WebQuickActions({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gym = ref.watch(gymProvider).value;
    final slug = gym?.subdomain ?? 'dashboard';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard(radius: 20, isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildActionItem(
                Icons.person_add_rounded, 
                'Member', 
                AppColors.primary,
                onTap: () => context.push('/$slug/owner/members/add'),
              ),
              _buildActionItem(
                Icons.fitness_center_rounded, 
                'Trainer', 
                const Color(0xFF3B82F6),
                onTap: () => context.push('/$slug/owner/trainers/add'),
              ),
              _buildActionItem(
                Icons.qr_code_scanner_rounded, 
                'Scan', 
                const Color(0xFF10B981),
                onTap: () => context.push('/scanner'),
              ),
              _buildActionItem(Icons.bar_chart_rounded, 'Reports', const Color(0xFFF59E0B)),
              _buildActionItem(Icons.campaign_rounded, 'Broadcast', const Color(0xFF7C3AED)),
              _buildActionItem(Icons.settings_rounded, 'Settings', Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
