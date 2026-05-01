import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../models/user_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../auth/providers/gym_provider.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../../core/network/dio_client.dart';
import 'trainer_list_page.dart';

class TrainerDetailsPage extends ConsumerStatefulWidget {
  const TrainerDetailsPage({
    super.key,
    required this.trainer,
    this.isOwnerView = false,
  });

  final UserModel trainer;
  final bool isOwnerView;

  @override
  ConsumerState<TrainerDetailsPage> createState() => _TrainerDetailsPageState();
}

class _TrainerDetailsPageState extends ConsumerState<TrainerDetailsPage> {
  static const _allPermissions = [
    _Permission('manage_leads', 'Manage Leads', 'Can add, edit and delete leads', Icons.person_search_rounded),
    _Permission('manage_attendance', 'Manage Attendance', 'Can mark and view attendance for all members', Icons.qr_code_scanner_rounded),
    _Permission('admin_access', 'Admin Access', 'Full access to gym management', Icons.admin_panel_settings_rounded),
    _Permission('manager_access', 'Manager Access', 'Can manage members and membership plans', Icons.manage_accounts_rounded),
    _Permission('trainer_only', 'Trainer Only', 'Standard trainer access (default)', Icons.fitness_center_rounded),
  ];

  late Set<String> _activePermissions;
  bool _isSavingPermissions = false;
  String? _permissionsError;

  @override
  void initState() {
    super.initState();
    // Parse existing permissions from comma-separated string
    final permsStr = widget.trainer.permissions;
    _activePermissions = permsStr.split(',').where((p) => p.isNotEmpty).toSet();
  }

  Future<void> _savePermissions() async {
    if (widget.trainer.id.isEmpty) {
      setState(() { _permissionsError = 'Invalid trainer ID. Please refresh and try again.'; });
      return;
    }

    setState(() { _isSavingPermissions = true; _permissionsError = null; });
    try {
      final dio = ref.read(dioClientProvider);
      final authService = ref.read(authServiceProvider);
      final token = await authService.getToken();

      final response = await dio.put(
        '/api/trainers/${widget.trainer.id}/permissions',
        data: {'permissions': _activePermissions.toList()},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success'] == true) {
        ref.invalidate(trainerListProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permissions updated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        setState(() { _permissionsError = response.data['message'] ?? 'Failed to update permissions'; });
      }
    } on DioException catch (e) {
      setState(() { 
        _permissionsError = e.response?.data['message'] ?? e.message ?? 'Unknown error occurred'; 
      });
    } catch (e) {
      setState(() { _permissionsError = e.toString(); });
    } finally {
      if (mounted) setState(() { _isSavingPermissions = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final isOwner = user?.normalizedRole == 'owner' || user?.normalizedRole == 'admin';

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
                      IconButton(
                        icon: Icon(Icons.more_horiz_rounded, color: isDark ? Colors.white : AppColors.textPrimary),
                        onPressed: () {},
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
                          if (isOwner) ...[
                            const SizedBox(height: 32),
                            _buildPermissionsSection(isDark),
                          ],
                          const SizedBox(height: 32),
                          _buildActions(isDark, ref, context),
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

  Widget _buildPermissionsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TRAINER PERMISSIONS',
                  style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
                const SizedBox(height: 4),
                Text(
                  'Control what this trainer can access',
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (_isSavingPermissions)
              const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppTheme.cardDecoration(isDark: isDark, radius: 24),
          child: Column(
            children: _allPermissions.asMap().entries.map((entry) {
              final perm = entry.value;
              final isEnabled = _activePermissions.contains(perm.key);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isEnabled
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(perm.icon, size: 18, color: isEnabled ? AppColors.primary : Colors.grey),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                perm.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                perm.description,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: isEnabled,
                          onChanged: (val) {
                            setState(() {
                              if (val) {
                                _activePermissions.add(perm.key);
                              } else {
                                _activePermissions.remove(perm.key);
                              }
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  if (entry.key < _allPermissions.length - 1)
                    Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ],
              );
            }).toList(),
          ),
        ),
        if (_permissionsError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_permissionsError!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isSavingPermissions ? null : _savePermissions,
            icon: const Icon(Icons.save_rounded, size: 18),
            label: const Text('SAVE PERMISSIONS', style: TextStyle(fontWeight: FontWeight.w900)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
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
              colors: [AppColors.info, AppColors.info.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.info.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.fitness_center_rounded, size: 48, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Text(
          widget.trainer.fullName,
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
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'PRO TRAINER',
            style: TextStyle(
              color: AppColors.info,
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
        Expanded(child: _statCard('CLIENTS', '—', Icons.people_rounded, isDark)),
        const SizedBox(width: 16),
        Expanded(child: _statCard('STATUS', widget.trainer.isActive ? 'Active' : 'Inactive', Icons.circle_rounded, isDark)),
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
          Icon(icon, color: AppColors.info, size: 20),
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
        _contactTile(Icons.email_rounded, 'Email', widget.trainer.email, isDark),
        const SizedBox(height: 12),
        _contactTile(Icons.phone_rounded, 'Phone', widget.trainer.phone, isDark),
      ],
    );
  }

  Widget _contactTile(IconData icon, String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(isDark: isDark, radius: 20),
      child: Row(
        children: [
          Icon(icon, color: AppColors.info.withValues(alpha: 0.5), size: 20),
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

  Widget _buildActions(bool isDark, WidgetRef ref, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              final slug = ref.read(gymProvider).value?.subdomain ?? 'dashboard';
              context.push('/$slug/messages/${widget.trainer.id}?name=${Uri.encodeComponent(widget.trainer.fullName)}');
            },
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
            onPressed: () {
              final slug = ref.read(gymProvider).value?.subdomain ?? 'dashboard';
              context.push('/$slug/owner/trainers/edit', extra: widget.trainer);
            },
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('EDIT', style: TextStyle(fontWeight: FontWeight.w900)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
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

class _Permission {
  final String key;
  final String label;
  final String description;
  final IconData icon;

  const _Permission(this.key, this.label, this.description, this.icon);
}
