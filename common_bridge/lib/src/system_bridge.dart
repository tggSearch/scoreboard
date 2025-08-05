import 'package:flutter/services.dart';

class SystemBridge {
  static const MethodChannel _channel = MethodChannel('system_bridge');

  /// Get battery level
  static Future<int> getBatteryLevel() async {
    try {
      final int result = await _channel.invokeMethod('getBatteryLevel');
      return result;
    } on PlatformException catch (e) {
      print('Error getting battery level: ${e.message}');
      return -1;
    }
  }

  /// Check if device is charging
  static Future<bool> isCharging() async {
    try {
      final bool result = await _channel.invokeMethod('isCharging');
      return result;
    } on PlatformException catch (e) {
      print('Error checking charging status: ${e.message}');
      return false;
    }
  }

  /// Get device storage info
  static Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final Map<String, dynamic> result = await _channel.invokeMethod('getStorageInfo');
      return result;
    } on PlatformException catch (e) {
      print('Error getting storage info: ${e.message}');
      return {};
    }
  }

  /// Get device memory info
  static Future<Map<String, dynamic>> getMemoryInfo() async {
    try {
      final Map<String, dynamic> result = await _channel.invokeMethod('getMemoryInfo');
      return result;
    } on PlatformException catch (e) {
      print('Error getting memory info: ${e.message}');
      return {};
    }
  }

  /// Open system settings
  static Future<void> openSystemSettings() async {
    try {
      await _channel.invokeMethod('openSystemSettings');
    } on PlatformException catch (e) {
      print('Error opening system settings: ${e.message}');
    }
  }

  /// Open app settings
  static Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod('openAppSettings');
    } on PlatformException catch (e) {
      print('Error opening app settings: ${e.message}');
    }
  }

  /// Share content
  static Future<void> shareContent(String content, {String? title}) async {
    try {
      await _channel.invokeMethod('shareContent', {
        'content': content,
        'title': title,
      });
    } on PlatformException catch (e) {
      print('Error sharing content: ${e.message}');
    }
  }

  /// Vibrate device
  static Future<void> vibrate({int duration = 100}) async {
    try {
      await _channel.invokeMethod('vibrate', {'duration': duration});
    } on PlatformException catch (e) {
      print('Error vibrating device: ${e.message}');
    }
  }

  /// Get device info
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final Map<String, dynamic> result = await _channel.invokeMethod('getDeviceInfo');
      return result;
    } on PlatformException catch (e) {
      print('Error getting device info: ${e.message}');
      return {};
    }
  }

  /// Check if device has internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      final bool result = await _channel.invokeMethod('hasInternetConnection');
      return result;
    } on PlatformException catch (e) {
      print('Error checking internet connection: ${e.message}');
      return false;
    }
  }
} 