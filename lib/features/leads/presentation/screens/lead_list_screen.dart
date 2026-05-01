import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../lead_provider.dart';
import '../../../auth/providers/gym_provider.dart';

class LeadListScreen extends ConsumerWidget {
  const LeadListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final leadsAsync = ref.watch(leadListProvider);
    final gym = ref.watch(gymProvider).value;
    final slug = gym?.subdomain ?? 'dashboard';

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
                    child: leadsAsync.when(
                      data: (leads) => leads.isEmpty
                          ? _buildEmptyState(isDark)
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: leads.length,
                              itemBuilder: (context, index) {
                                final lead = leads[index];
                                return _buildLeadCard(context, ref, lead, isDark);
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
        onPressed: () => context.push('/$slug/owner/leads/add'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add Lead', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            'Lead Management',
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
          Icon(Icons.person_search_rounded, size: 80, color: AppColors.primary.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(
            'No leads found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track your potential gym members here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadCard(BuildContext context, WidgetRef ref, Lead lead, bool isDark) {
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
                lead.fullName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              _buildStatusBadge(lead.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${lead.mobile} • ${lead.source ?? 'Unknown Source'}',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          if (lead.notes != null && lead.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              lead.notes!,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Interest: ${lead.interestLevel ?? 'Normal'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              Text(
                '${lead.createdAt.day}/${lead.createdAt.month}/${lead.createdAt.year}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showStatusDialog(context, ref, lead),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Update Status'),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _launchWhatsapp(lead.mobile, 'Hi ${lead.fullName}, this is GMMX Gym. We are reaching out regarding your enquiry.'),
                icon: const Icon(Icons.chat_rounded, color: Colors.green),
              ),
              IconButton(
                onPressed: () => launchUrl(Uri.parse('tel:${lead.mobile}')),
                icon: const Icon(Icons.phone_rounded, color: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchWhatsapp(String phone, String message) async {
    final url = 'https://wa.me/$phone?text=${Uri.encodeComponent(message)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'NEW': color = Colors.blue; break;
      case 'CONTACTED': color = Colors.orange; break;
      case 'TRIAL_SCHEDULED': color = Colors.purple; break;
      case 'CONVERTED': color = Colors.green; break;
      case 'LOST': color = Colors.red; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showStatusDialog(BuildContext context, WidgetRef ref, Lead lead) {
    final statuses = ['NEW', 'CONTACTED', 'TRIAL_SCHEDULED', 'TRIAL_COMPLETED', 'CONVERTED', 'LOST'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Lead Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((s) => ListTile(
            title: Text(s),
            onTap: () async {
              await ref.read(leadListProvider.notifier).updateStatus(lead.id, s);
              if (context.mounted) Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }
}
