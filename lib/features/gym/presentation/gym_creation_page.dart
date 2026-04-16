import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'gym_list_page.dart';

class GymCreationPage extends ConsumerStatefulWidget {
  const GymCreationPage({super.key});

  @override
  ConsumerState<GymCreationPage> createState() => _GymCreationPageState();
}

class _GymCreationPageState extends ConsumerState<GymCreationPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void handleCreateGym() {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        // Add new gym to the list
        final newGym = Gym(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: nameController.text,
          location: locationController.text,
          email: emailController.text,
          contactPhone: phoneController.text,
          memberCount: 0,
          trainerCount: 0,
          createdAt: DateTime.now(),
        );

        ref.read(gymListProvider.notifier).state = [
          ...ref.read(gymListProvider),
          newGym,
        ];

        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0f172a),
              const Color(0xFF1a0f1f),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        foregroundDecoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              const Color(0xFFFF5C73).withValues(alpha: 0.06),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create New Gym',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fill in the details to set up your gym',
                    style: TextStyle(
                      color: Color(0xFFB0B9C1),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Form
              Form(
                key: formKey,
                child: Column(
                  children: [
                    // Gym Name
                    _FormField(
                      label: 'Gym Name',
                      hintText: 'e.g., FitPro Gym Downtown',
                      icon: Icons.business_center_outlined,
                      controller: nameController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Gym name is required';
                        }
                        if ((value?.length ?? 0) < 3) {
                          return 'Gym name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Location
                    _FormField(
                      label: 'Location',
                      hintText: 'e.g., Mumbai, Maharashtra',
                      icon: Icons.location_on_outlined,
                      controller: locationController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Location is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Email
                    _FormField(
                      label: 'Contact Email',
                      hintText: 'e.g., info@fitpro.com',
                      icon: Icons.email_outlined,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Email is required';
                        }
                        if (!RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                            .hasMatch(value ?? '')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Phone
                    _FormField(
                      label: 'Contact Phone',
                      hintText: 'e.g., 9876543210',
                      icon: Icons.phone_outlined,
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Phone number is required';
                        }
                        if (!RegExp(r'^[6-9]\d{9}$')
                            .hasMatch(value ?? '')) {
                          return 'Please enter a valid 10-digit phone number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Info Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A5F).withValues(
                          alpha: 0.4,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF3B82F6).withValues(
                            alpha: 0.2,
                          ),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        '✓ You\'ll be able to add trainers after creating the gym\n✓ Share your gym code with trainers to join\n✓ Start managing attendance and plans',
                        style: TextStyle(
                          color: Color(0xFFADD7F6),
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Create Button
                    FilledButton(
                      onPressed: isLoading ? null : handleCreateGym,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5C73),
                        disabledBackgroundColor: const Color(0xFFFF5C73)
                            .withValues(alpha: 0.5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Create Gym',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),

                    const SizedBox(height: 12),

                    // Cancel Button
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(
                          color: Color(0xFF334155),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  @override
  State<_FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<_FormField> {
  late FocusNode _focusNode;
  bool isFocused = false;
  String? errorText;

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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF64748B),
            ),
            prefixIcon: Icon(
              widget.icon,
              color: isFocused
                  ? const Color(0xFFFF5C73)
                  : const Color(0xFF64748B),
              size: 20,
            ),
            filled: true,
            fillColor: const Color(0xFF1E293B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF334155),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF5C73),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFDC2626),
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            errorText: errorText,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          validator: widget.validator,
          onChanged: (_) {
            setState(() => errorText = null);
          },
        ),
      ],
    );
  }
}
