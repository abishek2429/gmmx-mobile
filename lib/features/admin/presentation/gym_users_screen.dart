import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/network/dio_client.dart';

class GymUsersScreen extends ConsumerStatefulWidget {
  final String gymId;
  final String gymName;

  const GymUsersScreen({super.key, required this.gymId, required this.gymName});

  @override
  ConsumerState<GymUsersScreen> createState() => _GymUsersScreenState();
}

class _GymUsersScreenState extends ConsumerState<GymUsersScreen> {
  List<dynamic> users = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.get('/api/super-admin/gyms/${widget.gymId}/users');
      
      if (mounted) {
        setState(() {
          users = response.data['data'];
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

  Future<void> _resetPin(String userId, String userName) async {
    final pinController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset PIN for $userName'),
        content: TextField(
          controller: pinController,
          decoration: const InputDecoration(labelText: 'New 4-Digit PIN', hintText: '1234'),
          keyboardType: TextInputType.number,
          maxLength: 4,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && pinController.text.length == 4) {
      try {
        final dio = ref.read(dioClientProvider);
        await dio.put('/api/super-admin/users/$userId/reset-pin', data: pinController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN reset successfully')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to reset PIN: $e'), backgroundColor: AppColors.error));
        }
      }
    }
  }

  Future<void> _addUser() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final pinController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone (10 digits)')),
              TextField(controller: pinController, decoration: const InputDecoration(labelText: '4-Digit PIN'), keyboardType: TextInputType.number, maxLength: 4),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final dio = ref.read(dioClientProvider);
        await dio.post('/api/super-admin/gyms/${widget.gymId}/users', data: {
          'ownerName': nameController.text, // Backend reuses this field
          'email': emailController.text,
          'phone': phoneController.text,
          'pin': pinController.text,
        });
        _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User added successfully')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add user: $e'), backgroundColor: AppColors.error));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gymName, style: const TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: _addUser,
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.pageBackground(isDark: isDark),
        child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
            ? Center(child: Text('Error: $error'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(user['fullName']?[0] ?? '?', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(user['fullName'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${user['role']} • ${user['email']}'),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Modify')),
                          const PopupMenuItem(value: 'pin', child: Text('Change PIN')),
                        ],
                        onSelected: (val) {
                          if (val == 'pin') {
                            _resetPin(user['id'], user['fullName']);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
