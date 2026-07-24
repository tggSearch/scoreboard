import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:common_ui/common_ui.dart';
import '../../../core/base/base_view.dart';
import '../controller/football_controller.dart';
import '../../../core/theme/app_colors.dart';

class FootballHistoryPage extends BaseView<FootballController> {
  const FootballHistoryPage({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppAppBar(
      titleText: 'football'.tr + ' ' + 'history'.tr,
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

  Widget _buildHistoryItem(FootballRecord record, int index) {
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
                    Icons.sports_soccer,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${record.team1Score} - ${record.team2Score}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            if (record.description.isNotEmpty)
              Text(
                record.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            const SizedBox(height: 8),
            // Additional info
            Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${record.duration} ' + 'seconds'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.sports_soccer,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${record.totalGoals} ' + 'goals'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
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

    if (difference.inMinutes < 1) {
      return 'just_now'.tr;
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ' + 'minutes_ago'.tr;
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ' + 'hours_ago'.tr;
    } else {
      return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
    }
  }

  void _showClearHistoryDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('clear_history_records'.tr),
        content: Text('confirm_clear_history_records'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearHistory();
              Get.back();
              Get.snackbar(
                'clear_history_success'.tr,
                'all_history_records_cleared'.tr,
                snackPosition: SnackPosition.TOP,
                backgroundColor: AppColors.primary,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('clear'.tr),
          ),
        ],
      ),
    );
  }
} 