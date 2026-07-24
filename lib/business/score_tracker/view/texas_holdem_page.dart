import 'package:flutter/material.dart';
import 'package:common_ui/common_ui.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/base/base_view.dart';
import '../controller/texas_holdem_controller.dart';
import '../../../core/theme/app_colors.dart';

class TexasHoldemPage extends BaseView<TexasHoldemController> {
  const TexasHoldemPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return AppGameSheet(
      appBar: AppAppBar(
        titleText: 'texas_holdem'.tr,
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
            onPressed: () => Get.toNamed('/texas-holdem-history'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInitialChipsSection(),
            const SizedBox(height: 12),
            Expanded(child: _buildPlayerScoresList()),
          ],
        ),
      ),
      bottomBar: _buildOperationButtons(),
    );
  }

  Widget _buildInitialChipsSection() {
    return AppSectionCard(
      title: 'initial_chips'.tr,
      titleTrailing: AppButton(
        label: 'modify'.tr,
        compact: true,
        onPressed: () => _showInitialChipsDialog(),
      ),
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
      child: Obx(() => Text(
        '${controller.initialChips.value}${'points'.tr}',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: UiColors.textPrimary,
        ),
      )),
    );
  }

  Widget _buildPlayerScoresList() {
    return Container(
      decoration: BoxDecoration(
        color: UiColors.surfaceVariant,
        borderRadius: BorderRadius.circular(UiRadius.lg),
        border: Border.all(color: UiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'player_count'.tr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: UiColors.textPrimary,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    AppActionChip.add(
                      label: 'add'.tr,
                      onPressed: () => _showAddPlayerDialog(),
                    ),
                    AppActionChip.delete(
                      label: 'delete'.tr,
                      onPressed: () => _toggleDeleteMode(),
                    ),
                    AppActionChip.reset(
                      label: 'reset'.tr,
                      onPressed: () => _showResetScoresDialog(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemCount: controller.players.length,
              itemBuilder: (context, index) {
                return _buildPlayerScoreItem(controller.players[index]);
              },
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerScoreItem(String player) {
    return AppPlayerCard(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        child: Text(
          player.isNotEmpty ? player[0] : '?',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            player,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: UiColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Obx(() => Text(
                '${'times'.tr}: ${controller.playerScores[player] ?? 1}',
                style: const TextStyle(fontSize: 12, color: UiColors.textSecondary),
              )),
              const SizedBox(width: 8),
              Obx(() => Text(
                '${'initial_chips'.tr}: ${(controller.playerScores[player] ?? 1) * controller.initialChips.value}${'points'.tr}',
                style: const TextStyle(fontSize: 12, color: UiColors.textMuted),
              )),
            ],
          ),
          const SizedBox(height: 2),
          Obx(() {
            final finalChips = controller.playerFinalChips[player];
            if (finalChips != null) {
              final initialChips = (controller.playerScores[player] ?? 1) * controller.initialChips.value;
              final winLoss = finalChips - initialChips;
              final winLossColor = winLoss >= 0 ? AppColors.success : AppColors.error;
              final winLossText = winLoss >= 0 ? '+$winLoss' : '$winLoss';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${'remaining_chips'.tr}: $finalChips${'points'.tr}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.info,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${'win_loss'.tr}: $winLossText${'points'.tr}',
                    style: TextStyle(
                      fontSize: 12,
                      color: winLossColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      actions: [
        AppStepButton.minus(
          onPressed: () {
            controller.exitDeleteMode();
            controller.adjustPlayerScore(player, -1);
          },
        ),
        const SizedBox(width: 6),
        AppStepButton.plus(
          onPressed: () {
            controller.exitDeleteMode();
            controller.adjustPlayerScore(player, 1);
          },
        ),
        Obx(() => controller.isDeleteMode.value
            ? Padding(
                padding: const EdgeInsets.only(left: 6),
                child: AppStepButton(
                  icon: Icons.delete_outline_rounded,
                  isIncrement: false,
                  onPressed: () => _showDeletePlayerDialog(player),
                ),
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildOperationButtons() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: 'input_chips'.tr,
            icon: Icons.assessment_outlined,
            expanded: true,
            onPressed: () => _showFinalSettlementDialog(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AppButton(
            label: 'game_statistics'.tr,
            icon: Icons.analytics_outlined,
            variant: AppButtonVariant.warning,
            expanded: true,
            onPressed: () => _showSettlementReportDialog(),
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
                  color: AppColors.primary,
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
          KeyboardDismiss.dismiss();
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
                      color: AppColors.primary,
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
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
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
                        backgroundColor: AppColors.primary,
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
          KeyboardDismiss.dismiss();
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
                      color: AppColors.primary,
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
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
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
                        backgroundColor: AppColors.primary,
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
          KeyboardDismiss.dismiss();
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
                      color: AppColors.primary,
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
                                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                              ),
                              filled: true,
                              fillColor: AppColors.surfaceVariant,
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
                            backgroundColor: AppColors.primary,
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
                  color: AppColors.primary,
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
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
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
                                color: AppColors.primary,
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
                          color: AppColors.surfaceVariant,
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
                          backgroundColor: AppColors.primary,
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
                            backgroundColor: AppColors.primary,
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
                  color: AppColors.primary,
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