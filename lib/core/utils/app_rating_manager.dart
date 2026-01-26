import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// 应用内评分管理工具类
class AppRatingManager {
  static const String _keyUsageCount = 'app_usage_count';
  static const String _keyHasRated = 'app_has_rated';
  static const String _keyRatingDismissed = 'app_rating_dismissed';
  static const int _triggerCount = 2; // 第二次使用时触发
  
  /// 记录使用次数并检查是否需要弹出评分
  /// [context] 用于显示对话框的上下文
  static Future<void> checkAndShowRating(BuildContext? context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 检查是否已经评分过
      final hasRated = prefs.getBool(_keyHasRated) ?? false;
      if (hasRated) {
        return; // 已经评分过，不再弹出
      }
      
      // 检查是否已经拒绝过评分
      final ratingDismissed = prefs.getBool(_keyRatingDismissed) ?? false;
      if (ratingDismissed) {
        return; // 用户已经拒绝过，不再弹出
      }
      
      // 增加使用次数
      final currentCount = prefs.getInt(_keyUsageCount) ?? 0;
      final newCount = currentCount + 1;
      await prefs.setInt(_keyUsageCount, newCount);
      
      // 如果达到触发次数，显示评分对话框
      if (newCount >= _triggerCount) {
        // 延迟一下，确保页面已经加载完成
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (context != null && context.mounted) {
          _showRatingDialog(context, prefs);
        } else {
          // 如果没有context，使用Get.context
          final getContext = Get.context;
          if (getContext != null) {
            _showRatingDialog(getContext, prefs);
          }
        }
      }
    } catch (e) {
      debugPrint('检查应用评分失败: $e');
    }
  }
  
  /// 显示评分对话框
  static void _showRatingDialog(BuildContext context, SharedPreferences prefs) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'rate_app_title'.tr,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'rate_app_content'.tr,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // 用户选择"稍后"，标记为已拒绝，但不清除计数
              await prefs.setBool(_keyRatingDismissed, true);
              Get.back();
            },
            child: Text(
              'rate_later'.tr,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () async {
              // 用户选择"不再提示"，清除计数并标记为已拒绝
              await prefs.setBool(_keyRatingDismissed, true);
              await prefs.setInt(_keyUsageCount, 0);
              Get.back();
            },
            child: Text(
              'never_ask'.tr,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              // 标记为已评分
              await prefs.setBool(_keyHasRated, true);
              
              // 调用应用内评分
              await _requestReview();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: Text('rate_now'.tr),
          ),
        ],
      ),
      barrierDismissible: false, // 不允许点击外部关闭
    );
  }
  
  /// 请求应用内评分
  static Future<void> _requestReview() async {
    try {
      final InAppReview inAppReview = InAppReview.instance;
      
      // 检查是否可用
      if (await inAppReview.isAvailable()) {
        // 显示应用内评分弹窗
        await inAppReview.requestReview();
      } else {
        // 如果应用内评分不可用，可以跳转到应用商店
        // 这里暂时不处理，因为用户已经点击了"去评分"
        debugPrint('应用内评分不可用');
      }
    } catch (e) {
      debugPrint('请求应用内评分失败: $e');
    }
  }
  
  /// 重置评分状态（用于测试）
  static Future<void> resetRatingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUsageCount);
      await prefs.remove(_keyHasRated);
      await prefs.remove(_keyRatingDismissed);
    } catch (e) {
      debugPrint('重置评分状态失败: $e');
    }
  }
  
  /// 获取当前使用次数（用于调试）
  static Future<int> getUsageCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyUsageCount) ?? 0;
    } catch (e) {
      debugPrint('获取使用次数失败: $e');
      return 0;
    }
  }
}
