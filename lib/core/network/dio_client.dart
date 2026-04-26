import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../config.dart';

final dioClientProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    // Increasing timeouts to handle local network latency
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  final dio = Dio(options);

  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (obj) => debugPrint('DIO: ${obj.toString()}'),
  ));

  return dio;
});
