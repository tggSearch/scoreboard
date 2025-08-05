import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PermissionUtils {
  // 默认网络权限已授予
  static bool _hasNetworkPermission = true;

  /// 检查网络权限
  static bool get hasNetworkPermission => _hasNetworkPermission;

  /// 请求网络权限（默认已授予）
  static Future<bool> requestNetworkPermission() async {
    // 默认网络权限已授予，无需用户手动授权
    _hasNetworkPermission = true;
    return true;
  }

  /// 显示权限说明对话框（仅在需要时显示）
  static Future<void> showPermissionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('网络权限'),
          content: const Text(
            '应用需要网络权限来获取排行榜数据。\n\n'
            '注意：应用主要功能为离线计分，网络仅用于数据同步。',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final granted = await requestNetworkPermission();
                if (granted) {
                  Get.snackbar(
                    '成功',
                    '网络权限已授予',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar(
                    '失败',
                    '网络权限被拒绝，应用将以离线模式运行',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                  );
                }
              },
              child: const Text('授予权限'),
            ),
          ],
        );
      },
    );
  }

  /// 检查并请求权限（默认已授予，不显示对话框）
  static Future<void> checkAndRequestPermissions(BuildContext context) async {
    // 默认网络权限已授予，无需显示权限对话框
    _hasNetworkPermission = true;
    
    // 可以在这里添加其他权限检查逻辑
    // 例如：相机权限、存储权限等
  }
} 