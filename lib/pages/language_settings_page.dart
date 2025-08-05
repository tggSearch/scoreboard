import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/controllers/language_controller.dart';
import '../core/l10n/translation_manager.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('language'.tr),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 当前语言显示
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.language, color: Colors.blue.shade600, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'language'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        languageController.getCurrentLanguageName(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 语言选项列表
          ...TranslationManager.getSupportedLanguages().map((language) {
            final isSelected = language['code'] == languageController.currentLanguage.value;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      language['code']!.substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                                 title: Text(
                   language['nativeName']!,
                   style: TextStyle(
                     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                     color: isSelected ? const Color(0xFF4CAF50) : Colors.black87,
                   ),
                 ),
                subtitle: Text(
                  _getLanguageDescription(language['code']!),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 24,
                      )
                    : null,
                onTap: () async {
                  if (!isSelected) {
                    await languageController.changeLanguage(language['code']!);
                    Get.snackbar(
                      'success'.tr,
                      '${'language'.tr} ${'update'.tr} ${'success'.tr}',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: const Color(0xFF4CAF50),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  }
                },
              ),
            );
          }).toList(),
          
          const SizedBox(height: 20),
          
          // 说明信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'note'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'language_change_note'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
  
  String _getLanguageDescription(String languageCode) {
    switch (languageCode) {
      case 'zh_CN':
        return '简体中文 - 中文界面';
      case 'en_US':
        return 'English - English Interface';
      default:
        return '';
    }
  }
} 