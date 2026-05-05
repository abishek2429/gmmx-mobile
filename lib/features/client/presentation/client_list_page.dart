import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import 'client_creation_page.dart';
import 'client_details_page.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../auth/providers/gym_provider.dart';
import '../../attendance/providers/attendance_provider.dart';
import '../../../../core/widgets/responsive_layout.dart';

// Client model
class Client {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String assignedTrainer;
  final String? assignedTrainerId;
  final String membershipPlan;
  final String? membershipPlanId;
  final DateTime joinedAt;
  final DateTime? expiryDate;
  final double feesPaid;
  final int attendanceCount;
  final bool isActive;

  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.assignedTrainer,
    this.assignedTrainerId,
    required this.membershipPlan,
    this.membershipPlanId,
    required this.joinedAt,
    this.expiryDate,
    this.feesPaid = 0,
    required this.attendanceCount,
    required this.isActive,
  });
}

final clientListProvider = FutureProvider<List<Client>>((ref) async {
  final dio = ref.read(dioClientProvider);

  final response = await dio.get('/api/members');

  if (response.statusCode == 200) {
    final List data = response.data['data']['content'] ?? []; // Page response
    return data.map((json) {
      return Client(
        id: json['id'] ?? '',
        name: json['fullName'] ?? 'No Name',
        email: json['email'] ?? '',
        mobile: json['mobile'] ?? '',
        assignedTrainer: json['assignedTrainerName'] ?? 'Unassigned',
        assignedTrainerId: json['assignedTrainerId'],
        membershipPlan: json['membershipPlanName'] ?? 'No Plan',
        membershipPlanId: json['membershipPlanId'],
        joinedAt: json['joinedAt'] != null ? DateTime.parse(json['joinedAt']) : DateTime.now(),
        expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
        feesPaid: (json['feesPaid'] as num?)?.toDouble() ?? 0.0,
        attendanceCount: 0,
        isActive: json['status'] == 'ACTIVE',
      );
    }).toList();
  } else {
    throw Exception('Failed to load members');
  }
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredClientListProvider = Provider<AsyncValue<List<Client>>>((ref) {
  final clientsAsync = ref.watch(clientListProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return clientsAsync.whenData((clients) {
    if (query.isEmpty) return clients;
    return clients.where((c) => 
      c.name.toLowerCase().contains(query) || 
      c.email.toLowerCase().contains(query) ||
      c.mobile.toLowerCase().contains(query)
    ).toList();
  });
});

class ClientListPage extends ConsumerWidget {
  const ClientListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final clientsAsync = ref.watch(filteredClientListProvider);
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
                child: _buildMainContent(context, ref, isDark, clientsAsync, slug, isMobile: true),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/$slug/owner/members/add'),
          backgroundColor: AppColors.primary,
          elevation: 8,
          label: const Text(
            'Add Member',
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
      web: _buildMainContent(context, ref, isDark, clientsAsync, slug, isMobile: false),
    );
  }

  Widget _buildMainContent(
    BuildContext context, 
    WidgetRef ref, 
    bool isDark, 
    AsyncValue<List<Client>> clientsAsync,
    String slug,
    {required bool isMobile}
  ) {
    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.fromLTRB(isMobile ? 20 : 32, isMobile ? 20 : 32, isMobile ? 20 : 32, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: AppTheme.glassButton(isDark: isDark),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: isDark ? Colors.white70 : AppColors.textPrimary,
                        size: 16,
                      ),
                    ),
                    onPressed: () => context.pop(),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: AppTheme.glassButton(isDark: isDark),
                      child: const Icon(
                        Icons.filter_list_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Members',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  fontSize: isMobile ? 32 : 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'Manage your gym community',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                  decoration: InputDecoration(
                    hintText: 'Search members...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E1E2D) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: clientsAsync.when(
            data: (clients) => Column(
              children: [
                // Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'TOTAL',
                          value: clients.length.toString(),
                          icon: Icons.people_rounded,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'ACTIVE',
                          value: clients.where((c) => c.isActive).length.toString(),
                          icon: Icons.bolt_rounded,
                          isDark: isDark,
                          accentColor: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'ATTND',
                          value: clients.isEmpty ? "0" : (clients.fold<int>(0, (sum, c) => sum + c.attendanceCount) / clients.length).toStringAsFixed(0),
                          icon: Icons.trending_up_rounded,
                          isDark: isDark,
                          accentColor: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Client List
                Expanded(
                  child: clients.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(40),
                                  margin: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.people_outline_rounded,
                                          size: 40,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        ref.watch(searchQueryProvider).isEmpty ? 'No members yet' : 'No results found',
                                        style: TextStyle(
                                          color: isDark ? Colors.white : AppColors.textPrimary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        ref.watch(searchQueryProvider).isEmpty 
                                         ? 'Add your first member to get started'
                                         : 'Try searching with a different name',
                                        style: TextStyle(
                                          color: isDark ? Colors.white38 : Colors.black38,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
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
                          onRefresh: () => ref.refresh(clientListProvider.future),
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: clients.length,
                            itemBuilder: (context, index) {
                              final client = clients[index];
                              return ClientCard(
                                client: client,
                                isDark: isDark,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ClientDetailsPage(
                                        client: client,
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
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: $error', 
                    style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () => ref.refresh(clientListProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
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
    this.accentColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isDark;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (accentColor ?? AppColors.primary).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: accentColor ?? AppColors.primary,
              size: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class ClientCard extends ConsumerWidget {
  const ClientCard({
    super.key,
    required this.client,
    required this.onTap,
    required this.isDark,
  });

  final Client client;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar with Initial
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      client.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: client.isActive ? AppColors.success : AppColors.error,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (client.isActive ? AppColors.success : AppColors.error).withOpacity(0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            client.membershipPlan,
                            style: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz_rounded, color: isDark ? Colors.white54 : Colors.black45),
                  onSelected: (val) => _handleAction(context, ref, val, client),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Member')),
                    PopupMenuItem(
                      value: client.isActive ? 'freeze' : 'unfreeze',
                      child: Text(client.isActive ? 'Freeze Membership' : 'Unfreeze Membership'),
                    ),
                    const PopupMenuItem(value: 'upgrade', child: Text('Upgrade Plan')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete Member', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'TRAINER',
                    value: client.assignedTrainer,
                    icon: Icons.fitness_center_rounded,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(
                    label: 'ATTND',
                    value: '${client.attendanceCount}',
                    icon: Icons.calendar_today_rounded,
                    isDark: isDark,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    final gym = ref.read(gymProvider).value;
                    final slug = gym?.subdomain ?? 'dashboard';
                    context.push('/$slug/messages/${client.id}?name=${Uri.encodeComponent(client.name)}');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      color: AppColors.primary,
                      size: 18,
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

  Future<void> _handleAction(BuildContext context, WidgetRef ref, String action, Client client) async {
    final dio = ref.read(dioClientProvider);
    final authService = ref.read(authServiceProvider);
    final token = await authService.getToken();
    final slug = ref.read(gymProvider).value?.subdomain ?? 'dashboard';

    switch (action) {
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Member'),
            content: Text('Are you sure you want to delete ${client.name}? This action cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          try {
            await dio.delete(
              '/api/members/${client.id}',
              options: Options(headers: {'Authorization': 'Bearer $token'}),
            );
            ref.invalidate(clientListProvider);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Member deleted successfully')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppColors.error),
              );
            }
          }
        }
        break;

      case 'freeze':
      case 'unfreeze':
        try {
          final newStatus = client.isActive ? 'INACTIVE' : 'ACTIVE';
          await dio.put(
            '/api/members/${client.id}',
            data: {'status': newStatus},
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          );
          ref.invalidate(clientListProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Member status updated to ${newStatus.toLowerCase()}')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update status: $e'), backgroundColor: AppColors.error),
            );
          }
        }
        break;

      case 'edit':
        context.push('/$slug/owner/members/edit', extra: client);
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${action.toUpperCase()} action for ${client.name} coming soon!')),
        );
    }
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
