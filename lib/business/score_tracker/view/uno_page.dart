import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/base/base_view.dart';
import '../controller/uno_controller.dart';
import 'package:common_ui/common_ui.dart';
import '../../../core/routes/app_routes.dart';

class UnoPage extends BaseView<UnoController> {
  const UnoPage({super.key});

  @override
  UnoController get controller => Get.put(UnoController());

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('uno'.tr),
      actions: [
        // 语音播报开关
        Obx(() => IconButton(
          icon: Icon(
            controller.voiceAnnouncer.isEnabled.value 
                ? Icons.volume_up 
                : Icons.volume_off,
            color: controller.voiceAnnouncer.isEnabled.value 
                ? Colors.white 
                : Colors.grey,
          ),
          onPressed: () => controller.voiceAnnouncer.toggle(),
        )),
        // 历史记录按钮
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () => Get.toNamed(AppRoutes.unoHistory),
        ),
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGameInfo(),
                const SizedBox(height: 12),
                _buildScoreModeToggle(),
                const SizedBox(height: 12),
                _buildCurrentRound(),
                const SizedBox(height: 12),
                _buildLeaderboard(),
                const SizedBox(height: 80), // 为悬浮按钮留出空间
              ],
            ),
          ),
          // 悬浮的结束按钮
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _buildFloatingEndButton(),
          ),
        ],
      );
    });
  }

  // 游戏信息
  Widget _buildGameInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.games, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'uno'.tr,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'target'.tr + ': ${controller.targetScore.value}${controller.isAccumulateMode.value ? 'points'.tr : 'wins'.tr}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'players'.tr + ': ${controller.playerCount.value}${'people'.tr} | ${'records'.tr}: ${controller.records.length}${'rounds'.tr}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showSettingsDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    'settings'.tr,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showResetDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    'reset'.tr,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 计分模式切换
  Widget _buildScoreModeToggle() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'scoring_mode'.tr + ': ',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              if (!controller.isAccumulateMode.value) {
                controller.toggleScoreMode();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: controller.isAccumulateMode.value ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'accumulate_points'.tr,
                style: TextStyle(
                  color: controller.isAccumulateMode.value ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (controller.isAccumulateMode.value) {
                controller.toggleScoreMode();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: !controller.isAccumulateMode.value ? Colors.green : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'record_winners_only'.tr,
                style: TextStyle(
                  color: !controller.isAccumulateMode.value ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 积分榜
  Widget _buildLeaderboard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.leaderboard, color: Colors.orange, size: 18),
              const SizedBox(width: 6),
              Text(
                controller.isAccumulateMode.value ? 'points_leaderboard'.tr : 'wins_leaderboard'.tr,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...controller.leaderboard.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: index == 0 ? Colors.orange.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
                border: index == 0 ? Border.all(color: Colors.orange, width: 1) : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: index == 0 ? Colors.orange : Colors.grey,
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          controller.isAccumulateMode.value 
                              ? 'points'.tr + ': ${player.score}'
                              : 'wins'.tr + ': ${player.wins}',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showPlayerNameDialog(index),
                    child: const Icon(Icons.edit, size: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // 当前轮次
  Widget _buildCurrentRound() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'current_round'.tr,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showAddPlayerDialog(),
                icon: const Icon(Icons.person_add, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 剩余手牌输入
          Text(
            'remaining_cards'.tr + ':',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          ...controller.players.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            player.name,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        if (controller.players.length > 2)
                          GestureDetector(
                            onTap: () => _showDeletePlayerDialog(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              child: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () => _showRemainingCardsDialog(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                controller.currentRemainingCards[index].toString(),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // 悬浮的结束按钮
  Widget _buildFloatingEndButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => controller.endRound(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'end_current_round'.tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // 显示新增玩家对话框
  void _showAddPlayerDialog() {
    if (controller.playerCount.value >= 10) {
      Get.snackbar(
        'tip'.tr,
        'max_players_limit'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    
    Get.dialog(
      CustomInputDialog(
        title: 'add_player'.tr,
        labelText: 'player_name'.tr,
        initialValue: 'player'.tr + '${controller.playerCount.value + 1}',
        onConfirm: (playerName) async {
          if (playerName.trim().isNotEmpty) {
            controller.setPlayerCount(controller.playerCount.value + 1);
            // 设置新玩家的名称
            await controller.setPlayerName(controller.playerCount.value - 1, playerName.trim());
          } else {
            Get.snackbar(
              'input_error'.tr,
              'player_name_cannot_be_empty'.tr,
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }

  // 显示删除玩家对话框
  void _showDeletePlayerDialog(int playerIndex) {
    final playerName = controller.players[playerIndex].name;
    Get.dialog(
      CustomDialog(
        title: 'delete_player'.tr,
        content: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: Colors.orange[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'confirm_delete_player'.tr.replaceAll('{player}', playerName) + '\n' + 'delete_warning'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              controller.removePlayer(playerIndex);
              Get.back();
              Get.snackbar(
                'delete_success'.tr,
                'player_deleted'.tr.replaceAll('{player}', playerName),
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
  }

  // 显示玩家名称编辑对话框
  void _showPlayerNameDialog(int playerIndex) {
    final currentName = controller.players[playerIndex].name;
    Get.dialog(
      CustomInputDialog(
        title: 'edit_player_name'.tr,
        labelText: 'player_name'.tr,
        initialValue: currentName,
        onConfirm: (newName) async {
          if (newName.trim().isNotEmpty) {
            await controller.setPlayerName(playerIndex, newName.trim());
          } else {
            Get.snackbar(
              'input_error'.tr,
              'player_name_cannot_be_empty'.tr,
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }

  // 显示剩余手牌输入对话框
  void _showRemainingCardsDialog(int playerIndex) {
    final currentCards = controller.currentRemainingCards[playerIndex];
    Get.dialog(
      CustomInputDialog(
        title: 'set_remaining_cards'.tr,
        labelText: 'cards_count'.tr,
        initialValue: currentCards.toString(),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'please_enter_cards_count'.tr;
          }
          final cards = int.tryParse(value);
          if (cards == null) {
            return 'please_enter_valid_number'.tr;
          }
          if (cards < 0 || cards > 100) {
            return 'cards_count_range'.tr;
          }
          return null;
        },
        onConfirm: (newCards) {
          final cards = int.tryParse(newCards);
          if (cards != null && cards >= 0 && cards <= 100) {
            controller.setRemainingCards(playerIndex, cards);
          }
        },
      ),
    );
  }

  // 显示游戏设置对话框
  void _showSettingsDialog() {
    Get.dialog(
      CustomDialog(
        title: 'game_settings'.tr,
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 玩家数量设置
              Row(
                children: [
                  Text('player_count'.tr + ': '),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: controller.playerCount.value,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      items: List.generate(9, (index) => index + 2).map((count) {
                        return DropdownMenuItem(
                          value: count,
                          child: Text('$count${'people'.tr}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.setPlayerCount(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 目标分数设置
              Row(
                children: [
                  Text('target_score'.tr + ': '),
                  Expanded(
                    child: TextFormField(
                      initialValue: controller.targetScore.value.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      onChanged: (value) {
                        final score = int.tryParse(value);
                        if (score != null && score > 0) {
                          controller.setTargetScore(score);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
  }

  // 显示游戏记录对话框
  void _showRecordsDialog() {
    Get.dialog(
      CustomDialog(
        title: 'game_records'.tr,
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Obx(() {
            if (controller.records.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('no_records'.tr, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: controller.records.length,
              itemBuilder: (context, index) {
                final record = controller.records[controller.records.length - 1 - index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(
                        record.winnerName.substring(0, 1),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      'player_wins'.tr.replaceAll('{player}', record.winnerName),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')}:${record.timestamp.second.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Text(
                      controller.isAccumulateMode.value 
                          ? '+${record.roundScore}${'points'.tr}'
                          : '+1${'win'.tr}',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
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

  // 显示重置确认对话框
  void _showResetDialog() {
    Get.dialog(
      CustomConfirmDialog(
        title: 'confirm_reset'.tr,
        content: 'reset_confirmation_content'.tr,
        confirmText: 'reset'.tr,
        cancelText: 'cancel'.tr,
        confirmColor: Colors.red,
        onConfirm: () async {
          controller.resetGame();
          await Future.delayed(const Duration(milliseconds: 100));
          Get.snackbar(
            '✅ ${'reset_complete'.tr}',
            'all_scores_and_records_cleared'.tr,
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFF8E44AD),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            icon: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 24,
            ),
            shouldIconPulse: false,
            dismissDirection: DismissDirection.horizontal,
          );
        },
      ),
    );
  }
} 