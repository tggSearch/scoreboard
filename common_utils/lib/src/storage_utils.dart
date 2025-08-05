import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageUtils {
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Set string value
  static Future<bool> setString(String key, String value) async {
    await init();
    return await _prefs!.setString(key, value);
  }

  /// Get string value
  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// Set int value
  static Future<bool> setInt(String key, int value) async {
    await init();
    return await _prefs!.setInt(key, value);
  }

  /// Get int value
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  /// Set bool value
  static Future<bool> setBool(String key, bool value) async {
    await init();
    return await _prefs!.setBool(key, value);
  }

  /// Get bool value
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  /// Set object (converted to JSON)
  static Future<bool> setObject(String key, Map<String, dynamic> value) async {
    await init();
    return await _prefs!.setString(key, jsonEncode(value));
  }

  /// Get object (parsed from JSON)
  static Map<String, dynamic>? getObject(String key) {
    final jsonString = _prefs?.getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Remove value by key
  static Future<bool> remove(String key) async {
    await init();
    return await _prefs!.remove(key);
  }

  /// Clear all data
  static Future<bool> clear() async {
    await init();
    return await _prefs!.clear();
  }

  /// Check if key exists
  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  /// Get all keys
  static Set<String> getKeys() {
    return _prefs?.getKeys() ?? <String>{};
  }
} 