import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/translation_manager.dart';

class LanguageController extends GetxController {
  static LanguageController get to => Get.find();
  final RxString currentLanguage = 'en_US'.obs;
  final List<String> supportedLanguages = ['zh_CN', 'en_US'];

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadLanguage();
    
    // 确保 Get.locale 与当前语言同步
    final parts = currentLanguage.value.split('_');
    if (parts.length == 2) {
      final locale = Locale(parts[0], parts[1]);
      Get.updateLocale(locale);
    }
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedLanguage = prefs.getString('language');
      print('Loaded saved language from SharedPreferences: $savedLanguage');
      
      // 如果没有保存的语言设置，则根据系统语言自动选择
      if (savedLanguage == null) {
        savedLanguage = _getSystemLanguage();
        print('No saved language found, using system language: $savedLanguage');
        // 保存系统语言设置
        await prefs.setString('language', savedLanguage);
        print('System language saved to SharedPreferences: $savedLanguage');
      }
      
      currentLanguage.value = savedLanguage;
      
      // 设置语言
      final parts = savedLanguage.split('_');
      if (parts.length == 2) {
        final locale = Locale(parts[0], parts[1]);
        Get.updateLocale(locale);
        print('Get.locale updated to: ${locale.languageCode}_${locale.countryCode}');
      }
      
      print('Language loaded successfully: $savedLanguage');
    } catch (e) {
      print('Error loading language: $e');
      // 如果出错，使用默认英文
      currentLanguage.value = 'en_US';
      Get.updateLocale(const Locale('en', 'US'));
    }
  }

  // 根据系统语言获取合适的语言代码
  String _getSystemLanguage() {
    final systemLocale = WidgetsBinding.instance.window.locale;
    final languageCode = systemLocale.languageCode.toLowerCase();
    final countryCode = systemLocale.countryCode?.toLowerCase() ?? '';
    
    print('System locale: ${systemLocale.languageCode}_${systemLocale.countryCode}');
    print('Detected language code: $languageCode, country code: $countryCode');
    
    // 如果系统语言是中文，使用中文
    if (languageCode == 'zh' || languageCode == 'zh-cn' || languageCode == 'zh-hans') {
      print('System language detected as Chinese, using zh_CN');
      return 'zh_CN';
    }
    
    // 其他情况使用英文
    print('System language detected as non-Chinese, using en_US');
    return 'en_US';
  }

  // 获取当前语言代码，确保与 Get.locale 同步
  String getCurrentLanguageCode() {
    final locale = Get.locale;
    if (locale != null) {
      final languageCode = '${locale.languageCode}_${locale.countryCode}';
      // 同步 currentLanguage 的值
      if (currentLanguage.value != languageCode) {
        currentLanguage.value = languageCode;
      }
      return languageCode;
    }
    return currentLanguage.value;
  }

  Future<void> changeLanguage(String languageCode) async {
    final parts = languageCode.split('_');
    if (parts.length == 2) {
      final locale = Locale(parts[0], parts[1]);
      Get.updateLocale(locale);
      currentLanguage.value = languageCode;
      
      // 保存到本地存储
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('language', languageCode);
        print('Language saved to SharedPreferences: $languageCode');
        
        // 验证保存是否成功
        final savedLanguage = prefs.getString('language');
        print('Verified saved language: $savedLanguage');
      } catch (e) {
        print('Error saving language: $e');
      }
      
      print('Language changed to: $languageCode');
    }
  }

  String getCurrentLanguageName() {
    return TranslationManager.getLanguageDisplayName(getCurrentLanguageCode());
  }

  List<Map<String, String>> getSupportedLanguages() {
    return TranslationManager.getSupportedLanguages();
  }

  bool get isChinese => currentLanguage.value == 'zh_CN';
  bool get isEnglish => currentLanguage.value == 'en_US';
} 