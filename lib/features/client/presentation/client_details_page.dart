import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import 'client_list_page.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/network/dio_client.dart';

class ClientDetailsPage extends ConsumerStatefulWidget {
  const ClientDetailsPage({super.key, required this.client});

  final Client client;

  @override
  ConsumerState<ClientDetailsPage> createState() => _ClientDetailsPageState();
}

class _ClientDetailsPageState extends ConsumerState<ClientDetailsPage> {
  bool _isDeleting = false;

  Future<void> _deleteMember() async {
    setState(() => _isDeleting = true);
    try {
      final authService = ref.read(authServiceProvider);
      final token = await authService.getToken();
      final dio = ref.read(dioClientProvider);

      await dio.delete('/api/members/${widget.client.id}', options: Options(headers: {'Authorization': 'Bearer $token'}));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member deleted successfully', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.success));
        ref.invalidate(clientListProvider);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e', style: const TextStyle(color: Colors.white)), backgroundColor: AppColors.error));
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

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
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.textPrimary, size: 20),
                      onPressed: () => context.pop(),
                    ),
                    actions: [
                      if (_isDeleting)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                        )
                      else
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_horiz_rounded, color: isDark ? Colors.white : AppColors.textPrimary),
                          onSelected: (value) {
                            if (value == 'delete') _deleteMember();
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit Member')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete Member', style: TextStyle(color: AppColors.error))),
                          ],
                        ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildProfileHeader(isDark),
                          const SizedBox(height: 32),
                          _buildStatsGrid(isDark),
                          const SizedBox(height: 32),
                          _buildContactSection(isDark),
                          const SizedBox(height: 32),
                          _buildActions(isDark),
                          const SizedBox(height: 100),
                        ],
                      ),
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

  Widget _buildProfileHeader(bool isDark) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.person_rounded, size: 48, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Text(
          widget.client.name,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.client.isActive 
                ? AppColors.success.withValues(alpha: 0.1) 
                : AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.client.isActive ? 'ACTIVE' : 'INACTIVE',
            style: TextStyle(
              color: widget.client.isActive ? AppColors.success : AppColors.error,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(bool isDark) {
    return Row(
      children: [
        Expanded(child: _statCard('ATTENDANCE', widget.client.attendanceCount.toString(), Icons.calendar_today_rounded, isDark)),
        const SizedBox(width: 16),
        Expanded(child: _statCard('TRAINER', widget.client.assignedTrainer, Icons.fitness_center_rounded, isDark)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(isDark: isDark, radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CONTACT INFO', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        _contactTile(Icons.email_rounded, 'Email', widget.client.email, isDark),
        const SizedBox(height: 12),
        _contactTile(Icons.phone_rounded, 'Phone', widget.client.mobile, isDark),
      ],
    );
  }

  Widget _contactTile(IconData icon, String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(isDark: isDark, radius: 20),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary.withValues(alpha: 0.5), size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w700)),
              Text(value, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => WhatsappService.sendMessage(phone: widget.client.mobile, message: "Hi ${widget.client.name}!"),
            icon: const Icon(Icons.chat_bubble_rounded, size: 18),
            label: const Text('MESSAGE', style: TextStyle(fontWeight: FontWeight.w900)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('EDIT', style: TextStyle(fontWeight: FontWeight.w900)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}
