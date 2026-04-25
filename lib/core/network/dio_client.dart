import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

final dioClientProvider = Provider<Dio>((ref) {
  // Determine base URL dynamically based on platform/environment
  String getBaseUrl() {
    return 'https://api.gmmx.app'; 
  }

  final options = BaseOptions(
    baseUrl: getBaseUrl(),
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
