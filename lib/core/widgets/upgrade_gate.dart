import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../providers/plan_provider.dart';
import '../../models/plan_model.dart';

/// Wraps any widget and shows an upgrade overlay if the feature is locked.
/// Usage:
///   UpgradeGate(
///     feature: GatedFeature.qrAttendance,
///     child: MyWidget(),
///   )
class UpgradeGate extends ConsumerWidget {
  const UpgradeGate({
    super.key,
    required this.feature,
    required this.child,
    this.lockedChild,
  });

  final GatedFeature feature;
  final Widget child;

  /// Optional: custom locked state widget. Defaults to grayed-out child with badge.
  final Widget? lockedChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAccess = ref.watch(canAccessFeatureProvider(feature));
    if (canAccess) return child;

    if (lockedChild != null) return lockedChild!;

    return _LockedFeatureCard(feature: feature);
  }
}

/// A full card shown when a section is locked
class _LockedFeatureCard extends ConsumerWidget {
  const _LockedFeatureCard({required this.feature});
  final GatedFeature feature;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final requiredPlan = feature.requiredPlan;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: requiredPlan.color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: requiredPlan.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.lock_rounded, color: requiredPlan.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.displayName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Available on ${requiredPlan.displayName} plan',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/owner/plans'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: requiredPlan.gradient),
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

/// Small badge to show on top of locked icons/actions
class UpgradeBadge extends StatelessWidget {
  const UpgradeBadge({super.key, required this.plan, required this.child});

  final GymPlan plan;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: plan.gradient),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 1.5,
              ),
            ),
            child: const Icon(Icons.lock_rounded, size: 8, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// A banner strip shown at the top of screens showing plan + usage
class PlanUsageBanner extends ConsumerWidget {
  const PlanUsageBanner({
    super.key,
    required this.currentCount,
    required this.isDark,
  });

  final int currentCount;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(currentPlanProvider);
    final limit = plan.memberLimit;
    final isUnlimited = limit >= 9999;
    final progress = isUnlimited ? 0.0 : (currentCount / limit).clamp(0.0, 1.0);
    final isNearLimit = !isUnlimited && progress > 0.8;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNearLimit
              ? AppColors.warning.withOpacity(0.4)
              : plan.color.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Plan badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: plan.gradient),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  plan.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isUnlimited
                      ? '$currentCount members'
                      : '$currentCount / $limit members',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
              ),
              if (!isUnlimited)
                GestureDetector(
                  onTap: () => context.push('/owner/plans'),
                  child: Row(
                    children: [
                      Text(
                        'Upgrade',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: plan.color,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios_rounded, size: 10, color: plan.color),
                    ],
                  ),
                ),
            ],
          ),
          if (!isUnlimited) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark
                    ? AppColors.secondaryBgDark
                    : AppColors.surfaceElevatedLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isNearLimit ? AppColors.warning : plan.color,
                ),
                minHeight: 5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
