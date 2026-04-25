import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';

class WorkoutPlanPage extends ConsumerWidget {
  const WorkoutPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    final days = [
      _WorkoutDay('Monday', 'Push Day (Chest, Shoulders, Triceps)', [
        _Exercise('Bench Press', '4 Sets x 10 Reps', 'Compound'),
        _Exercise('Overhead Press', '3 Sets x 12 Reps', 'Shoulders'),
        _Exercise('Lateral Raises', '4 Sets x 15 Reps', 'Isolation'),
      ], AppColors.primary),
      _WorkoutDay('Tuesday', 'Pull Day (Back, Biceps)', [
        _Exercise('Deadlifts', '3 Sets x 5 Reps', 'Power'),
        _Exercise('Lat Pulldowns', '4 Sets x 12 Reps', 'Hypertrophy'),
        _Exercise('Barbell Curls', '3 Sets x 15 Reps', 'Arms'),
      ], Colors.blue),
      _WorkoutDay('Wednesday', 'Rest Day', [], Colors.grey),
    ];

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
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'MY WORKOUT PLAN',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    centerTitle: true,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildDaySection(days[index], isDark),
                      childCount: days.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySection(_WorkoutDay day, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: day.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                day.name.toUpperCase(),
                style: TextStyle(
                  color: day.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '— ${day.subtitle}',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (day.exercises.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            width: double.infinity,
            decoration: AppTheme.cardDecoration(isDark: isDark, radius: 24),
            child: const Column(
              children: [
                Icon(Icons.hotel_rounded, color: Colors.grey, size: 40),
                SizedBox(height: 12),
                Text('Recovery is part of the process.', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          )
        else
          ...day.exercises.map((e) => _buildExerciseCard(e, isDark)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildExerciseCard(_Exercise exercise, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(isDark: isDark, radius: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.fitness_center_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.sets,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              exercise.type.toUpperCase(),
              style: const TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutDay {
  final String name, subtitle;
  final List<_Exercise> exercises;
  final Color color;
  _WorkoutDay(this.name, this.subtitle, this.exercises, this.color);
}

class _Exercise {
  final String name, sets, type;
  _Exercise(this.name, this.sets, this.type);
}
