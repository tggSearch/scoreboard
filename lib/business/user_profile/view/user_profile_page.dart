import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/base/base_view.dart';
import '../controller/user_profile_controller.dart';
import '../../../core/controllers/language_controller.dart';

class UserProfilePage extends BaseView<UserProfileController> {
  const UserProfilePage({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('settings'.tr),
      backgroundColor: const Color(0xFF4CAF50),
      foregroundColor: Colors.white,
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 应用信息卡片
          _buildAppInfoCard(),
          const SizedBox(height: 16),
          
          // 功能列表
          _buildFunctionList(),
          const SizedBox(height: 16),
          
          // 关于我们
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF66BB6A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 应用图标
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sports_score,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          
          // 应用信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'app_name_pro'.tr,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'app_description'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
          // 箭头图标
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withOpacity(0.8),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFunctionItem(
            icon: Icons.privacy_tip,
            title: 'privacy_policy'.tr,
            subtitle: 'privacy_policy_subtitle'.tr,
            onTap: () => _showPrivacyPolicy(),
          ),
          _buildDivider(),
          _buildFunctionItem(
            icon: Icons.description,
            title: 'user_agreement'.tr,
            subtitle: 'user_agreement_subtitle'.tr,
            onTap: () => _showUserAgreement(),
          ),
          _buildDivider(),
          _buildFunctionItem(
            icon: Icons.feedback,
            title: 'feedback'.tr,
            subtitle: 'feedback_subtitle'.tr,
            onTap: () => _showFeedback(),
          ),
          _buildDivider(),
          _buildFunctionItem(
            icon: Icons.language,
            title: 'language'.tr,
            subtitle: 'language_subtitle'.tr,
            onTap: () => _showLanguageSettings(),
          ),
          _buildDivider(),
          _buildFunctionItem(
            icon: Icons.star,
            title: 'rate_app'.tr,
            subtitle: 'rate_app_subtitle'.tr,
            onTap: () => _rateApp(),
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF4CAF50),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'about'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'about_content'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.email,
                color: Colors.grey[600],
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'contact_us'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    Get.dialog(
      AlertDialog(
        title: Text('privacy_policy_title'.tr),
        content: SingleChildScrollView(
          child: Text('privacy_policy_content'.tr),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('ok'.tr),
          ),
        ],
      ),
    );
  }

  void _showUserAgreement() {
    Get.dialog(
      AlertDialog(
        title: Text('user_agreement_title'.tr),
        content: SingleChildScrollView(
          child: Text('user_agreement_content'.tr),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('ok'.tr),
          ),
        ],
      ),
    );
  }

  void _showFeedback() {
    Get.dialog(
      AlertDialog(
        title: Text('feedback_title'.tr),
        content: SingleChildScrollView(
          child: Text(
            'feedback_content'.tr,
            style: const TextStyle(fontSize: 14),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('ok'.tr),
          ),
        ],
      ),
    );
  }

  void _showLanguageSettings() {
    final languageController = Get.find<LanguageController>();
    
    Get.dialog(
      AlertDialog(
        title: Text('language'.tr),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 当前语言显示
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.language, color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'language'.tr,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() {
                            final currentCode = languageController.getCurrentLanguageCode();
                            return Text(
                              languageController.getCurrentLanguageName(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // 语言选项
              ...languageController.getSupportedLanguages().map((language) {
                final isSelected = language['code'] == languageController.getCurrentLanguageCode();
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          language['code']!.substring(0, 2).toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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
                            size: 20,
                          )
                        : null,
                    onTap: () async {
                      if (!isSelected) {
                        await languageController.changeLanguage(language['code']!);
                        Get.back();
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('close'.tr),
          ),
        ],
      ),
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

  void _rateApp() {
    Get.dialog(
      AlertDialog(
        title: Text('rate_app_title'.tr),
        content: Text('rate_app_content'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('rate_later'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // 这里可以添加跳转到应用商店的逻辑
              Get.snackbar(
                'tip'.tr,
                '请前往应用商店为应用评分',
                backgroundColor: const Color(0xFF4CAF50),
                colorText: Colors.white,
              );
            },
            child: Text('rate_now'.tr),
          ),
        ],
      ),
    );
  }
} 