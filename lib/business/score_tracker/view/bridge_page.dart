import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/base/base_view.dart';
import '../controller/bridge_controller.dart';
import 'package:common_ui/common_ui.dart';
import '../../../core/routes/app_routes.dart';

class BridgePage extends BaseView<BridgeController> {
  const BridgePage({super.key});

  @override
  BridgeController get controller => Get.put(BridgeController());

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('bridge'.tr),
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
          onPressed: () => Get.toNamed(AppRoutes.bridgeHistory),
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
                _buildPlayerInfo(),
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
                'bridge'.tr,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'records_count'.tr.replaceAll('{count}', controller.records.length.toString()),
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

  // 玩家信息
  Widget _buildPlayerInfo() {
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
          Text(
            'player_info'.tr,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Obx(() => Text(
                      _getPlayerDisplayName(controller.players[0]),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    )),
                    Text('north'.tr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Obx(() => Text(
                      _getPlayerDisplayName(controller.players[1]),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    )),
                    Text('south'.tr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Obx(() => Text(
                      _getPlayerDisplayName(controller.players[2]),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    )),
                    Text('east'.tr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Obx(() => Text(
                      _getPlayerDisplayName(controller.players[3]),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    )),
                    Text('west'.tr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
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
          Text(
            'current_round'.tr,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          // 定约输入
          Row(
            children: [
              Text('contract'.tr + ': ', style: const TextStyle(fontSize: 12)),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showContractDialog(),
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
                            controller.currentContract.value.isEmpty ? 'click_to_select_or_input'.tr : controller.currentContract.value,
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
          const SizedBox(height: 8),
          
          // 加倍状态
          Row(
            children: [
              Text('double_status'.tr + ': ', style: const TextStyle(fontSize: 12)),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showDoubleStatusDialog(),
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
                            controller.currentDoubleStatus.value,
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
          const SizedBox(height: 8),
          
          // 成交方
          Row(
            children: [
              Text('declarer'.tr + ': ', style: const TextStyle(fontSize: 12)),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showDeclarerDialog(),
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
                            controller.currentDeclarer.value == 'NS' ? 'north_south'.tr : 'east_west'.tr,
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
          const SizedBox(height: 8),
          
          // 墩数
          Row(
            children: [
              Text('tricks'.tr + ': ', style: const TextStyle(fontSize: 12)),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showTricksDialog(),
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
                            controller.currentTricks.value.toString(),
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
          const SizedBox(height: 8),
          
          // 是否有局
          Row(
            children: [
              Text('vulnerable'.tr + ': ', style: const TextStyle(fontSize: 12)),
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.setVulnerable(!controller.currentVulnerable.value),
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
                            controller.currentVulnerable.value ? 'yes'.tr : 'no'.tr,
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
                'leaderboard'.tr,
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
                          player['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          'points'.tr + ': ${player['score']}',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
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
            'end_round'.tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // 显示定约输入对话框
  void _showContractDialog() {
    Get.dialog(
      CustomDialog(
        title: 'contract'.tr,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Common contracts
            Text(
              'common_contracts'.tr,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.commonContracts.map((contract) {
                return GestureDetector(
                  onTap: () {
                    controller.setContract(contract);
                    Get.back();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: controller.currentContract.value == contract 
                          ? Colors.blue 
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      contract,
                      style: TextStyle(
                        color: controller.currentContract.value == contract 
                            ? Colors.white 
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            // Manual input
            Text(
              'manual_input'.tr,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'input_contract_hint'.tr,
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  controller.setContract(value.trim());
                  Get.back();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
        ],
      ),
    );
  }

  // Show double status dialog
  void _showDoubleStatusDialog() {
    Get.dialog(
      CustomDialog(
        title: 'double_status'.tr,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDoubleStatusOption('no_double'.tr),
            _buildDoubleStatusOption('double'.tr),
            _buildDoubleStatusOption('redouble'.tr),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildDoubleStatusOption(String status) {
    return Obx(() => GestureDetector(
      onTap: () {
        controller.setDoubleStatus(status);
        Get.back();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: controller.currentDoubleStatus.value == status 
              ? Colors.blue 
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: controller.currentDoubleStatus.value == status 
                ? Colors.white 
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ));
  }

  // 显示成交方对话框
  void _showDeclarerDialog() {
    Get.dialog(
      CustomDialog(
        title: 'declarer'.tr,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDeclarerOption('NS', 'north_south'.tr),
            _buildDeclarerOption('EW', 'east_west'.tr),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildDeclarerOption(String value, String label) {
    return Obx(() => GestureDetector(
      onTap: () {
        controller.setDeclarer(value);
        Get.back();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: controller.currentDeclarer.value == value 
              ? Colors.blue 
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: controller.currentDeclarer.value == value 
                ? Colors.white 
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ));
  }

  // 显示墩数对话框
  void _showTricksDialog() {
    Get.dialog(
      CustomDialog(
        title: 'tricks'.tr,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Common tricks
            Text(
              'tricks'.tr + ':',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.commonTricks.map((tricks) {
                return GestureDetector(
                  onTap: () {
                    controller.setTricks(tricks);
                    Get.back();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: controller.currentTricks.value == tricks 
                          ? Colors.blue 
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tricks.toString(),
                      style: TextStyle(
                        color: controller.currentTricks.value == tricks 
                            ? Colors.white 
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            // Manual input
            Text(
              'manual_input'.tr,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'input_tricks_hint'.tr,
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                final tricks = int.tryParse(value);
                if (tricks != null && tricks >= 6 && tricks <= 13) {
                  controller.setTricks(tricks);
                  Get.back();
                } else {
                  Get.snackbar('error'.tr, 'please_input_valid_number'.tr);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
        ],
      ),
    );
  }



  // 显示设置对话框
  void _showSettingsDialog() {
    Get.dialog(
      CustomDialog(
        title: 'player_info'.tr,
        content: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.players.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      _getDirectionName(index),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () => _showPlayerNameDialog(index),
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
                                controller.players[index].name,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const Icon(Icons.edit, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        )),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
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
        title: 'set_player_name'.tr,
        labelText: 'player_name'.tr,
        initialValue: currentName,
        onConfirm: (newName) async {
          if (newName.trim().isNotEmpty) {
            await controller.setPlayerName(playerIndex, newName.trim());
            // 强制刷新UI
            controller.players.refresh();
          }
        },
      ),
    );
  }

  // 获取方向名称
  String _getDirectionName(int playerIndex) {
    switch (playerIndex) {
      case 0:
        return 'north'.tr;
      case 1:
        return 'south'.tr;
      case 2:
        return 'east'.tr;
      case 3:
        return 'west'.tr;
      default:
        return 'unknown'.tr;
    }
  }

  // 获取玩家显示名称
  String _getPlayerDisplayName(BridgePlayer player) {
    // 如果玩家名称是默认的Player 1-4，则显示方向名称
    if (player.name.startsWith('Player ')) {
      final playerIndex = controller.players.indexOf(player);
      switch (playerIndex) {
        case 0:
          return 'north'.tr;
        case 1:
          return 'south'.tr;
        case 2:
          return 'east'.tr;
        case 3:
          return 'west'.tr;
        default:
          return player.name;
      }
    }
    // 否则显示用户自定义的名称
    return player.name;
  }

  // 显示重置对话框
  void _showResetDialog() {
    Get.dialog(
      CustomConfirmDialog(
        title: 'game_reset'.tr,
        content: 'confirm_clear_records_content'.tr,
        confirmText: 'confirm'.tr,
        cancelText: 'cancel'.tr,
        onConfirm: () {
          controller.resetGame();
          Get.back();
        },
      ),
    );
  }
} 