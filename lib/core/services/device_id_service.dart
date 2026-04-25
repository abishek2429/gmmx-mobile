import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceIdServiceProvider = Provider((ref) => DeviceIdService());

class DeviceIdService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<String?> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id; // Unique ID on Android
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor; // Unique ID on iOS
      }
      return 'unknown_device';
    } catch (e) {
      return null;
    }
  }
}
