import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/l10n/translation_manager.dart';
import '../core/controllers/language_controller.dart';

class TranslationDebugPage extends StatelessWidget {
  const TranslationDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('翻译调试'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 翻译统计
            _buildTranslationStats(),
            const SizedBox(height: 20),
            
            // 翻译验证
            _buildTranslationValidation(),
            const SizedBox(height: 20),
            
            // 当前语言信息
            _buildCurrentLanguageInfo(languageController),
            const SizedBox(height: 20),
            
            // 翻译键列表
            _buildTranslationKeysList(),
            const SizedBox(height: 20),
            
            // 测试翻译功能
            _buildTranslationTest(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTranslationStats() {
    final stats = TranslationManager.getTranslationStats();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '翻译统计',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...stats.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${entry.key}: ',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text('${entry.value} 个翻译键'),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTranslationValidation() {
    final validation = TranslationManager.validateTranslations();
    final missingInEn = validation['missing_in_english'] ?? [];
    final missingInZh = validation['missing_in_chinese'] ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '翻译验证',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (missingInEn.isEmpty && missingInZh.isEmpty)
              const Text(
                '✅ 所有翻译键都完整',
                style: TextStyle(color: Colors.green),
              )
            else ...[
              if (missingInEn.isNotEmpty) ...[
                const Text(
                  '❌ 英文缺少以下翻译键:',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                ...missingInEn.map((key) => Text('  • $key')).toList(),
                const SizedBox(height: 12),
              ],
              if (missingInZh.isNotEmpty) ...[
                const Text(
                  '❌ 中文缺少以下翻译键:',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                ...missingInZh.map((key) => Text('  • $key')).toList(),
              ],
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildCurrentLanguageInfo(LanguageController languageController) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '当前语言信息',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('语言代码: ${languageController.currentLanguage.value}'),
            Text('显示名称: ${languageController.getCurrentLanguageName()}'),
            Text('是否为中文: ${languageController.isChinese}'),
            Text('是否为英文: ${languageController.isEnglish}'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTranslationKeysList() {
    final keys = TranslationManager.getAvailableKeys();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '翻译键列表',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text('共 ${keys.length} 个'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: keys.length,
                itemBuilder: (context, index) {
                  final key = keys[index];
                  final translation = TranslationManager.getText(key);
                  
                  return ListTile(
                    dense: true,
                    title: Text(
                      key,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      translation,
                      style: const TextStyle(fontSize: 11),
                    ),
                    onTap: () {
                      Get.snackbar(
                        '翻译键',
                        '$key: $translation',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: const Color(0xFF4CAF50),
                        colorText: Colors.white,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTranslationTest() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '翻译测试',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'app_name',
                'cancel',
                'confirm',
                'save',
                'delete',
                'edit',
                'reset',
                'language',
                'settings',
                'history',
              ].map((key) => ElevatedButton(
                onPressed: () {
                  final translation = TranslationManager.getText(key);
                  Get.snackbar(
                    '翻译测试',
                    '$key: $translation',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: const Color(0xFF4CAF50),
                    colorText: Colors.white,
                  );
                },
                child: Text(key),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
} 