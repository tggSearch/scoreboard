import 'package:flutter/services.dart';

class PermissionBridge {
  static const MethodChannel _channel = MethodChannel('permission_bridge');

  /// Check if camera permission is granted
  static Future<bool> checkCameraPermission() async {
    try {
      final bool result = await _channel.invokeMethod('checkCameraPermission');
      return result;
    } on PlatformException catch (e) {
      print('Error checking camera permission: ${e.message}');
      return false;
    }
  }

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    try {
      final bool result = await _channel.invokeMethod('requestCameraPermission');
      return result;
    } on PlatformException catch (e) {
      print('Error requesting camera permission: ${e.message}');
      return false;
    }
  }

  /// Check if storage permission is granted
  static Future<bool> checkStoragePermission() async {
    try {
      final bool result = await _channel.invokeMethod('checkStoragePermission');
      return result;
    } on PlatformException catch (e) {
      print('Error checking storage permission: ${e.message}');
      return false;
    }
  }

  /// Request storage permission
  static Future<bool> requestStoragePermission() async {
    try {
      final bool result = await _channel.invokeMethod('requestStoragePermission');
      return result;
    } on PlatformException catch (e) {
      print('Error requesting storage permission: ${e.message}');
      return false;
    }
  }

  /// Check if microphone permission is granted
  static Future<bool> checkMicrophonePermission() async {
    try {
      final bool result = await _channel.invokeMethod('checkMicrophonePermission');
      return result;
    } on PlatformException catch (e) {
      print('Error checking microphone permission: ${e.message}');
      return false;
    }
  }

  /// Request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    try {
      final bool result = await _channel.invokeMethod('requestMicrophonePermission');
      return result;
    } on PlatformException catch (e) {
      print('Error requesting microphone permission: ${e.message}');
      return false;
    }
  }

  /// Check if location permission is granted
  static Future<bool> checkLocationPermission() async {
    try {
      final bool result = await _channel.invokeMethod('checkLocationPermission');
      return result;
    } on PlatformException catch (e) {
      print('Error checking location permission: ${e.message}');
      return false;
    }
  }

  /// Request location permission
  static Future<bool> requestLocationPermission() async {
    try {
      final bool result = await _channel.invokeMethod('requestLocationPermission');
      return result;
    } on PlatformException catch (e) {
      print('Error requesting location permission: ${e.message}');
      return false;
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
} 