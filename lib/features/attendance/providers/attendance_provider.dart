import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

final attendanceActionProvider = Provider((ref) {
  final dio = ref.watch(dioClientProvider);
  return AttendanceActionNotifier(dio);
});

class AttendanceActionNotifier {
  final Dio _dio;
  AttendanceActionNotifier(this._dio);

  Future<void> markAttendance({
    required String memberId,
    String method = 'MANUAL',
    double? latitude,
    double? longitude,
    String? qrToken,
    bool isSelfScan = false,
  }) async {
    try {
      final endpoint = isSelfScan ? '/api/attendance/scan' : '/api/attendance/mark';
      await _dio.post(endpoint, data: {
        'memberId': memberId,
        'method': method,
        'latitude': latitude,
        'longitude': longitude,
        'qrToken': qrToken,
      });
    } catch (e) {
      rethrow;
    }
  }
}
