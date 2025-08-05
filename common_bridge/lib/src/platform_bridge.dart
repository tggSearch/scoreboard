import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformBridge {
  /// Check if running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Check if running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Check if running on Web
  static bool get isWeb => kIsWeb;

  /// Check if running on Desktop
  static bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  /// Get platform name
  static String get platformName {
    if (isWeb) return 'Web';
    if (isIOS) return 'iOS';
    if (isAndroid) return 'Android';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Get platform version
  static String get platformVersion {
    if (isWeb) return 'Web';
    return Platform.operatingSystemVersion;
  }

  /// Check if device is tablet
  static bool get isTablet {
    // This is a simplified check, in real app you might want to use device_info_plus package
    return false; // Placeholder implementation
  }

  /// Get device info
  static Map<String, dynamic> get deviceInfo {
    return {
      'platform': platformName,
      'version': platformVersion,
      'isTablet': isTablet,
    };
  }
} 