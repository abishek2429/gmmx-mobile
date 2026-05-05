import 'package:health/health.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final healthServiceProvider = Provider((ref) => HealthService());

class HealthService {
  final Health _health = Health();

  static const List<HealthDataType> types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  Future<bool> authorize() async {
    // Request permissions
    final permissions = types.map((e) => HealthDataAccess.READ).toList();
    bool? hasPermissions = await _health.hasPermissions(types, permissions: permissions);
    
    if (hasPermissions == null || !hasPermissions) {
      try {
        return await _health.requestAuthorization(types, permissions: permissions);
      } catch (e) {
        return false;
      }
    }
    return true;
  }

  Future<int> getStepsToday() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    
    try {
      final steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<double> getCaloriesToday() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    
    try {
      final healthData = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );
      
      double total = 0;
      for (var data in healthData) {
        total += (double.tryParse(data.value.toString()) ?? 0);
      }
      return total;
    } catch (e) {
      return 0.0;
    }
  }
}
