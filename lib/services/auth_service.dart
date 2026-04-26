import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService(this._dio);

  Future<UserModel?> login({
    required String gymId,
    required String identifier,
    required String pin,
    String? deviceId,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'gymId': gymId,
        'identifier': identifier,
        'pin': pin,
        'deviceId': deviceId,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        
        await _storage.write(key: 'accessToken', value: accessToken);
        await _storage.write(key: 'refreshToken', value: refreshToken);

        final userData = data['user'];
        return UserModel.fromJson(userData);
      }
      return null;
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Login failed. Please try again.';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<UserModel?> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );
      
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        return null; // User canceled sign in
      }

      final GoogleSignInAuthentication googleAuth = await account.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get Google ID Token.');
      }

      final response = await _dio.post('/auth/google', data: {
        'idToken': idToken,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        
        await _storage.write(key: 'accessToken', value: accessToken);
        await _storage.write(key: 'refreshToken', value: refreshToken);

        final userData = data['user'];
        return UserModel.fromJson(userData);
      }
      return null;
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Google Login failed. Please try again.';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }

  Future<void> sendOtp(String identifier) async {
    try {
      await _dio.post('/auth/send-otp', data: {
        'identifier': identifier,
      });
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Failed to send OTP.';
      throw Exception(errorMessage);
    }
  }

  Future<void> verifyOtp(String identifier, String otp) async {
    try {
      await _dio.post('/auth/verify-otp', data: {
        'identifier': identifier,
        'otp': otp,
      });
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Invalid OTP.';
      throw Exception(errorMessage);
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'accessToken');
  }
}
