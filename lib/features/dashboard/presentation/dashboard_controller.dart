import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../services/health_service.dart';

class DailyRevenue {
  final String day;
  final double amount;

  DailyRevenue({required this.day, required this.amount});

  factory DailyRevenue.fromJson(Map<String, dynamic> json) {
    return DailyRevenue(
      day: json['day'],
      amount: (json['amount'] as num).toDouble(),
    );
  }
}

class OwnerStats {
  final String totalMembers;
  final String activeTrainers;
  final String monthlyRevenue;
  final String newMembersThisMonth;
  final List<DailyRevenue> weeklyRevenue;
  final String totalWeeklyRevenue;

  OwnerStats({
    required this.totalMembers,
    required this.activeTrainers,
    required this.monthlyRevenue,
    required this.newMembersThisMonth,
    required this.weeklyRevenue,
    required this.totalWeeklyRevenue,
  });

  factory OwnerStats.fromJson(Map<String, dynamic> json) {
    return OwnerStats(
      totalMembers: json['totalMembers'],
      activeTrainers: json['activeTrainers'],
      monthlyRevenue: json['monthlyRevenue'],
      newMembersThisMonth: json['newMembersThisMonth'],
      weeklyRevenue: (json['weeklyRevenue'] as List?)
              ?.map((e) => DailyRevenue.fromJson(e))
              .toList() ??
          [],
      totalWeeklyRevenue: json['totalWeeklyRevenue'] ?? '₹0',
    );
  }
}

class ClientStats {
  final String planName;
  final String expiryDate;
  final int totalVisits;
  final int calories;
  final List<Exercise> todayWorkout;
  final String? trainerId;
  final String trainerName;
  final String trainerSpecialty;
  final List<AttendanceDay> attendanceStreak;
  final int steps;
  final int stepGoal;
  final bool isCheckedIn;
  final double? height;
  final double? weight;

  ClientStats({
    required this.planName,
    required this.expiryDate,
    required this.totalVisits,
    required this.calories,
    required this.todayWorkout,
    this.trainerId,
    required this.trainerName,
    required this.trainerSpecialty,
    required this.attendanceStreak,
    required this.steps,
    required this.stepGoal,
    required this.isCheckedIn,
    this.height,
    this.weight,
  });

  factory ClientStats.fromJson(Map<String, dynamic> json) {
    return ClientStats(
      planName: json['planName'] ?? 'Standard',
      expiryDate: json['expiryDate'] ?? 'N/A',
      totalVisits: json['totalVisits'] ?? 0,
      calories: json['calories'] ?? 0,
      todayWorkout: (json['todayWorkout'] as List?)
              ?.map((e) => Exercise.fromJson(e))
              .toList() ??
          [],
      trainerId: json['trainerId'],
      trainerName: json['trainerName'] ?? 'No Trainer',
      trainerSpecialty: json['trainerSpecialty'] ?? 'Coach',
      attendanceStreak: (json['attendanceStreak'] as List?)
              ?.map((e) => AttendanceDay.fromJson(e))
              .toList() ??
          [],
      steps: json['steps'] ?? 0,
      stepGoal: json['stepGoal'] ?? 10000,
      isCheckedIn: json['isCheckedIn'] ?? false,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
    );
  }
}

class Exercise {
  final String name;
  final String sets;
  final String icon;

  Exercise({required this.name, required this.sets, required this.icon});

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] ?? '',
      sets: json['sets'] ?? '',
      icon: json['icon'] ?? 'fitness_center',
    );
  }
}

class AttendanceDay {
  final String day;
  final bool present;

  AttendanceDay({required this.day, required this.present});

  factory AttendanceDay.fromJson(Map<String, dynamic> json) {
    return AttendanceDay(
      day: json['day'] ?? '',
      present: json['present'] ?? false,
    );
  }
}

class RecentActivity {
  final String title;
  final String subtitle;
  final String icon;
  final String time;

  RecentActivity({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.time,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      icon: json['icon'] ?? 'info',
      time: json['time'] ?? '',
    );
  }
}

final ownerStatsProvider = FutureProvider<OwnerStats>((ref) async {
  final dio = ref.read(dioClientProvider);
  final authService = ref.read(authServiceProvider);
  final token = await authService.getToken();

  final response = await dio.get(
    '/api/dashboard/owner/stats',
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );

  if (response.statusCode == 200) {
    return OwnerStats.fromJson(response.data['data']);
  } else {
    throw Exception('Failed to load stats');
  }
});

final recentActivityProvider = FutureProvider<List<RecentActivity>>((ref) async {
  final dio = ref.read(dioClientProvider);
  final authService = ref.read(authServiceProvider);
  final token = await authService.getToken();

  final response = await dio.get(
    '/api/dashboard/recent-activity',
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((e) => RecentActivity.fromJson(e)).toList();
  } else {
    return [];
  }
});

final clientStatsProvider = FutureProvider<ClientStats>((ref) async {
  final dio = ref.read(dioClientProvider);
  final authService = ref.read(authServiceProvider);
  final healthService = ref.read(healthServiceProvider);
  final token = await authService.getToken();

  final response = await dio.get(
    '/api/dashboard/client/stats',
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );

  if (response.statusCode == 200) {
    var stats = ClientStats.fromJson(response.data['data']);
    
    // Fetch real health data if possible
    try {
      final steps = await healthService.getStepsToday();
      final calories = await healthService.getCaloriesToday();
      
      if (steps > 0) {
        stats = ClientStats(
          planName: stats.planName,
          expiryDate: stats.expiryDate,
          totalVisits: stats.totalVisits,
          calories: calories > 0 ? calories.toInt() : stats.calories,
          todayWorkout: stats.todayWorkout,
          trainerId: stats.trainerId,
          trainerName: stats.trainerName,
          trainerSpecialty: stats.trainerSpecialty,
          attendanceStreak: stats.attendanceStreak,
          steps: steps,
          stepGoal: stats.stepGoal,
          isCheckedIn: stats.isCheckedIn,
        );
      }
    } catch (_) {
      // Health data failed, use API stats
    }
    
    return stats;
  } else {
    throw Exception('Failed to load member stats');
  }
});
