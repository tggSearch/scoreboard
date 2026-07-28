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
        scrollable: true,
        title: Text('privacy_policy_title'.tr),
        content: Text('privacy_policy_content'.tr),
        actions: [
          TextButton(
            onPressed: () => DialogNavigator.close(),
            child: Text('ok'.tr),
          ),
        ],
      ),
    );
  }

  void _showUserAgreement() {
    Get.dialog(
      AlertDialog(
        scrollable: true,
        title: Text('user_agreement_title'.tr),
        content: Text('user_agreement_content'.tr),
        actions: [
          TextButton(
            onPressed: () => DialogNavigator.close(),
            child: Text('ok'.tr),
          ),
        ],
      ),
    );
  }

  void _showFeedback() {
    Get.dialog(
      AlertDialog(
        scrollable: true,
        title: Text('feedback_title'.tr),
        content: Text(
          'feedback_content'.tr,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => DialogNavigator.close(),
            child: Text('ok'.tr),
          ),
        ],
      ),
    );
  }

  void _showLanguageSettings() {
    final languageController = Get.find<LanguageController>();
    final maxHeight = MediaQuery.sizeOf(Get.context!).height * 0.65;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 360, maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'language'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => DialogNavigator.close(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                      ...languageController.getSupportedLanguages().map((language) {
                        final isSelected =
                            language['code'] == languageController.getCurrentLanguageCode();

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
                                DialogNavigator.closeThen(() {
                                  Get.snackbar(
                                    'success'.tr,
                                    '${'language'.tr} ${'update'.tr} ${'success'.tr}',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: AppColors.primary,
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 2),
                                  );
                                });
                              }
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => DialogNavigator.close(),
                    child: Text('close'.tr),
                  ),
                ),
              ),
            ],
          ),
        ),
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
            onPressed: () => DialogNavigator.close(),
            child: Text('rate_later'.tr),
          ),
          TextButton(
            onPressed: () {
              DialogNavigator.closeThen(() {
                Get.snackbar(
                  'tip'.tr,
                  '请前往应用商店为应用评分',
                  backgroundColor: AppColors.primary,
                  colorText: Colors.white,
                );
              });
            },
            child: Text('rate_now'.tr),
          ),
        ],
      ),
    );
  }
} 