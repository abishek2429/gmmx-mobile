import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import 'client_creation_page.dart';
import 'client_details_page.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/whatsapp_service.dart';

// Client model
class Client {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String assignedTrainer;
  final DateTime joinedAt;
  final int attendanceCount;
  final bool isActive;

  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.assignedTrainer,
    required this.joinedAt,
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
        assignedTrainer: json['assignedTrainerId'] ?? 'Unassigned',
        joinedAt: json['joinedAt'] != null ? DateTime.parse(json['joinedAt']) : DateTime.now(),
        attendanceCount: 0,
        isActive: json['isActive'] ?? true,
      );
    }).toList();
  } else {
    throw Exception('Failed to load members');
  }
});

class ClientListPage extends ConsumerWidget {
  const ClientListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final clientsAsync = ref.watch(clientListProvider);

    return Scaffold(
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
              child: Column(
                children: [
                  // Header
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
                                  'Members',
                                  style: TextStyle(
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Manage gym members',
                                  style: TextStyle(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: AppTheme.glassButton(isDark: isDark),
                                child: Icon(
                                  Icons.filter_list_rounded,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Search members...',
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

                  // Content based on AsyncValue
                  Expanded(
                    child: clientsAsync.when(
                      data: (clients) => Column(
                        children: [
                          // Stats Row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    label: 'Total',
                                    value: clients.length.toString(),
                                    icon: Icons.people_outline_rounded,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _StatCard(
                                    label: 'Active',
                                    value: clients.where((c) => c.isActive).length.toString(),
                                    icon: Icons.check_circle_outline_rounded,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _StatCard(
                                    label: 'Avg Attn',
                                    value: clients.isEmpty ? "0" : (clients.fold<int>(0, (sum, c) => sum + c.attendanceCount) / clients.length).toStringAsFixed(0),
                                    icon: Icons.analytics_outlined,
                                    isDark: isDark,
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
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(32),
                                            margin: const EdgeInsets.all(24),
                                            decoration: AppTheme.cardDecoration(isDark: isDark),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.people_outline_rounded,
                                                  size: 64,
                                                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                                                ),
                                                const SizedBox(height: 20),
                                                Text(
                                                  'No members yet',
                                                  style: TextStyle(
                                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Add your first member to get started',
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
                      loading: () => Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                      error: (error, stack) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
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
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/owner/members/add'),
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

class ClientCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                        client.name,
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.fitness_center_rounded, size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            client.assignedTrainer,
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => WhatsappService.sendMessage(
                    phone: client.mobile,
                    message: "Hi ${client.name}! This is GMMX Gym. How are you doing today? 💪",
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.chat_bubble_rounded, color: AppColors.success, size: 20),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: client.isActive
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    client.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: client.isActive
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
                    label: 'Attendance',
                    value: '${client.attendanceCount}',
                    icon: Icons.event_available_rounded,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(
                    label: 'Joined',
                    value: '${client.joinedAt.day}/${client.joinedAt.month}/${client.joinedAt.year}',
                    icon: Icons.event_available_rounded,
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
