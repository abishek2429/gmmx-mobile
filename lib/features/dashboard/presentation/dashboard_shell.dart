import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'role_dashboards/owner_dashboard.dart';
import 'role_dashboards/trainer_dashboard.dart';
import 'role_dashboards/member_dashboard.dart';

enum AppRole { owner, trainer, member }

final userRoleProvider = StateProvider<AppRole>((ref) => AppRole.owner);

class DashboardShell extends ConsumerWidget {
  const DashboardShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);

    return Scaffold(
      body: _getDashboard(role),
      bottomNavigationBar: role == AppRole.member 
        ? _buildMemberNav(context) 
        : _buildAdminNav(context),
    );
  }

  Widget _getDashboard(AppRole role) {
    switch (role) {
      case AppRole.owner:
        return const OwnerDashboard();
      case AppRole.trainer:
        return const TrainerDashboard();
      case AppRole.member:
        return const MemberDashboard();
    }
  }

  Widget _buildAdminNav(BuildContext context) {
    return NavigationBar(
      destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.people_outline), label: 'Members'),
        NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
        NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
      ],
    );
  }

  Widget _buildMemberNav(BuildContext context) {
    return NavigationBar(
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.qr_code), label: 'My QR'),
        NavigationDestination(icon: Icon(Icons.history), label: 'Log'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
