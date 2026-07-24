import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:common_ui/common_ui.dart';
import '../../../core/base/base_view.dart';
import '../controller/tennis_controller.dart';
import '../../../core/theme/app_colors.dart';

class TennisHistoryPage extends BaseView<TennisController> {
  const TennisHistoryPage({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppAppBar(titleText: 'tennis_history'.tr);
  }

  @override
  Widget buildContent(BuildContext context) {
    return Obx(() {
      if (controller.records.isEmpty) {
        return AppEmptyState(
          icon: Icons.history,
          message: 'no_records'.tr,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.records.length,
        itemBuilder: (context, index) {
          final record = controller.records[index];
          final isLastRecord = index == controller.records.length - 1;

          return AppHistoryListTile(
            index: index,
            title: record.description,
            subtitle:
                '${controller.team1Name.value}: ${record.team1Score}  ·  ${controller.team2Name.value}: ${record.team2Score}\n${_formatDateTime(record.timestamp)}',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLastRecord
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${record.team1Score}-${record.team2Score}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isLastRecord ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'days_ago'.tr.replaceAll('{days}', difference.inDays.toString());
    } else if (difference.inHours > 0) {
      return 'hours_ago'.tr.replaceAll('{hours}', difference.inHours.toString());
    } else if (difference.inMinutes > 0) {
      return 'minutes_ago'.tr.replaceAll('{minutes}', difference.inMinutes.toString());
    } else {
      return 'just_now'.tr;
    }
  }
}
