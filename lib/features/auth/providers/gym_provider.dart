import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/theme_provider.dart';

class GymInfo {
  final String id;
  final String subdomain;
  final String name;
  final String? displayName;
  final String? logoUrl;
  final String? address;
  final String? contactPhone;

  GymInfo({
    required this.id,
    required this.subdomain,
    required this.name,
    this.displayName,
    this.logoUrl,
    this.address,
    this.contactPhone,
  });

  factory GymInfo.fromJson(Map<String, dynamic> json) {
    return GymInfo(
      id: json['id'],
      subdomain: json['subdomain'],
      name: json['name'],
      displayName: json['displayName'],
      logoUrl: json['logoUrl'],
      address: json['address'],
      contactPhone: json['contactPhone'],
    );
  }
}

final gymProvider = StateNotifierProvider<GymNotifier, AsyncValue<GymInfo?>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final dio = ref.watch(dioClientProvider);
  return GymNotifier(prefs, dio);
});

class GymNotifier extends StateNotifier<AsyncValue<GymInfo?>> {
  final SharedPreferences _prefs;
  final Dio _dio;
  static const _key = 'gmmx_current_gym_id';

  GymNotifier(this._prefs, this._dio) : super(const AsyncValue.data(null)) {
    _loadStoredGym();
  }

  void _loadStoredGym() async {
    final gymId = _prefs.getString(_key);
    if (gymId != null) {
      lookupGym(gymId);
    }
  }

  Future<bool> lookupGym(String gymId) async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/api/tenants/lookup/$gymId');
      final gym = GymInfo.fromJson(response.data['data']);
      state = AsyncValue.data(gym);
      await _prefs.setString(_key, gymId);
      return true;
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Gym not found. Please check the ID.';
      state = AsyncValue.error(message, StackTrace.current);
      return false;
    } catch (e, stack) {
      state = AsyncValue.error('An unexpected error occurred', stack);
      return false;
    }
  }

  void clearGym() {
    _prefs.remove(_key);
    state = const AsyncValue.data(null);
  }
}
