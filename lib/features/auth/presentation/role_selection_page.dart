import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/home_page.dart';

// Simple provider to store selected role
final selectedRoleProvider = StateProvider<String?>((ref) => null);

class RoleSelectionPage extends ConsumerWidget {
  const RoleSelectionPage({
    super.key,
    required this.mobile,
  });

  final String mobile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(selectedRoleProvider);

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  elevation: 0,
                  color: const Color(0x1AFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: const Color(0xFFFF5C73).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        const Text(
                          'What\'s Your Role?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Choose your role to get started',
                          style: TextStyle(
                            color: Color(0xFFB0B9C1),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Owner Role Card
                        _RoleCard(
                          title: 'Gym Owner',
                          description:
                              'Manage gyms, track trainers, monitor attendance',
                          icon: Icons.business_center_outlined,
                          isSelected: selectedRole == 'owner',
                          onTap: () {
                            ref
                                .read(selectedRoleProvider.notifier)
                                .state = 'owner';
                          },
                        ),

                        const SizedBox(height: 12),

                        // Trainer Role Card
                        _RoleCard(
                          title: 'Trainer',
                          description:
                              'Manage clients, assign plans, track progress',
                          icon: Icons.person_outline,
                          isSelected: selectedRole == 'trainer',
                          onTap: () {
                            ref
                                .read(selectedRoleProvider.notifier)
                                .state = 'trainer';
                          },
                        ),

                        const SizedBox(height: 12),

                        // Member Role Card
                        _RoleCard(
                          title: 'Member',
                          description:
                              'Track attendance, view plans, monitor progress',
                          icon: Icons.person_pin_outlined,
                          isSelected: selectedRole == 'member',
                          onTap: () {
                            ref
                                .read(selectedRoleProvider.notifier)
                                .state = 'member';
                          },
                        ),

                        const SizedBox(height: 32),

                        // Continue Button
                        FilledButton(
                          onPressed: selectedRole == null
                              ? null
                              : () {
                                  // Navigate to HomePage regardless of role
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const HomePage(),
                                    ),
                                  );
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5C73),
                            disabledBackgroundColor: const Color(0xFFFF5C73)
                                .withValues(alpha: 0.5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E293B) : const Color(0x0AFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF5C73)
                : const Color(0xFF334155),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF5C73).withValues(alpha: 0.2)
                    : const Color(0xFF334155),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFFFF5C73)
                    : const Color(0xFF94A3B8),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFFF5C73),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
