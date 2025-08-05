import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppLocalizations {
  static const Locale zhCN = Locale('zh', 'CN');
  static const Locale enUS = Locale('en', 'US');
  
  static const List<Locale> supportedLocales = [
    zhCN,
    enUS,
  ];
  
  static const String fallbackLocale = 'zh_CN';
  
  // 语言映射
  static const Map<String, String> languageNames = {
    'zh_CN': '简体中文',
    'en_US': 'English',
  };
  
  // 获取当前语言
  static String getCurrentLanguage() {
    final locale = Get.locale;
    if (locale != null) {
      return '${locale.languageCode}_${locale.countryCode}';
    }
    return fallbackLocale;
  }
  
  // 切换语言
  static void changeLanguage(String languageCode) {
    final parts = languageCode.split('_');
    if (parts.length == 2) {
      final locale = Locale(parts[0], parts[1]);
      Get.updateLocale(locale);
    }
  }
  
  // 获取语言显示名称
  static String getLanguageDisplayName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }
} 