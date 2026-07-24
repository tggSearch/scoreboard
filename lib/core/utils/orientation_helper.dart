import 'package:flutter/services.dart';

/// Safely update device orientation to avoid noisy iOS UIScene errors during transitions.
class OrientationHelper {
  OrientationHelper._();

  static Future<void> setPreferredOrientations(
    List<DeviceOrientation> orientations,
  ) async {
    await SystemChrome.setPreferredOrientations(orientations);
  }

  static Future<void> setPortrait() {
    return setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  static Future<void> setLandscape() {
    return setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
