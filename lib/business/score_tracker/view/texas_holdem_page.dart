import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/base/base_view.dart';
import '../controller/texas_holdem_controller.dart';

class TexasHoldemPage extends BaseView<TexasHoldemController> {
  const TexasHoldemPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        title: Text(
          'texas_holdem'.tr,
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
            onPressed: () => Get.toNamed('/texas-holdem-history'),
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
              // 初始筹码设置
              _buildInitialChipsSection(),
              const SizedBox(height: 12),
              
              // 玩家积分列表
              Expanded(child: _buildPlayerScoresList()),
              const SizedBox(height: 12),
              
              // 操作按钮
              _buildOperationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialChipsSection() {
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
                  'initial_chips'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                  '${controller.initialChips.value}${'points'.tr}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                )),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showInitialChipsDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(0, 32),
            ),
            child: Text('modify'.tr, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerScoresList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'player_count'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _showAddPlayerDialog(),
                      icon: const Icon(Icons.add, size: 14),
                      label: Text('add'.tr, style: const TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: const Size(0, 24),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _toggleDeleteMode(),
                      icon: const Icon(Icons.delete, size: 14),
                      label: Text('delete'.tr, style: const TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: const Size(0, 24),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showResetScoresDialog(),
                      icon: const Icon(Icons.refresh, size: 14),
                      label: Text('reset'.tr, style: const TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: const Size(0, 24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: controller.players.length,
              itemBuilder: (context, index) {
                final player = controller.players[index];
                return _buildPlayerScoreItem(player);
              },
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerScoreItem(String player) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Obx(() => Text(
                      '${'times'.tr}: ${controller.playerScores[player] ?? 1}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                    const SizedBox(width: 8),
                    Obx(() => Text(
                      '${'initial_chips'.tr}: ${(controller.playerScores[player] ?? 1) * controller.initialChips.value}${'points'.tr}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 2),
                Obx(() {
                  final finalChips = controller.playerFinalChips[player];
                  if (finalChips != null) {
                    final initialChips = (controller.playerScores[player] ?? 1) * controller.initialChips.value;
                    final winLoss = finalChips - initialChips;
                    final winLossColor = winLoss >= 0 ? Colors.green : Colors.red;
                    final winLossText = winLoss >= 0 ? '+$winLoss' : '$winLoss';
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'remaining_chips'.tr + ': ${finalChips}' + 'points'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'win_loss'.tr + ': $winLossText' + 'points'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: winLossColor,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  controller.exitDeleteMode();
                  controller.adjustPlayerScore(player, -1);
                },
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.red,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                onPressed: () {
                  controller.exitDeleteMode();
                  controller.adjustPlayerScore(player, 1);
                },
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.green,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              // 删除按钮 - 只在删除模式下显示
              Obx(() => controller.isDeleteMode.value ? IconButton(
                onPressed: () => _showDeletePlayerDialog(player),
                icon: const Icon(Icons.delete_forever),
                color: Colors.red,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ) : const SizedBox.shrink()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperationButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showFinalSettlementDialog(),
            icon: const Icon(Icons.assessment, size: 16),
            label: Text('input_chips'.tr, style: const TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showSettlementReportDialog(),
            icon: const Icon(Icons.analytics, size: 16),
            label: Text('game_statistics'.tr, style: const TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleDeleteMode() {
    controller.toggleDeleteMode();
  }

  void _showDeletePlayerDialog(String player) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'confirm_delete_title'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 内容区域
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      color: Colors.orange[600],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'confirm_delete_player'.tr.replaceAll('{player}', player),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 按钮区域
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                        controller.removePlayer(player);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('delete'.tr),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInitialChipsDialog() {
    // 退出删除模式
    controller.exitDeleteMode();
    
    final chipsController = TextEditingController(text: controller.initialChips.value.toString());
    
    Get.dialog(
      GestureDetector(
        onTap: () {
          // 点击Dialog外部区域时收起键盘
          FocusScope.of(Get.context!).unfocus();
        },
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              // 阻止点击Dialog内部时关闭Dialog
            },
            child: Container(
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题栏
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'set_initial_chips'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 内容区域
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: chipsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'initial_chips'.tr,
                        hintText: 'please_enter_initial_chips'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      autofocus: true,
                    ),
                  ),
              // 按钮区域
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'cancel'.tr,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final chips = int.tryParse(chipsController.text);
                        if (chips != null && chips > 0) {
                          controller.updateInitialChips(chips);
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('confirm'.tr),
                    ),
                  ],
                ),
              ),
            ],
          ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddPlayerDialog() {
    // 退出删除模式
    controller.exitDeleteMode();
    
    final nameController = TextEditingController();
    
    Get.dialog(
      GestureDetector(
        onTap: () {
          // 点击Dialog外部区域时收起键盘
          FocusScope.of(Get.context!).unfocus();
        },
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              // 阻止点击Dialog内部时关闭Dialog
            },
            child: Container(
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题栏
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'add_player'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 内容区域
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'player_name'.tr,
                        hintText: 'please_enter_player_name'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      autofocus: true,
                    ),
                  ),
              // 按钮区域
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                        final playerName = nameController.text;
                        if (playerName.isNotEmpty) {
                          controller.addPlayer(playerName);
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('confirm'.tr),
                    ),
                  ],
                ),
              ),
            ],
          ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFinalSettlementDialog() {
    // 退出删除模式
    controller.exitDeleteMode();
    
    if (controller.players.isEmpty) {
      Get.snackbar('tip'.tr, 'please_add_players_first'.tr);
      return;
    }

    // 先选择玩家
    String? selectedPlayer = controller.players.isNotEmpty ? controller.players.first : null;
    final chipsController = TextEditingController();
    
    // 如果有玩家，设置默认筹码值
    if (selectedPlayer != null) {
      final currentScore = controller.playerScores[selectedPlayer] ?? 1;
      chipsController.text = (currentScore * controller.initialChips.value).toString();
    }

    Get.dialog(
      GestureDetector(
        onTap: () {
          // 点击Dialog外部区域时收起键盘
          FocusScope.of(Get.context!).unfocus();
        },
        child: StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  // 阻止点击Dialog内部时关闭Dialog
                },
                child: Container(
                  width: 320,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  // 标题栏
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.assessment,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'input_chips'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 内容区域
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'select_player'.tr + ':',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: selectedPlayer,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: InputBorder.none,
                            ),
                            hint: Text('please_select_player'.tr),
                            items: controller.players.map((player) => DropdownMenuItem<String>(
                              value: player,
                              child: Text(player),
                            )).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedPlayer = value;
                                // 设置默认筹码值
                                if (value != null) {
                                  final currentScore = controller.playerScores[value] ?? 1;
                                  chipsController.text = (currentScore * controller.initialChips.value).toString();
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (selectedPlayer != null) ...[
                          Text(
                            'input_final_chips'.tr + ':',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: chipsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: '$selectedPlayer ' + 'final_chips'.tr,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // 按钮区域
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
                            if (selectedPlayer != null) {
                              final chips = int.tryParse(chipsController.text);
                              if (chips != null && chips >= 0) {
                                // 直接更新玩家的最终筹码
                                controller.updatePlayerFinalChips(selectedPlayer!, chips);
                                Get.back();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('confirm'.tr),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSettlementReportDialog() {
    // 退出删除模式
    controller.exitDeleteMode();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          height: 600,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // 标题栏
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.analytics,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'game_statistics'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 内容区域 - 可滚动
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 统计信息卡片 - 简化为2行
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF4CAF50).withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'statistics_overview'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Obx(() {
                              final players = controller.players;
                              final initialChips = controller.initialChips.value;
                              final playerFinalChips = controller.playerFinalChips;
                              
                              int totalInitialChips = 0;
                              int totalFinalChips = 0;
                              
                              for (final player in players) {
                                final currentScore = controller.playerScores[player] ?? 1;
                                final playerInitialChips = currentScore * initialChips;
                                totalInitialChips += playerInitialChips;
                                
                                if (playerFinalChips.containsKey(player)) {
                                  totalFinalChips += playerFinalChips[player]!;
                                }
                              }
                              
                              final totalWinLoss = totalFinalChips - totalInitialChips;
                              final isBalanced = totalWinLoss == 0;
                              
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatItem('total_players'.tr, '${players.length}人', Icons.people),
                                      ),
                                      Expanded(
                                        child: _buildStatItem(
                                          'total_win_loss'.tr,
                                          '${totalWinLoss >= 0 ? '+' : ''}${totalWinLoss}分',
                                          totalWinLoss >= 0 ? Icons.trending_up : Icons.trending_down,
                                          color: totalWinLoss >= 0 ? Colors.green : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isBalanced ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: isBalanced ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                isBalanced ? Icons.check_circle : Icons.warning,
                                                color: isBalanced ? Colors.green : Colors.orange,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isBalanced ? 'balanced'.tr : 'unbalanced'.tr,
                                                style: TextStyle(
                                                  color: isBalanced ? Colors.green : Colors.orange,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 玩家列表
                      Text(
                        'player_details'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 表头
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'player'.tr,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'initial_chips'.tr,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'remaining_chips'.tr,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'win_loss'.tr,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Obx(() => Column(
                        children: controller.players.map((player) {
                          final currentScore = controller.playerScores[player] ?? 1;
                          final initialChips = currentScore * controller.initialChips.value;
                          final finalChips = controller.playerFinalChips[player];
                          final winLoss = finalChips != null ? finalChips - initialChips : 0;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[200]!),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    player,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${initialChips}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    finalChips != null ? '${finalChips}' : 'not_entered'.tr,
                                    style: TextStyle(
                                      color: finalChips != null ? Colors.blue[600] : Colors.grey[400],
                                      fontSize: 11,
                                      fontWeight: finalChips != null ? FontWeight.w500 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Icon(
                                        finalChips != null 
                                            ? (winLoss >= 0 ? Icons.trending_up : Icons.trending_down)
                                            : Icons.remove,
                                        size: 12,
                                        color: finalChips != null 
                                            ? (winLoss >= 0 ? Colors.green : Colors.red)
                                            : Colors.grey[400],
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        finalChips != null 
                                            ? '${winLoss >= 0 ? '+' : ''}${winLoss}'
                                            : '-',
                                        style: TextStyle(
                                          color: finalChips != null 
                                              ? (winLoss >= 0 ? Colors.green : Colors.red)
                                              : Colors.grey[400],
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )),
                    ],
                  ),
                ),
              ),
              // 按钮区域
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Get.back();
                          await controller.saveCurrentGameDataToHistory();
                        },
                        icon: const Icon(Icons.save, size: 14),
                        label: Text('save'.tr, style: const TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // 复制功能
                          final copyText = _generateCopyText();
                          await Clipboard.setData(ClipboardData(text: copyText));
                          Get.back();
                          Get.snackbar(
                            'copy_success'.tr,
                            'statistics_copied'.tr,
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: const Color(0xFF4CAF50),
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 14),
                        label: Text('copy'.tr, style: const TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text('close'.tr, style: const TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? Colors.grey[600],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetScoresDialog() {
    // 退出删除模式
    controller.exitDeleteMode();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'confirm_reset'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 内容区域
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      color: Colors.orange[600],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'confirm_reset_content'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 按钮区域
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                        controller.resetAllScores();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('reset_times'.tr),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _generateCopyText() {
    final players = controller.players;
    final initialChips = controller.initialChips.value;
    final playerFinalChips = controller.playerFinalChips;

    final List<String> lines = [];
    
    for (final player in players) {
      final currentScore = controller.playerScores[player] ?? 1;
      final totalChips = currentScore * initialChips;
      final finalChips = playerFinalChips[player];
      
      if (finalChips != null) {
        final winLoss = finalChips - totalChips;
        final winLossText = winLoss >= 0 ? '+$winLoss' : '$winLoss';
        lines.add('copy_text_template'.tr
            .replaceAll('{player}', player)
            .replaceAll('{initial_chips}', totalChips.toString())
            .replaceAll('{final_chips}', finalChips.toString())
            .replaceAll('{win_loss}', winLossText));
      } else {
        lines.add('copy_text_not_entered'.tr
            .replaceAll('{player}', player)
            .replaceAll('{initial_chips}', totalChips.toString()));
      }
    }
    
    return lines.join('\n');
  }
} 