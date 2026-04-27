import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import 'client_list_page.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../trainer/presentation/trainer_list_page.dart';
import '../../../models/user_model.dart';

class ClientEditPage extends ConsumerStatefulWidget {
  final Client client;
  const ClientEditPage({super.key, required this.client});

  @override
  ConsumerState<ClientEditPage> createState() => _ClientEditPageState();
}

class _ClientEditPageState extends ConsumerState<ClientEditPage> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  String? selectedTrainerId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.client.name);
    emailController = TextEditingController(text: widget.client.email);
    phoneController = TextEditingController(text: widget.client.mobile);
    selectedTrainerId = widget.client.assignedTrainer != 'Unassigned' ? widget.client.assignedTrainer : null;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void handleUpdateClient() {
    if (!formKey.currentState!.validate()) return;
    
    setState(() => isLoading = true);

    Future.microtask(() async {
      try {
        final authService = ref.read(authServiceProvider);
        final token = await authService.getToken();
        
        if (token == null) throw Exception('Not authenticated');

        final dio = ref.read(dioClientProvider);
        
        await dio.put('/api/members/${widget.client.id}', 
          data: {
            'fullName': nameController.text,
            'email': emailController.text,
            'mobile': phoneController.text,
            'assignedTrainerId': selectedTrainerId,
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        if (mounted) {
          // ignore: unused_result
          ref.refresh(clientListProvider);
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          setState(() => isLoading = false);
          String errorMessage = e.toString();
          if (e is DioException && e.response?.data != null) {
            errorMessage = e.response?.data['message'] ?? e.response?.data.toString() ?? e.toString();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update member: $errorMessage'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    });
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Edit Member',
                          style: TextStyle(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Update details for ${widget.client.name}',
                          style: TextStyle(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FormField(
                                label: 'Full Name',
                                hintText: 'e.g., John Doe',
                                icon: Icons.person_outline_rounded,
                                controller: nameController,
                                isDark: isDark,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Name is required';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _FormField(
                                label: 'Email Address',
                                hintText: 'e.g., john@email.com',
                                icon: Icons.alternate_email_rounded,
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                isDark: isDark,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Email is required';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _FormField(
                                label: 'Phone Number',
                                hintText: 'e.g., 9876543210',
                                icon: Icons.phone_android_rounded,
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                isDark: isDark,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Phone is required';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Assigned Trainer',
                                style: TextStyle(
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ref.watch(trainerListProvider).when(
                                data: (trainers) => Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                      width: 1,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedTrainerId,
                                      isExpanded: true,
                                      hint: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'Select trainer',
                                          style: TextStyle(
                                            color: isDark ? AppColors.textHintDark : AppColors.textHint,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        setState(() => selectedTrainerId = value);
                                      },
                                      items: trainers
                                          .map((trainer) => DropdownMenuItem<String>(
                                                value: trainer.id,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                                  child: Text(
                                                    trainer.fullName,
                                                    style: TextStyle(
                                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                      dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                                loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                error: (err, _) => Text('Error loading trainers', style: const TextStyle(color: AppColors.error)),
                              ),
                              const SizedBox(height: 40),
                              FilledButton(
                                onPressed: isLoading ? null : handleUpdateClient,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
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

class _FormField extends StatefulWidget {
  const _FormField({
    required this.label,
    required this.hintText,
    required this.icon,
    required this.controller,
    required this.validator,
    required this.isDark,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool isDark;

  @override
  State<_FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<_FormField> {
  late FocusNode _focusNode;
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() => isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: widget.isDark ? AppColors.textHintDark : AppColors.textHint),
            prefixIcon: Icon(
              widget.icon,
              color: isFocused ? AppColors.primary : (widget.isDark ? AppColors.textHintDark : AppColors.textHint),
              size: 22,
            ),
            filled: true,
            fillColor: widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: widget.isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: widget.isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: TextStyle(
            color: widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontSize: 15,
          ),
          validator: widget.validator,
        ),
      ],
    );
  }
}
