import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

class TrainerShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const TrainerShell({
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
            label: Text('Clients'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: Text('Plans'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_rounded),
            label: Text('Attendance'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: Text('Profile'),
          ),
        ],
      ),
    );
  }
}
