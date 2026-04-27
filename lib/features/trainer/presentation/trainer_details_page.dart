import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/user_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../auth/providers/gym_provider.dart';

class TrainerDetailsPage extends ConsumerWidget {
  const TrainerDetailsPage({
    super.key,
    required this.trainer,
  });

  final UserModel trainer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

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
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.textPrimary, size: 20),
                      onPressed: () => context.pop(),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.more_horiz_rounded, color: isDark ? Colors.white : AppColors.textPrimary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildProfileHeader(isDark),
                          const SizedBox(height: 32),
                          _buildStatsGrid(isDark),
                          const SizedBox(height: 32),
                          _buildContactSection(isDark),
                          const SizedBox(height: 32),
                          _buildActions(isDark, ref, context),
                          const SizedBox(height: 100),
                        ],
                      ),
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

  Widget _buildProfileHeader(bool isDark) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.info, AppColors.info.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.info.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.fitness_center_rounded, size: 48, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Text(
          trainer.fullName,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'PRO TRAINER',
            style: TextStyle(
              color: AppColors.info,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(bool isDark) {
    return Row(
      children: [
        Expanded(child: _statCard('CLIENTS', '12', Icons.people_rounded, isDark)),
        const SizedBox(width: 16),
        Expanded(child: _statCard('RATING', '4.8', Icons.star_rounded, isDark)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(isDark: isDark, radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.info, size: 20),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CONTACT INFO', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        _contactTile(Icons.email_rounded, 'Email', trainer.email, isDark),
        const SizedBox(height: 12),
        _contactTile(Icons.phone_rounded, 'Phone', trainer.phone, isDark),
      ],
    );
  }

  Widget _contactTile(IconData icon, String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(isDark: isDark, radius: 20),
      child: Row(
        children: [
          Icon(icon, color: AppColors.info.withValues(alpha: 0.5), size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w700)),
              Text(value, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(bool isDark, WidgetRef ref, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              final slug = ref.read(gymProvider).value?.subdomain ?? 'dashboard';
              context.push('/$slug/messages/${trainer.id}?name=${Uri.encodeComponent(trainer.fullName)}');
            },
            icon: const Icon(Icons.chat_bubble_rounded, size: 18),
            label: const Text('MESSAGE', style: TextStyle(fontWeight: FontWeight.w900)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              final slug = ref.read(gymProvider).value?.subdomain ?? 'dashboard';
              context.push('/$slug/owner/trainers/edit', extra: trainer);
            },
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('EDIT', style: TextStyle(fontWeight: FontWeight.w900)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}
