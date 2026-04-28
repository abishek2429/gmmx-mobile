import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class MembershipPlan {
  final String id;
  final String name;
  final int durationDays;
  final double price;
  final String? description;

  MembershipPlan({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.price,
    this.description,
  });

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    return MembershipPlan(
      id: json['id'],
      name: json['name'],
      durationDays: json['durationDays'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
    );
  }
}

final membershipPlansProvider = StateNotifierProvider<MembershipPlanNotifier, AsyncValue<List<MembershipPlan>>>((ref) {
  final dio = ref.watch(dioClientProvider);
  return MembershipPlanNotifier(dio);
});

class MembershipPlanNotifier extends StateNotifier<AsyncValue<List<MembershipPlan>>> {
  final Dio _dio;

  MembershipPlanNotifier(this._dio) : super(const AsyncValue.loading()) {
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/api/membership-plans');
      final List<dynamic> data = response.data['data'];
      final plans = data.map((json) => MembershipPlan.fromJson(json)).toList();
      state = AsyncValue.data(plans);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createPlan(String name, int duration, double price, String? description) async {
    try {
      await _dio.post('/api/membership-plans', data: {
        'name': name,
        'durationDays': duration,
        'price': price,
        'description': description,
      });
      fetchPlans();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePlan(String id, String name, int duration, double price, String? description) async {
    try {
      await _dio.put('/api/membership-plans/$id', data: {
        'name': name,
        'durationDays': duration,
        'price': price,
        'description': description,
      });
      fetchPlans();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePlan(String id) async {
    try {
      await _dio.delete('/api/membership-plans/$id');
      fetchPlans();
    } catch (e) {
      rethrow;
    }
  }
}
