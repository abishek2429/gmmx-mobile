import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/network/dio_client.dart';
import './gym_users_screen.dart';

class SuperAdminDashboard extends ConsumerStatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  ConsumerState<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends ConsumerState<SuperAdminDashboard> {
  List<dynamic> gyms = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.get('/api/super-admin/gyms');
      
      if (mounted) {
        setState(() {
          gyms = response.data['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  void _manageGym(String id, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GymUsersScreen(gymId: id, gymName: name),
      ),
    );
  }

  Future<void> _deleteGym(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Gym?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to permanently delete "$name"? This will remove all users, members, and data associated with this gym. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final dio = ref.read(dioClientProvider);
        await dio.delete('/api/super-admin/gyms/$id');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gym "$name" deleted successfully'), backgroundColor: AppColors.error),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete gym: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Administration', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: AppTheme.pageBackground(isDark: isDark),
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: isLoading 
            ? const Center(child: CircularProgressIndicator())
            : error != null
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text('Error: $error', style: const TextStyle(color: AppColors.error)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                  ],
                ))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  itemCount: gyms.length,
                  itemBuilder: (context, index) {
                    final gym = gyms[index];
                    return _GymCard(
                      gym: gym,
                      isDark: isDark,
                      onManage: () => _manageGym(gym['id'], gym['name']),
                      onDelete: () => _deleteGym(gym['id'], gym['name']),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _GymCard extends StatelessWidget {
  final dynamic gym;
  final bool isDark;
  final VoidCallback onManage;
  final VoidCallback onDelete;

  const _GymCard({
    required this.gym, 
    required this.isDark, 
    required this.onManage,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gym['name'],
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'gmmx.app/${gym['subdomain']}',
                              style: TextStyle(
                                color: AppColors.primary, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          gym['plan'],
                          style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _StatBadge(
                        icon: Icons.people_rounded,
                        value: '${gym['userCount']}',
                        label: 'Active Users',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatBadge(
                          icon: Icons.alternate_email_rounded,
                          value: gym['ownerEmail'] ?? 'No Email',
                          label: 'Owner Contact',
                          isDark: isDark,
                          isLong: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey[50],
                border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onManage,
                      icon: const Icon(Icons.manage_accounts_rounded, size: 18),
                      label: const Text('Manage Users', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.error.withOpacity(0.1),
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.all(12),
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
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;
  final bool isLong;

  const _StatBadge({
    required this.icon, 
    required this.value, 
    required this.label, 
    required this.isDark,
    this.isLong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: isLong ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isDark ? Colors.white38 : Colors.grey[600]),
          const SizedBox(width: 10),
          if (isLong)
            Expanded(
              child: _buildContent(),
            )
          else
            _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value, 
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label, 
          style: TextStyle(fontSize: 9, color: isDark ? Colors.white38 : Colors.grey[500], fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
