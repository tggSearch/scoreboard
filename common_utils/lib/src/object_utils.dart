import 'dart:convert';

class ObjectUtils {
  /// Deep copy of Map
  static Map<String, dynamic> deepCopyMap(Map<String, dynamic> original) {
    return jsonDecode(jsonEncode(original));
  }

  /// Deep copy of List
  static List<dynamic> deepCopyList(List<dynamic> original) {
    return jsonDecode(jsonEncode(original));
  }

  /// Check if object is null
  static bool isNull(dynamic obj) {
    return obj == null;
  }

  /// Check if object is not null
  static bool isNotNull(dynamic obj) {
    return obj != null;
  }

  /// Safe cast with default value
  static T? safeCast<T>(dynamic obj, T? defaultValue) {
    if (obj is T) {
      return obj;
    }
    return defaultValue;
  }

  /// Convert dynamic to Map<String, dynamic>
  static Map<String, dynamic>? toMap(dynamic obj) {
    if (obj is Map<String, dynamic>) {
      return obj;
    }
    if (obj is Map) {
      return Map<String, dynamic>.from(obj);
    }
    return null;
  }

  /// Convert dynamic to List
  static List<dynamic>? toList(dynamic obj) {
    if (obj is List) {
      return obj;
    }
    return null;
  }

  /// Merge two maps
  static Map<String, dynamic> mergeMaps(
    Map<String, dynamic> map1,
    Map<String, dynamic> map2,
  ) {
    final result = Map<String, dynamic>.from(map1);
    result.addAll(map2);
    return result;
  }

  /// Get nested value from map using dot notation
  static dynamic getNestedValue(Map<String, dynamic> map, String path) {
    final keys = path.split('.');
    dynamic current = map;
    
    for (final key in keys) {
      if (current is Map && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    
    return current;
  }

  /// Set nested value in map using dot notation
  static void setNestedValue(Map<String, dynamic> map, String path, dynamic value) {
    final keys = path.split('.');
    final lastKey = keys.removeLast();
    
    Map<String, dynamic> current = map;
    for (final key in keys) {
      current = current.putIfAbsent(key, () => <String, dynamic>{}) as Map<String, dynamic>;
    }
    
    current[lastKey] = value;
  }
} 