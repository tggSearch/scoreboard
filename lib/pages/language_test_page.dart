import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/controllers/language_controller.dart';

class LanguageTestPage extends StatelessWidget {
  const LanguageTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Language Test'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 当前语言显示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Language:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                      'Code: ${languageController.currentLanguage.value}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )),
                    Obx(() => Text(
                      'Name: ${languageController.getCurrentLanguageName()}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )),
                    Obx(() => Text(
                      'Get.locale: ${Get.locale?.languageCode}_${Get.locale?.countryCode}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 语言切换按钮
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Switch Language:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await languageController.changeLanguage('zh_CN');
                              Get.snackbar(
                                'Success',
                                'Language changed to Chinese',
                                snackPosition: SnackPosition.TOP,
                              );
                            },
                            child: const Text('Switch to Chinese'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await languageController.changeLanguage('en_US');
                              Get.snackbar(
                                'Success',
                                'Language changed to English',
                                snackPosition: SnackPosition.TOP,
                              );
                            },
                            child: const Text('Switch to English'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 测试翻译
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Translation Test:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Text('app_name'.tr),
                    Text('language'.tr),
                    Text('settings'.tr),
                    Text('about'.tr),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 系统信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Information:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('System Locale: ${WidgetsBinding.instance.window.locale}'),
                    Text('Platform: ${GetPlatform.isAndroid ? 'Android' : GetPlatform.isIOS ? 'iOS' : GetPlatform.isWeb ? 'Web' : 'Unknown'}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 