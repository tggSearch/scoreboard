import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:common_ui/common_ui.dart';
import '../../../core/base/base_view.dart';
import '../controller/user_profile_controller.dart';
import '../../../core/controllers/language_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';

class UserProfilePage extends BaseView<UserProfileController> {
  const UserProfilePage({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppAppBar(titleText: 'settings'.tr);
  }

  @override
  Widget buildContent(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(AppSpacing.lg),
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
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.splashGradient,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.primaryGlow(AppColors.primary),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Image.asset(
                'assets/icons/score_board.png',
                fit: BoxFit.cover,
              ),
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
    return AppSurfaceCard(
      padding: EdgeInsets.zero,
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
            icon: Icons.bug_report,
            title: 'Language Test',
            subtitle: 'Test language switching functionality',
            onTap: () => Get.toNamed('/language-test'),
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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
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
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: AppColors.divider,
    );
  }

  Widget _buildAboutSection() {
    return AppSurfaceCard(
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
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.email,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'contact_us'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
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
                        color: isSelected ? AppColors.primary : Colors.grey.shade200,
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
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
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
                            color: AppColors.primary,
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
                          backgroundColor: AppColors.primary,
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
                backgroundColor: AppColors.primary,
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