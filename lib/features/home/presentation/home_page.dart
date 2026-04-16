import 'package:flutter/material.dart';

import '../../auth/data/auth_repository.dart';
import '../../attendance/qr_attendance_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GMMX ${user.role}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tenant: ${user.tenantSlug}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Role: ${user.role}'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QrAttendancePage()));
              },
              child: const Text('QR Attendance'),
            ),
            const SizedBox(height: 12),
            const Text('Notifications: Coming soon')
          ],
        ),
      ),
    );
  }
}
