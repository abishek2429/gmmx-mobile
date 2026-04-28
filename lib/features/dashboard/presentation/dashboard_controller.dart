import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/presentation/auth_controller.dart';

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
