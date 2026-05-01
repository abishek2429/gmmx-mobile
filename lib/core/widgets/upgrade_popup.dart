import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../models/plan_model.dart';
import 'package:forui/forui.dart';

class UpgradePopup extends StatelessWidget {
  const UpgradePopup({super.key, this.requiredPlan});

  final GymPlan? requiredPlan;

  static Future<void> show(BuildContext context, {GymPlan? requiredPlan}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpgradePopup(requiredPlan: requiredPlan),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plansToShow = [GymPlan.starter, GymPlan.growth, GymPlan.pro];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.secondaryBgDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upgrade Plan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unlock premium features for your gym',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: plansToShow.length,
              itemBuilder: (context, index) {
                final plan = plansToShow[index];
                final isRecommended = plan == GymPlan.growth;
                final isRequired = requiredPlan != null && plan.index >= requiredPlan!.index;

                return _PlanCard(
                  plan: plan,
                  isRecommended: isRecommended,
                  isDark: isDark,
                  isRequired: isRequired,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Taxes may apply. Billing managed via GMMX Dashboard.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isRecommended,
    required this.isDark,
    required this.isRequired,
  });

  final GymPlan plan;
  final bool isRecommended;
  final bool isDark;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isRecommended 
              ? plan.color 
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRecommended)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: plan.color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: const Text(
                'RECOMMENDED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
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
                          plan.displayName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: plan.color,
                          ),
                        ),
                        Text(
                          plan.tagline,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          plan.price,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4, left: 2),
                          child: Text(
                            plan.priceLabel,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                ...plan.features.take(4).map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        f.included ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        size: 16,
                        color: f.included ? AppColors.success : Colors.grey.withOpacity(0.3),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        f.label,
                        style: TextStyle(
                          fontSize: 13,
                          color: f.included 
                              ? (isDark ? Colors.white : AppColors.textPrimary)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FButton(
                    onPress: () {
                      // Still need to point to web for actual payment, but now we've shown value
                      // Alternatively, we could just show a "Contact Support" or "Learn More"
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Plan selection logic here')),
                      );
                    },
                    variant: isRecommended ? null : FButtonVariant.outline,
                    child: Text('Select ${plan.displayName}'),
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
