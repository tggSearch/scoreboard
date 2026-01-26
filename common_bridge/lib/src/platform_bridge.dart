import 'dart:io';

class PlatformBridge {
  /// Check if running on iOS
  static bool get isIOS => Platform.isIOS;

  /// Check if running on Android
  static bool get isAndroid => Platform.isAndroid;

  /// Get platform name
  static String get platformName {
    if (isIOS) return 'iOS';
    if (isAndroid) return 'Android';
    return 'Unknown';
  }

  /// Get platform version
  static String get platformVersion {
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