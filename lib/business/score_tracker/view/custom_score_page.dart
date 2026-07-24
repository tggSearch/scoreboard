import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/base/base_view.dart';
import '../../../core/routes/app_routes.dart';
import '../controller/custom_score_controller.dart';
import 'package:common_ui/common_ui.dart';
import '../../../core/theme/app_colors.dart';

class CustomScorePage extends BaseView<CustomScoreController> {
  const CustomScorePage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return AppGameSheet(
      appBar: AppAppBar(
        titleText: 'custom_score'.tr,
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              controller.voiceAnnouncer.isEnabled.value
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              color: Colors.white,
            ),
            onPressed: () => controller.voiceAnnouncer.toggle(),
          )),
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white),
            onPressed: () => Get.toNamed(AppRoutes.customScoreHistory),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildGameInfo(),
            const SizedBox(height: 12),
            Expanded(child: _buildPlayersList()),
          ],
        ),
      ),
      bottomBar: _buildOperationButtons(),
    );
  }

  Widget _buildGameInfo() {
    return AppSectionCard(
      title: 'game_statistics'.tr,
      titleTrailing: AppButton(
        label: 'add_player'.tr,
        compact: true,
        icon: Icons.person_add_outlined,
        onPressed: _showAddPlayerDialog,
      ),
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
      child: Obx(() {
        if (controller.players.isEmpty) {
          return Text(
            'no_players'.tr,
            style: const TextStyle(fontSize: 13, color: UiColors.textSecondary),
          );
        }
        final maxScore = controller.players.map((p) => p.score).reduce((a, b) => a > b ? a : b);
        final leaders = controller.players.where((p) => p.score == maxScore).toList();
        String leaderText;
        if (leaders.length == 1) {
          leaderText = 'leader_info'.tr.replaceAll('{player}', leaders.first.name).replaceAll('{score}', maxScore.toString());
        } else {
          leaderText = 'tied_leader_info'.tr.replaceAll('{players}', leaders.map((p) => p.name).join('、')).replaceAll('{score}', maxScore.toString());
        }
        return Text(
          'player_count_info'.tr.replaceAll('{count}', controller.players.length.toString()).replaceAll('{leader_info}', leaderText),
          style: const TextStyle(fontSize: 13, color: UiColors.textSecondary, height: 1.4),
        );
      }),
    );
  }

  Widget _buildPlayersList() {
    return Obx(() => ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: controller.players.length,
      itemBuilder: (context, index) {
        final player = controller.players[index];
        return AppPlayerCard(
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          content: InkWell(
            onTap: () => _showPlayerEditDialog(index, player),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: UiColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'score_label'.tr.replaceAll('{score}', player.score.toString()),
                  style: const TextStyle(
                    fontSize: 13,
                    color: UiColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          actions: controller.players.length > 1
              ? [
                  AppStepButton(
                    icon: Icons.delete_outline_rounded,
                    isIncrement: false,
                    onPressed: () => _showDeletePlayerDialog(index),
                  ),
                ]
              : null,
        );
      },
    ));
  }

  Widget _buildOperationButtons() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: 'reset_scores'.tr,
            icon: Icons.refresh_rounded,
            variant: AppButtonVariant.warning,
            expanded: true,
            onPressed: _showResetDialog,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AppButton(
            label: 'copy_result'.tr,
            icon: Icons.copy_rounded,
            variant: AppButtonVariant.secondary,
            expanded: true,
            onPressed: _showCopyDialog,
          ),
        ),
      ],
    );
  }

  void _showAddPlayerDialog() {
    Get.dialog(
      CustomInputDialog(
        title: 'add_player'.tr,
        labelText: 'please_input_player_name'.tr,
        onConfirm: (name) {
          if (name.trim().isNotEmpty) {
            controller.addPlayer(name.trim());
          }
        },
      ),
    );
  }

  void _showDeletePlayerDialog(int index) {
    Get.dialog(
      CustomConfirmDialog(
        title: 'delete_player'.tr,
        content: 'confirm_delete_player'.tr.replaceAll('{player}', controller.players[index].name),
        confirmText: 'confirm'.tr,
        cancelText: 'cancel'.tr,
        onConfirm: () {
          controller.removePlayer(index);
        },
      ),
    );
  }

  void _showPlayerEditDialog(int index, CustomPlayer player) {
    final nameController = TextEditingController(text: player.name);
    final scoreController = TextEditingController(text: player.score.toString());
    
    Get.dialog(
      CustomDialog(
        title: 'edit_player'.tr,
        content: Column(
            mainAxisSize: MainAxisSize.min,
                  children: [
                    // 姓名输入
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'player_name'.tr,
                        border: const OutlineInputBorder(),
                      ),
                      controller: nameController,
                    ),
                    const SizedBox(height: 16),
                    // 分数输入
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'score'.tr,
                        border: const OutlineInputBorder(),
                      ),
                      controller: scoreController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
          ],
        ),
        actions: [
          TextButton(
                            onPressed: () => Get.back(),
                            child: Text('cancel'.tr),
                          ),
          ElevatedButton(
                            onPressed: () {
              // 从控制器获取最新的值
              final newName = nameController.text.trim();
              final scoreText = scoreController.text.trim();
              final newScore = int.tryParse(scoreText) ?? player.score;
              
              if (newName.isNotEmpty) {
                controller.setPlayerName(index, newName);
              }
              controller.setPlayerScore(index, newScore);
              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
            child: Text('save'.tr),
              ),
            ],
      ),
    );
  }

  void _showResetDialog() {
    Get.dialog(
      CustomConfirmDialog(
        title: 'reset_scores'.tr,
        content: 'confirm_reset_all_scores'.tr,
        confirmText: 'confirm'.tr,
        cancelText: 'cancel'.tr,
        onConfirm: () {
          controller.resetAllScores();
        },
      ),
    );
  }

  void _showCopyDialog() {
    final copyText = controller.generateCopyText();
    if (copyText.isEmpty) {
      Get.snackbar('tip'.tr, 'no_data_to_copy'.tr);
      return;
    }

    Get.dialog(
      CustomDialog(
        title: 'copy_result'.tr,
        content: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  copyText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('close'.tr),
          ),
          ElevatedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: copyText));
                        Get.back();
                        Get.snackbar(
                          'copy_success'.tr,
                          'result_copied_to_clipboard'.tr,
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: AppColors.primary,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      },
            icon: const Icon(Icons.copy, size: 16),
            label: Text('copy'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                    ),
                  ),
                ],
      ),
    );
  }
} 