import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../client/presentation/client_list_page.dart';
import '../../dashboard/presentation/dashboard_controller.dart';
import '../../auth/providers/gym_provider.dart';

class PaymentsPage extends ConsumerWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final clientsAsync = ref.watch(clientListProvider);
    final statsAsync = ref.watch(ownerStatsProvider);

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
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'FINANCE',
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    centerTitle: true,
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Generating PDF Report...')),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        statsAsync.when(
                          data: (stats) => _buildRevenueOverview(isDark, stats),
                          loading: () => _buildRevenueOverview(isDark, null),
                          error: (_, __) => _buildRevenueOverview(isDark, null),
                        ),
                        const SizedBox(height: 32),
                        clientsAsync.when(
                          data: (clients) => _buildRecentTransactions(context, ref, isDark, clients),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('Error: $e')),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueOverview(bool isDark, OwnerStats? stats) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: AppTheme.cardDecoration(isDark: isDark, radius: 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('THIS MONTH REVENUE', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(stats?.monthlyRevenue ?? '₹0', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.success, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _revenueStat('WEEKLY', stats?.totalWeeklyRevenue ?? '₹0', Colors.orange),
              const SizedBox(width: 20),
              _revenueStat('MEMBERS', stats?.totalMembers ?? '0', AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _revenueStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, WidgetRef ref, bool isDark, List<Client> clients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('MEMBER PAYMENTS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            Text('TOTAL: ${clients.length}', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 20),
        ...clients.map((client) {
          final isExpired = client.expiryDate != null && client.expiryDate!.isBefore(DateTime.now());
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration(isDark: isDark, radius: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isExpired ? AppColors.error.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isExpired ? Icons.priority_high_rounded : Icons.receipt_long_rounded, 
                    color: isExpired ? AppColors.error : AppColors.success, 
                    size: 20
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(client.membershipPlan, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${client.feesPaid.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    if (isExpired)
                      GestureDetector(
                        onTap: () {
                          final gym = ref.read(gymProvider).value;
                          final slug = gym?.subdomain ?? 'dashboard';
                          context.push('/$slug/messages/${client.id}?name=${Uri.encodeComponent(client.name)}');
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('REMIND', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                        ),
                      )
                    else
                      Text(
                        client.expiryDate != null ? 'Exp: ${client.expiryDate!.day}/${client.expiryDate!.month}' : 'No Expiry',
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
