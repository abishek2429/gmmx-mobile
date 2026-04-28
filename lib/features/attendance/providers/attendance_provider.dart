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

  Future<void> markAttendance(String memberId) async {
    try {
      await _dio.post('/api/attendance/mark', data: {
        'memberId': memberId,
        'method': 'MANUAL',
      });
    } catch (e) {
      rethrow;
    }
  }
}
