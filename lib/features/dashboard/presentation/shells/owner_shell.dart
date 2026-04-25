import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

class OwnerShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const OwnerShell({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: FBottomNavigationBar(
        index: navigationShell.currentIndex,
        onChange: _onTap,
        children: const [
          FBottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: Text('Home'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: Text('Members'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_rounded),
            label: Text('Trainers'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.payments_rounded),
            label: Text('Finance'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: Text('Profile'),
          ),
        ],
      ),
    );
  }
}
