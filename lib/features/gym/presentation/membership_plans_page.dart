import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../providers/membership_plan_provider.dart';

class MembershipPlansPage extends ConsumerWidget {
  const MembershipPlansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final plansAsync = ref.watch(membershipPlansProvider);

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
              child: Column(
                children: [
                  _buildHeader(context, isDark),
                  Expanded(
                    child: plansAsync.when(
                      data: (plans) => plans.isEmpty
                          ? _buildEmptyState(isDark)
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: plans.length,
                              itemBuilder: (context, index) {
                                final plan = plans[index];
                                return _buildPlanCard(context, ref, plan, isDark);
                              },
                            ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error: $err')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPlanDialog(context, ref, isDark),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded, 
              color: isDark ? Colors.white : AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
          Text(
            'Membership Plans',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt_rounded, size: 80, color: AppColors.primary.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(
            'No plans created yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your gym membership tiers here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, WidgetRef ref, MembershipPlan plan, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(isDark: isDark, radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showPlanDialog(context, ref, isDark, plan: plan);
                  } else if (value == 'delete') {
                    _confirmDelete(context, ref, plan.id);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${plan.price.toStringAsFixed(0)} • ${plan.durationDays} Days',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          if (plan.description != null && plan.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              plan.description!,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showPlanDialog(BuildContext context, WidgetRef ref, bool isDark, {MembershipPlan? plan}) {
    final nameController = TextEditingController(text: plan?.name);
    final durationController = TextEditingController(text: plan?.durationDays.toString());
    final priceController = TextEditingController(text: plan?.price.toString());
    final descController = TextEditingController(text: plan?.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF101018) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(plan == null ? 'ADD PLAN' : 'EDIT PLAN', style: const TextStyle(fontWeight: FontWeight.w900)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(nameController, 'Plan Name (e.g. Monthly)', isDark),
              const SizedBox(height: 16),
              _buildField(durationController, 'Duration (Days)', isDark, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildField(priceController, 'Price (₹)', isDark, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildField(descController, 'Description', isDark, maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final duration = int.tryParse(durationController.text.trim()) ?? 0;
              final price = double.tryParse(priceController.text.trim()) ?? 0;
              final desc = descController.text.trim();

              if (name.isEmpty || duration <= 0 || price < 0) return;

              try {
                if (plan == null) {
                  await ref.read(membershipPlansProvider.notifier).createPlan(name, duration, price, desc);
                } else {
                  await ref.read(membershipPlansProvider.notifier).updatePlan(plan.id, name, duration, price, desc);
                }
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                // Show error
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, bool isDark, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(16),
      ),
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan?'),
        content: const Text('This will remove this membership tier. Members already assigned will keep their current plan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              await ref.read(membershipPlansProvider.notifier).deletePlan(id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
