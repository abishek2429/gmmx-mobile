import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import 'trainer_creation_page.dart';
import 'trainer_details_page.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../models/user_model.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../auth/providers/gym_provider.dart';

final trainerListProvider = FutureProvider<List<UserModel>>((ref) async {
  final dio = ref.read(dioClientProvider);
  final response = await dio.get('/api/trainers');
  
  final List<dynamic> content = response.data['data']['content'] ?? [];
  return content.map((json) => UserModel.fromJson(json)).toList();
});

class TrainerListPage extends ConsumerWidget {
  const TrainerListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final trainersAsync = ref.watch(trainerListProvider);
    final gym = ref.watch(gymProvider).value;
    final slug = gym?.subdomain ?? 'dashboard';

    return ResponsiveLayout(
      mobile: Scaffold(
        body: Container(
          decoration: AppTheme.pageBackground(isDark: isDark),
          child: Stack(
            children: [
              // Background Glow
              Positioned.fill(
                child: DecoratedBox(
                  decoration: AppTheme.foregroundGlow(isDark: isDark),
                ),
              ),
              SafeArea(
                child: _buildMainContent(context, ref, isDark, trainersAsync, slug, isMobile: true),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/$slug/owner/trainers/add'),
          backgroundColor: AppColors.primary,
          elevation: 8,
          label: const Text(
            'Add Trainer',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          icon: const Icon(
            Icons.add_rounded,
            color: Colors.white,
          ),
        ),
      ),
      web: _buildMainContent(context, ref, isDark, trainersAsync, slug, isMobile: false),
    );
  }

  Widget _buildMainContent(
    BuildContext context, 
    WidgetRef ref, 
    bool isDark, 
    AsyncValue<List<UserModel>> trainersAsync,
    String slug,
    {required bool isMobile}
  ) {
    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.all(isMobile ? 20 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Team Trainers',
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          fontSize: isMobile ? 28 : 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your training staff',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (!isMobile)
                        FButton(
                          onPress: () => context.push('/$slug/owner/trainers/add'),
                          prefix: const Icon(Icons.add_rounded),
                          child: const Text('Add New Trainer'),
                        ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: AppTheme.glassButton(isDark: isDark),
                          child: const Icon(
                            Icons.filter_list_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search trainers...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: trainersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, s) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: $e', 
                    style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () => ref.refresh(trainerListProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (trainers) => Column(
              children: [
                // Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Total',
                          value: '${trainers.length}',
                          icon: Icons.person_outlined,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'Active',
                          value: '${trainers.where((t) => t.isActive).length}',
                          icon: Icons.check_circle_outline_rounded,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'Workload',
                          value: '-',
                          icon: Icons.assignment_ind_outlined,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Trainer List
                Expanded(
                  child: trainers.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(32),
                                margin: const EdgeInsets.all(24),
                                decoration: AppTheme.cardDecoration(isDark: isDark),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.fitness_center_rounded,
                                      size: 64,
                                      color: isDark ? AppColors.textHintDark : AppColors.textHint,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'No trainers yet',
                                      style: TextStyle(
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Onboard your first trainer to get started',
                                      style: TextStyle(
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.refresh(trainerListProvider.future),
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: trainers.length,
                          itemBuilder: (context, index) {
                            final trainer = trainers[index];
                            return TrainerCard(
                              trainer: trainer,
                              isDark: isDark,
                              onTap: () {
                                 Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => TrainerDetailsPage(
                                      trainer: trainer,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.cardDecoration(isDark: isDark, radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(
                icon,
                color: AppColors.primary,
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class TrainerCard extends StatelessWidget {
  const TrainerCard({
    super.key,
    required this.trainer,
    required this.onTap,
    required this.isDark,
  });

  final UserModel trainer;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bool isActive = trainer.isActive;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration(isDark: isDark, radius: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainer.fullName,
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Expert Trainer',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.success.withOpacity(0.12)
                        : AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: isActive
                          ? (isDark ? AppColors.successDark : AppColors.success)
                          : (isDark ? AppColors.errorDark : AppColors.error),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Email',
                    value: trainer.email,
                    icon: Icons.email_outlined,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(
                    label: 'Phone',
                    value: trainer.phone,
                    icon: Icons.phone_outlined,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.secondaryBgDark : AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
