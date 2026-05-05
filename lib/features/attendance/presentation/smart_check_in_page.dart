import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../auth/providers/gym_provider.dart';
import '../../auth/presentation/auth_controller.dart';
import '../providers/attendance_provider.dart';
import '../../qr_attendance/presentation/qr_scanner_page.dart'; // Reuse overlay
import '../../dashboard/presentation/dashboard_controller.dart';

class SmartCheckInPage extends ConsumerStatefulWidget {
  const SmartCheckInPage({super.key});

  @override
  ConsumerState<SmartCheckInPage> createState() => _SmartCheckInPageState();
}

class _SmartCheckInPageState extends ConsumerState<SmartCheckInPage> {
  bool _isProcessing = false;
  String? _errorMessage;
  Position? _currentPosition;
  MobileScannerController? _scannerController;
  
  @override
  void initState() {
    super.initState();
    _initializeCheckIn();
  }

  Future<void> _initializeCheckIn() async {
    final gym = ref.read(gymProvider).value;
    
    // Default to HYBRID if not set to ensure "scan work"
    final mode = gym?.attendanceMode ?? 'HYBRID';
    
    if (mode == 'LOCATION_ONLY' || mode == 'HYBRID' || mode == 'MANUAL') {
      await _checkLocation();
    }
    
    if (mode == 'QR_ONLY' || mode == 'HYBRID' || mode == 'MANUAL') {
      setState(() {
        _scannerController = MobileScannerController();
      });
    }
  }

  Future<void> _checkLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Location error: $e";
      });
    }
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _handleDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _submitCheckIn(qrToken: barcode.rawValue);
        break;
      }
    }
  }

  Future<void> _submitCheckIn({String? qrToken}) async {
    final gym = ref.read(gymProvider).value;
    final user = ref.read(authControllerProvider).user;
    if (gym == null || user == null) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      await ref.read(attendanceActionProvider).markAttendance(
        memberId: user.id,
        method: gym.attendanceMode ?? 'MANUAL',
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
        qrToken: qrToken,
        isSelfScan: true,
      );

      if (mounted) {
        _showSuccess();
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _showSuccess() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Color(0xFF101018),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recorded!',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your status has been updated successfully.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Pop sheet
                  context.pop(); // Go back
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('CONTINUE', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final gym = ref.watch(gymProvider).value;
    final mode = gym?.attendanceMode ?? 'MANUAL';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_scannerController != null) ...[
            MobileScanner(
              controller: _scannerController!,
              onDetect: _handleDetect,
            ),
            // Overlay for QR
            Container(
              decoration: ShapeDecoration(
                shape: QrScannerOverlayShape(
                  borderColor: AppColors.primary,
                  borderRadius: 20,
                  borderLength: 40,
                  borderWidth: 8,
                  cutOutSize: 280,
                ),
              ),
            ),
          ] else if (mode == 'LOCATION_ONLY' || mode == 'MANUAL')
             Container(color: isDark ? const Color(0xFF0F0F1A) : Colors.white),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'ATTENDANCE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      if (_scannerController != null) ...[
                        GestureDetector(
                          onTap: () => _scannerController!.toggleTorch(),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.flashlight_on_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _scannerController!.switchCamera(),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ] else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),

                const Spacer(),

                // Status/Errors
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.error.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.error),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () => _submitCheckIn(qrToken: 'GMMX_SUCCESS'),
                          icon: const Icon(Icons.bug_report_rounded, size: 16),
                          label: const Text('Simulate Scan for Demo'),
                          style: TextButton.styleFrom(foregroundColor: Colors.white54),
                        ),
                      ],
                    ),
                  ),

                if ((mode == 'LOCATION_ONLY' || mode == 'MANUAL' || mode == 'HYBRID') && !_isProcessing)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        if (mode == 'LOCATION_ONLY' || mode == 'HYBRID') ...[
                          Icon(
                            _currentPosition != null ? Icons.location_on : Icons.location_off,
                            color: _currentPosition != null ? AppColors.primary : AppColors.error,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _currentPosition != null ? 'Location Verified' : 'Checking Location...',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          ref.watch(clientStatsProvider).value?.isCheckedIn ?? false
                              ? 'Your session is active. Click below to check out.'
                              : 'You can mark your attendance below.',
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _submitCheckIn(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            child: Text(
                              ref.watch(clientStatsProvider).value?.isCheckedIn ?? false
                                  ? 'CHECK OUT NOW'
                                  : 'CHECK IN NOW',
                              style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_isProcessing)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
