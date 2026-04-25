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

class ClientCreationPage extends ConsumerStatefulWidget {
  const ClientCreationPage({super.key});

  @override
  ConsumerState<ClientCreationPage> createState() =>
      _ClientCreationPageState();
}

class _ClientCreationPageState extends ConsumerState<ClientCreationPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  String? selectedTrainer;
  bool isLoading = false;

  final trainers = ['Rajesh Kumar', 'Priya Singh', 'Amit Patel'];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void handleCreateClient() {
    if (!formKey.currentState!.validate()) return;
    if (selectedTrainer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a trainer')),
      );
      return;
    }

    setState(() => isLoading = true);

    Future.microtask(() async {
      try {
        final authService = ref.read(authServiceProvider);
        final token = await authService.getToken();
        
        if (token == null) throw Exception('Not authenticated');

        final dio = ref.read(dioClientProvider);
        
        final response = await dio.post('/api/members', 
          data: {
            'fullName': nameController.text,
            'email': emailController.text,
            'mobile': phoneController.text,
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
              content: Text('Failed to add member: $errorMessage'),
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
                        Text(
                          'Step 1 of 1',
                          style: TextStyle(
                            color: isDark ? AppColors.textHintDark : AppColors.textHint,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Add New Member',
                          style: TextStyle(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Register a new member to the gym',
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
                                  if ((value?.length ?? 0) < 3) return 'Min 3 characters';
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
                                  if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value ?? '')) {
                                    return 'Invalid email format';
                                  }
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
                                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value ?? '')) {
                                    return 'Invalid 10-digit phone number';
                                  }
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
                              Container(
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
                                    value: selectedTrainer,
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
                                      setState(() => selectedTrainer = value);
                                    },
                                    items: trainers
                                        .map((trainer) => DropdownMenuItem<String>(
                                              value: trainer,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: Text(
                                                  trainer,
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
                              const SizedBox(height: 40),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.info.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded, color: AppColors.info, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Member will use their mobile number and a default PIN (1234) to access their mobile app. They can change it later in their profile.',
                                        style: TextStyle(
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                          fontSize: 12,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                              FilledButton(
                                onPressed: isLoading ? null : handleCreateClient,
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
                                        'Create Account',
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: widget.isDark ? AppColors.errorDark : AppColors.error,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
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
