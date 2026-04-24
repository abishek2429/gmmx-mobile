import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

class ClientShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ClientShell({
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
            icon: Icon(Icons.home_rounded),
            label: Text('Home'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_rounded),
            label: Text('Workout'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: Text('History'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.trending_up_rounded),
            label: Text('Progress'),
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
