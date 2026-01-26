import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:common_utils/common_utils.dart';
import 'package:fl_umeng/fl_umeng.dart';
import 'dart:io';
import 'dart:async';
import 'core/routes/app_routes.dart';
import 'core/l10n/translations.dart';
import 'core/l10n/app_localizations.dart';
import 'core/controllers/language_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageUtils.init(); // Initialize storage
  
  // 初始化友盟统计（异步执行，不阻塞应用启动）
  _initUmeng().catchError((error) {
    // 即使初始化失败也不影响应用启动
    debugPrint('友盟统计初始化失败，但不影响应用运行: $error');
  });
  
  // 初始化语言控制器
  final languageController = Get.put(LanguageController());
  
  // 等待语言控制器初始化完成
  await languageController.onInit();
  
  runApp(const MyApp());
}

/// 初始化友盟统计
/// 添加超时和异常处理，确保不会导致ANR或crash
Future<void> _initUmeng() async {
  try {
    // 设置日志开启（生产环境建议关闭）
    // 不设置超时，因为这是一个快速操作，即使失败也不影响初始化
    try {
      await FlUMeng().setLogEnabled(true);
    } catch (e) {
      debugPrint('友盟设置日志异常: $e，继续初始化');
    }
    
    // 初始化友盟，设置5秒超时，避免长时间等待导致ANR
    try {
      final initFuture = FlUMeng().init(
        androidAppKey: '6909af0a8560e34872debbf6',
        iosAppKey: '6909afb48560e34872debc5e',
        channel: Platform.isAndroid ? 'default' : 'App Store',
      );
      
      final result = await initFuture.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('友盟初始化超时');
          return false; // 超时返回false
        },
      );
      
      if (result == true) {
        debugPrint('友盟统计初始化成功');
      } else {
        debugPrint('友盟统计初始化失败（返回false）');
      }
    } on TimeoutException {
      debugPrint('友盟初始化超时，但不影响应用运行');
    } on PlatformException catch (e) {
      // 平台异常（如网络问题、SDK问题等）
      debugPrint('友盟统计初始化平台异常: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('友盟统计初始化异常: $e');
    }
  } on TimeoutException {
    debugPrint('友盟统计初始化超时，但不影响应用运行');
  } on PlatformException catch (e) {
    // 平台异常（如网络问题、SDK问题等）
    debugPrint('友盟统计初始化平台异常: ${e.code} - ${e.message}');
  } catch (e, stackTrace) {
    // 捕获所有其他异常，确保不会导致crash
    debugPrint('友盟统计初始化发生未知异常: $e');
    debugPrint('堆栈跟踪: $stackTrace');
    // 不重新抛出异常，确保应用可以正常启动
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
