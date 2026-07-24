import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:common_ui/common_ui.dart';
import '../../../core/base/base_view.dart';
import '../controller/basketball_controller.dart';
import '../../../core/theme/app_colors.dart';

class BasketballHistoryPage extends BaseView<BasketballController> {
  const BasketballHistoryPage({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppAppBar(
      titleText: 'basketball'.tr + ' ' + 'history'.tr,
      actions: [
        IconButton(
          onPressed: () {
            _showClearHistoryDialog();
          },
          icon: const Icon(Icons.delete_sweep),
        ),
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Obx(() {
      if (controller.records.isEmpty) {
        return AppEmptyState(
          icon: Icons.history,
          message: 'no_history_records'.tr,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.records.length,
        itemBuilder: (context, index) {
          final record = controller.records[controller.records.length - 1 - index];
          return _buildHistoryItem(record, index);
        },
      );
    });
  }

  Widget _buildHistoryItem(BasketballRecord record, int index) {
    final timeString = _formatTime(record.timestamp);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header information
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 20,
                  child: const Icon(
                    Icons.sports_basketball,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${record.team1Name} vs ${record.team2Name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeString,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showDeleteDialog(record),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Score display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        record.team1Name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.team1Score.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'vs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        record.team2Name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.team2Score.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Game time
            if (record.gameTime > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${record.gameTime} ${'minutes'.tr}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${'days_ago'.tr}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${'hours_ago'.tr}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${'minutes_ago'.tr}';
    } else {
      return 'just_now'.tr;
    }
  }

  void _showClearHistoryDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('confirm_delete'.tr),
        content: Text('confirm_delete_content'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearHistory();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BasketballRecord record) {
    Get.dialog(
      AlertDialog(
        title: Text('confirm_delete'.tr),
        content: Text('confirm_delete_content'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteRecord(record);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }
}
