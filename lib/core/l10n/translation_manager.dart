import 'package:get/get.dart';
import '../translations/zh_cn.dart';
import '../translations/en_us.dart';

class TranslationManager {
  static TranslationManager? _instance;
  static TranslationManager get instance => _instance ??= TranslationManager._();

  TranslationManager._();

  static Map<String, String> get currentTranslations {
    final locale = Get.locale;
    if (locale != null) {
      final languageCode = '${locale.languageCode}_${locale.countryCode}';
      return _getTranslationsByLanguage(languageCode);
    }
    return EnUS.translations;
  }

  static Map<String, String> _getTranslationsByLanguage(String languageCode) {
    switch (languageCode) {
      case 'zh_CN':
        return ZhCN.translations;
      case 'en_US':
        return EnUS.translations;
      default:
        return EnUS.translations;
    }
  }

  static String getText(String key, {Map<String, dynamic>? args}) {
    final translations = currentTranslations;
    String text = translations[key] ?? key;
    
    if (args != null) {
      args.forEach((key, value) {
        text = text.replaceAll('{$key}', value.toString());
      });
    }
    
    return text;
  }

  static bool hasKey(String key) {
    return currentTranslations.containsKey(key);
  }

  static List<String> getAvailableKeys() {
    return currentTranslations.keys.toList();
  }

  static List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'zh_CN', 'nativeName': '简体中文'},
      {'code': 'en_US', 'nativeName': 'English'},
    ];
  }

  static String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'zh_CN':
        return '简体中文';
      case 'en_US':
        return 'English';
      default:
        return languageCode;
    }
  }

  static Map<String, List<String>> validateTranslations() {
    final zhKeys = ZhCN.translations.keys.toList();
    final enKeys = EnUS.translations.keys.toList();
    
    final missingInEn = zhKeys.where((key) => !enKeys.contains(key)).toList();
    final missingInZh = enKeys.where((key) => !zhKeys.contains(key)).toList();
    
    return {
      'missing_in_en': missingInEn,
      'missing_in_zh': missingInZh,
    };
  }

  static Map<String, int> getTranslationStats() {
    return {
      'zh_CN': ZhCN.translations.length,
      'en_US': EnUS.translations.length,
    };
  }
} 