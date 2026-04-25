import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/presentation/auth_controller.dart';

class OwnerStats {
  final String totalMembers;
  final String activeTrainers;
  final String monthlyRevenue;
  final String newMembersThisMonth;

  OwnerStats({
    required this.totalMembers,
    required this.activeTrainers,
    required this.monthlyRevenue,
    required this.newMembersThisMonth,
  });

  factory OwnerStats.fromJson(Map<String, dynamic> json) {
    return OwnerStats(
      totalMembers: json['totalMembers'],
      activeTrainers: json['activeTrainers'],
      monthlyRevenue: json['monthlyRevenue'],
      newMembersThisMonth: json['newMembersThisMonth'],
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
