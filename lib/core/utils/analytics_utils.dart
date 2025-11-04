import 'package:fl_umeng/fl_umeng.dart';
import 'package:flutter/foundation.dart';

/// 友盟统计工具类
class AnalyticsUtils {
  /// 获取友盟实例
  static final _umeng = FlUMeng();

  /// 记录页面开始
  /// [pageName] 页面名称
  static Future<void> onPageStart(String pageName) async {
    try {
      await _umeng.onPageStart(pageName);
      debugPrint('友盟统计 - 页面开始: $pageName');
    } catch (e) {
      debugPrint('友盟统计 - 页面开始失败: $e');
    }
  }

  /// 记录页面结束
  /// [pageName] 页面名称
  static Future<void> onPageEnd(String pageName) async {
    try {
      await _umeng.onPageEnd(pageName);
      debugPrint('友盟统计 - 页面结束: $pageName');
    } catch (e) {
      debugPrint('友盟统计 - 页面结束失败: $e');
    }
  }

  /// 记录自定义事件
  /// [eventId] 事件ID
  /// [parameters] 事件参数（可选）
  static Future<void> onEvent(String eventId, {Map<String, dynamic>? parameters}) async {
    try {
      await _umeng.onEvent(eventId, parameters ?? {});
      debugPrint('友盟统计 - 自定义事件: $eventId${parameters != null ? ", 参数: $parameters" : ""}');
    } catch (e) {
      debugPrint('友盟统计 - 自定义事件失败: $e');
    }
  }

  /// 上报错误（仅Android）
  /// [error] 错误信息
  static Future<void> reportError(String error) async {
    try {
      await _umeng.reportError(error);
      debugPrint('友盟统计 - 上报错误: $error');
    } catch (e) {
      debugPrint('友盟统计 - 上报错误失败: $e');
    }
  }
}

