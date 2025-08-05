import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/base/base_view.dart';
import '../../../core/routes/app_routes.dart';
import '../controller/custom_score_controller.dart';
import 'package:common_ui/common_ui.dart';

class CustomScorePage extends BaseView<CustomScoreController> {
  const CustomScorePage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        title: Text(
          'custom_score'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // 语音开关
          Obx(() => IconButton(
            icon: Icon(
              controller.voiceAnnouncer.isEnabled.value
                  ? Icons.volume_up
                  : Icons.volume_off,
              color: Colors.white,
            ),
            onPressed: () => controller.voiceAnnouncer.toggle(),
          )),
          // 历史记录
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => Get.toNamed(AppRoutes.customScoreHistory),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 游戏信息
              _buildGameInfo(),
              const SizedBox(height: 12),
              
              // 玩家列表
              Expanded(child: _buildPlayersList()),
              const SizedBox(height: 12),
              
              // 操作按钮
              _buildOperationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'game_statistics'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() {
                  if (controller.players.isEmpty) {
                    return Text(
                      'no_players'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    );
                  }
                  
                  // 找到最高分的玩家
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
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  );
                }),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _showAddPlayerDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text('add_player'.tr, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersList() {
    return Obx(() => ListView.builder(
      itemCount: controller.players.length,
      itemBuilder: (context, index) {
        final player = controller.players[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => _showPlayerEditDialog(index, player),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                // 玩家序号
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // 玩家信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'score_label'.tr.replaceAll('{score}', player.score.toString()),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 删除按钮
                if (controller.players.length > 1)
                  IconButton(
                    onPressed: () => _showDeletePlayerDialog(index),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        );
      },
    ));
  }

  Widget _buildOperationButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _showResetDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text('reset_scores'.tr),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _showCopyDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text('copy_result'.tr),
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
    String newName = player.name;
    int newScore = player.score;
    
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
                      controller: TextEditingController(text: player.name),
              onChanged: (value) {
                newName = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    // 分数输入
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'score'.tr,
                        border: const OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: player.score.toString()),
                      keyboardType: TextInputType.number,
              onChanged: (value) {
                        final score = int.tryParse(value) ?? 0;
                newScore = score;
                      },
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
              if (newName.trim().isNotEmpty) {
                controller.setPlayerName(index, newName.trim());
              }
              controller.setPlayerScore(index, newScore);
                                Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
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
                          backgroundColor: const Color(0xFF4CAF50),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      },
            icon: const Icon(Icons.copy, size: 16),
            label: Text('copy'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                    ),
                  ),
                ],
      ),
    );
  }
} 