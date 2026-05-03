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
    if (gym == null) return;

    final mode = gym.attendanceMode ?? 'MANUAL';
    
    if (mode == 'LOCATION_ONLY' || mode == 'HYBRID') {
      await _checkLocation();
    }
    
    if (mode == 'QR_ONLY' || mode == 'HYBRID') {
      setState(() {
        _scannerController = MobileScannerController();
      });
    } else if (mode == 'LOCATION_ONLY') {
      // If only location, we can auto-submit or show a button
      // For now, let user click a button to confirm
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
              'Success!',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your attendance has been recorded.',
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
          if (_scannerController != null)
            MobileScanner(
              controller: _scannerController!,
              onDetect: _handleDetect,
            ),
          
          if (mode == 'LOCATION_ONLY' || mode == 'MANUAL')
             Container(color: isDark ? const Color(0xFF0F0F1A) : Colors.white),

          // Overlay for QR
          if (mode == 'QR_ONLY' || mode == 'HYBRID')
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
                          'CHECK IN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Spacer
                    ],
                  ),
                ),

                const Spacer(),

                // Status/Errors
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
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
                  ),

                if (mode == 'LOCATION_ONLY' && _currentPosition != null && !_isProcessing)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'Location Verified',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You are at the gym. Click below to check in.',
                          style: TextStyle(color: Colors.white70),
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
                            child: const Text('CHECK IN NOW', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
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
