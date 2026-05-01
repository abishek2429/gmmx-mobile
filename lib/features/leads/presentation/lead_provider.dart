import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class Lead {
  final String id;
  final String fullName;
  final String mobile;
  final String? email;
  final String? notes;
  final String status;
  final String? source;
  final String? interestLevel;
  final String? assignedTrainerId;
  final String? assignedTrainerName;
  final DateTime createdAt;

  Lead({
    required this.id,
    required this.fullName,
    required this.mobile,
    this.email,
    this.notes,
    required this.status,
    this.source,
    this.interestLevel,
    this.assignedTrainerId,
    this.assignedTrainerName,
    required this.createdAt,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'],
      fullName: json['fullName'],
      mobile: json['mobile'],
      email: json['email'],
      notes: json['notes'],
      status: json['status'],
      source: json['source'],
      interestLevel: json['interestLevel'],
      assignedTrainerId: json['assignedTrainerId'],
      assignedTrainerName: json['assignedTrainerName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

final leadListProvider = StateNotifierProvider<LeadNotifier, AsyncValue<List<Lead>>>((ref) {
  final dio = ref.watch(dioClientProvider);
  return LeadNotifier(dio);
});

class LeadNotifier extends StateNotifier<AsyncValue<List<Lead>>> {
  final Dio _dio;

  LeadNotifier(this._dio) : super(const AsyncValue.loading()) {
    fetchLeads();
  }

  Future<void> fetchLeads() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/api/leads');
      final List<dynamic> data = response.data['data']['content'];
      final leads = data.map((json) => Lead.fromJson(json)).toList();
      state = AsyncValue.data(leads);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createLead(Map<String, dynamic> data) async {
    try {
      await _dio.post('/api/leads', data: data);
      fetchLeads();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _dio.patch('/api/leads/$id/status', data: {'status': status});
      fetchLeads();
    } catch (e) {
      rethrow;
    }
  }
}
