import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'trainer_list_page.dart';

class TrainerCreationPage extends ConsumerStatefulWidget {
  const TrainerCreationPage({super.key});

  @override
  ConsumerState<TrainerCreationPage> createState() =>
      _TrainerCreationPageState();
}

class _TrainerCreationPageState extends ConsumerState<TrainerCreationPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  String? selectedSpecialization;
  bool isLoading = false;

  final specializations = [
    'Strength Training',
    'Cardio & Weight Loss',
    'Yoga & Flexibility',
    'CrossFit',
    'Functional Training',
    'HIIT',
  ];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void handleCreateTrainer() {
    if (!formKey.currentState!.validate()) return;
    if (selectedSpecialization == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a specialization')),
      );
      return;
    }

    setState(() => isLoading = true);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final newTrainer = Trainer(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: nameController.text,
          email: emailController.text,
          phone: phoneController.text,
          specialization: selectedSpecialization!,
          clientCount: 0,
          joinedAt: DateTime.now(),
          isActive: true,
        );

        ref.read(trainerListProvider.notifier).state = [
          ...ref.read(trainerListProvider),
          newTrainer,
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
                    'Onboard Trainer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add a new trainer to your gym team',
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
                    // Trainer Name
                    _FormField(
                      label: 'Full Name',
                      hintText: 'e.g., Rajesh Kumar',
                      icon: Icons.person_outline,
                      controller: nameController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Trainer name is required';
                        }
                        if ((value?.length ?? 0) < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Email
                    _FormField(
                      label: 'Email',
                      hintText: 'e.g., rajesh@gym.com',
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
                      label: 'Phone',
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

                    const SizedBox(height: 16),

                    // Specialization Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Specialization',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF334155),
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedSpecialization,
                              isExpanded: true,
                              hint: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Select specialization',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(
                                    () => selectedSpecialization = value);
                              },
                              items: specializations
                                  .map((spec) =>
                                      DropdownMenuItem<String>(
                                        value: spec,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Text(
                                            spec,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              dropdownColor: const Color(0xFF1E293B),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                        '✓ Trainer can start managing clients immediately\n✓ Send them a joining code to connect with your gym\n✓ Monitor their performance and client satisfaction',
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
                      onPressed: isLoading ? null : handleCreateTrainer,
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
                              'Onboard Trainer',
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
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          validator: widget.validator,
        ),
      ],
    );
  }
}
