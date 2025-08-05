import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../l10n/translation_manager.dart';

class LanguageController extends GetxController {
  static LanguageController get to => Get.find();
  final RxString currentLanguage = 'zh_CN'.obs;
  final List<String> supportedLanguages = ['zh_CN', 'en_US'];

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('language') ?? 'zh_CN';
      currentLanguage.value = savedLanguage;
      
      // 设置语言
      final parts = savedLanguage.split('_');
      if (parts.length == 2) {
        final locale = Locale(parts[0], parts[1]);
        Get.updateLocale(locale);
      }
      
      print('Language loaded: $savedLanguage');
    } catch (e) {
      print('Error loading language: $e');
      // 如果出错，使用默认中文
      currentLanguage.value = 'zh_CN';
      Get.updateLocale(const Locale('zh', 'CN'));
    }
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
      
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