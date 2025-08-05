class StringUtils {
  /// Format phone number with mask
  static String formatPhoneNumber(String phone) {
    if (phone.isEmpty) return '';
    if (phone.length < 7) return phone;
    
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
  }

  /// Check if string is empty or null
  static bool isEmpty(String? str) {
    return str == null || str.trim().isEmpty;
  }

  /// Check if string is not empty
  static bool isNotEmpty(String? str) {
    return !isEmpty(str);
  }

  /// Capitalize first letter
  static String capitalize(String str) {
    if (isEmpty(str)) return '';
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }

  /// Truncate string with ellipsis
  static String truncate(String str, int maxLength, {String suffix = '...'}) {
    if (str.length <= maxLength) return str;
    return '${str.substring(0, maxLength)}$suffix';
  }

  /// Remove all whitespace
  static String removeWhitespace(String str) {
    return str.replaceAll(RegExp(r'\s+'), '');
  }

  /// Extract numbers from string
  static String extractNumbers(String str) {
    return str.replaceAll(RegExp(r'[^0-9]'), '');
  }
} 