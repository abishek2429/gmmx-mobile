import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class Equipment {
  final String id;
  final String name;
  final int quantity;
  final String condition;
  final DateTime? lastMaintenanceDate;

  Equipment({
    required this.id,
    required this.name,
    required this.quantity,
    required this.condition,
    this.lastMaintenanceDate,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      condition: json['condition'],
      lastMaintenanceDate: json['lastMaintenanceDate'] != null 
          ? DateTime.parse(json['lastMaintenanceDate']) 
          : null,
    );
  }
}

final equipmentProvider = StateNotifierProvider<EquipmentNotifier, AsyncValue<List<Equipment>>>((ref) {
  final dio = ref.watch(dioClientProvider);
  return EquipmentNotifier(dio);
});

class EquipmentNotifier extends StateNotifier<AsyncValue<List<Equipment>>> {
  final Dio _dio;

  EquipmentNotifier(this._dio) : super(const AsyncValue.loading()) {
    fetchEquipment();
  }

  Future<void> fetchEquipment() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/api/equipment');
      final List<dynamic> data = response.data['data'];
      final equipment = data.map((json) => Equipment.fromJson(json)).toList();
      state = AsyncValue.data(equipment);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createEquipment(String name, int quantity, String condition, DateTime? maintenanceDate) async {
    try {
      await _dio.post('/api/equipment', data: {
        'name': name,
        'quantity': quantity,
        'condition': condition,
        'lastMaintenanceDate': maintenanceDate?.toIso8601String().split('T')[0],
      });
      fetchEquipment();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEquipment(String id, String name, int quantity, String condition, DateTime? maintenanceDate) async {
    try {
      await _dio.put('/api/equipment/$id', data: {
        'name': name,
        'quantity': quantity,
        'condition': condition,
        'lastMaintenanceDate': maintenanceDate?.toIso8601String().split('T')[0],
      });
      fetchEquipment();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEquipment(String id) async {
    try {
      await _dio.delete('/api/equipment/$id');
      fetchEquipment();
    } catch (e) {
      rethrow;
    }
  }
}
