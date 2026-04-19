import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';

class QrAttendancePage extends ConsumerStatefulWidget {
  const QrAttendancePage({super.key});

  @override
  ConsumerState<QrAttendancePage> createState() => _QrAttendancePageState();
}

class _QrAttendancePageState extends ConsumerState<QrAttendancePage> {
  final qrTokenController = TextEditingController();
  final memberIdController = TextEditingController();

  bool isLoading = false;
  String statusMessage = '';

  @override
  void dispose() {
    qrTokenController.dispose();
    memberIdController.dispose();
    super.dispose();
  }

  Future<void> generateDailyQr() async {
    setState(() {
      isLoading = true;
      statusMessage = '';
    });

    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.post(
        '/api/attendance/qr/generate',
        data: {'tenantSlug': 'titan-hq'},
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['qrToken'] as String? ?? '';
      final qrDate = data['qrDate'] as String? ?? '';

      setState(() {
        qrTokenController.text = token;
        statusMessage = 'QR generated for $qrDate';
      });
    } catch (e) {
      setState(() {
        statusMessage = _errorMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> markAttendance() async {
    final qrToken = qrTokenController.text.trim();
    final memberId = memberIdController.text.trim();

    if (qrToken.isEmpty || memberId.isEmpty) {
      setState(() {
        statusMessage = 'Enter both QR token and member ID.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      statusMessage = '';
    });

    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.post(
        '/api/attendance/scan',
        data: {
          'tenantSlug': 'titan-hq',
          'qrToken': qrToken,
          'memberId': memberId,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final message = data['message'] as String? ?? 'Attendance marked';
      final attendanceDate = data['attendanceDate'] as String? ?? '';

      setState(() {
        statusMessage = '$message${attendanceDate.isNotEmpty ? ' ($attendanceDate)' : ''}';
      });
    } catch (e) {
      setState(() {
        statusMessage = _errorMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _errorMessage(Object error) {
    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '');
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Attendance')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tenant: ${'titan-hq'}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: isLoading ? null : generateDailyQr,
                            icon: const Icon(Icons.qr_code_2),
                            label: const Text('Generate Daily QR Token'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: qrTokenController,
                          decoration: const InputDecoration(
                            labelText: 'QR Token',
                            hintText: 'Paste generated token',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: memberIdController,
                          decoration: const InputDecoration(
                            labelText: 'Member ID',
                            hintText: 'UUID from /api/member response',
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: isLoading ? null : markAttendance,
                            child: const Text('Mark Attendance'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (statusMessage.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    statusMessage,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (isLoading) ...[
                  const SizedBox(height: 12),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
