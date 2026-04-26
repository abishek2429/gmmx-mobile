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
    // Navigate to Gym Users management
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GymUsersScreen(gymId: id, gymName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Administration', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.pageBackground(isDark: isDark),
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: isLoading 
            ? const Center(child: CircularProgressIndicator())
            : error != null
              ? Center(child: Text('Error: $error', style: const TextStyle(color: AppColors.error)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: gyms.length,
                  itemBuilder: (context, index) {
                    final gym = gyms[index];
                    return _GymCard(
                      gym: gym,
                      isDark: isDark,
                      onManage: () => _manageGym(gym['id'], gym['name']),
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

  const _GymCard({required this.gym, required this.isDark, required this.onManage});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        gym['name'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '/${gym['subdomain']}',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    gym['plan'],
                    style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.manage_accounts_rounded, color: AppColors.primary, size: 24),
                  onPressed: onManage,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(label: 'Users', value: '${gym['userCount']}', icon: Icons.people_outline_rounded),
                _StatItem(label: 'Owner', value: gym['ownerEmail'] ?? 'N/A', icon: Icons.email_outlined, isSmall: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isSmall;

  const _StatItem({required this.label, required this.value, required this.icon, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: isSmall ? 11 : 14, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
