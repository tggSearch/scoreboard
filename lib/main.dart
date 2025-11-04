import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:common_utils/common_utils.dart';
import 'package:fl_umeng/fl_umeng.dart';
import 'dart:io';
import 'core/routes/app_routes.dart';
import 'core/l10n/translations.dart';
import 'core/l10n/app_localizations.dart';
import 'core/controllers/language_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageUtils.init(); // Initialize storage
  
  // 初始化友盟统计
  await _initUmeng();
  
  // 初始化语言控制器
  final languageController = Get.put(LanguageController());
  
  // 等待语言控制器初始化完成
  await languageController.onInit();
  
  runApp(const MyApp());
}

/// 初始化友盟统计
Future<void> _initUmeng() async {
  try {
    // 设置日志开启（生产环境建议关闭）
    await FlUMeng().setLogEnabled(true);
    
    // 初始化友盟
    final result = await FlUMeng().init(
      androidAppKey: '6909af0a8560e34872debbf6',
      iosAppKey: '6909afb48560e34872debc5e',
      channel: Platform.isAndroid ? 'default' : 'App Store',
    );
    
    if (result == true) {
      debugPrint('友盟统计初始化成功');
    } else {
      debugPrint('友盟统计初始化失败');
    }
  } catch (e) {
    debugPrint('友盟统计初始化异常: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    
    return Obx(() => GetMaterialApp(
      title: 'Score Board',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // 浅绿色主题
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF4CAF50),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      // 多语言支持
      translations: AppTranslations(),
      locale: _getLocaleFromLanguageCode(languageController.currentLanguage.value),
      fallbackLocale: const Locale('en', 'US'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    ));
  }
  
  Locale _getLocaleFromLanguageCode(String languageCode) {
    final parts = languageCode.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return const Locale('en', 'US');
  }
}
