import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/controllers/language_controller.dart';

class TestLanguagePage extends StatelessWidget {
  const TestLanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('app_name'.tr),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/language-settings'),
            icon: const Icon(Icons.language),
          ),
          IconButton(
            onPressed: () => Get.toNamed('/translation-debug'),
            icon: const Icon(Icons.bug_report),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 当前语言信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'language'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '当前语言: ${languageController.getCurrentLanguageName()}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 测试翻译内容
            Text(
              '测试翻译内容',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 游戏类型测试
            _buildTestSection('游戏类型', [
              'mahjong',
              'doudizhu',
              'basketball',
              'football',
              'tennis',
              'badminton',
              'pingpong',
              'volleyball',
              'texas_holdem',
              'uno',
              'bridge',
              'custom_score',
            ]),
            
            const SizedBox(height: 20),
            
            // 通用词汇测试
            _buildTestSection('通用词汇', [
              'cancel',
              'confirm',
              'save',
              'delete',
              'edit',
              'reset',
              'close',
              'copy',
              'settings',
              'history',
              'records',
            ]),
            
            const SizedBox(height: 20),
            
            // 玩家相关测试
            _buildTestSection('玩家相关', [
              'player',
              'player_name',
              'player_score',
              'add_player',
              'edit_player',
              'delete_player',
              'leading_player',
              'highest_score',
            ]),
            
            const SizedBox(height: 20),
            
            // 游戏设置测试
            _buildTestSection('游戏设置', [
              'game_settings',
              'base_score',
              'multiplier',
              'custom_multiplier',
              'game_statistics',
              'game_records',
            ]),
            
            const SizedBox(height: 20),
            
            // 斗地主相关测试
            _buildTestSection('斗地主相关', [
              'landlord',
              'farmers',
              'landlord_wins',
              'farmers_win',
              'select_landlord',
              'landlord_score',
              'farmer_score',
            ]),
            
            const SizedBox(height: 20),
            
            // 麻将相关测试
            _buildTestSection('麻将相关', [
              'win_game',
              'gang',
              'self_draw',
              'point_pao',
              'win_type',
              'fan_count',
              'zhuama',
              'ming_gang',
              'an_gang',
              'dian_gang',
              'gang_score',
              'total_fans',
            ]),
            
            const SizedBox(height: 20),
            
            // 按钮测试
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed('/language-settings'),
                    child: Text('language'.tr),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.snackbar(
                        'success'.tr,
                        'test_message'.tr,
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: const Color(0xFF4CAF50),
                        colorText: Colors.white,
                      );
                    },
                    child: Text('test'.tr),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTestSection(String title, List<String> keys) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...keys.map((key) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text(
                    '$key: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      key.tr,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
} 