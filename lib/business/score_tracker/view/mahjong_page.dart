import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/base/base_view.dart';
import '../controller/mahjong_controller.dart';
import 'package:common_ui/common_ui.dart';

class MahjongPage extends BaseView<MahjongController> {
  const MahjongPage({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('mahjong_scoring'.tr),
      backgroundColor: const Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // 语音开关
        Obx(() => IconButton(
          onPressed: () {
            controller.voiceAnnouncer.toggle();
          },
          icon: Icon(
            controller.voiceAnnouncer.isEnabled.value ? Icons.volume_up : Icons.volume_off,
            color: controller.voiceAnnouncer.isEnabled.value ? Colors.white : Colors.white.withOpacity(0.6),
          ),
        )),

        // 历史记录按钮
        IconButton(
          onPressed: () {
            Get.toNamed('/mahjong-history');
          },
          icon: const Icon(Icons.history),
        ),
        // 设置菜单
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'settings':
                _showSettingsDialog();
                break;
              case 'fans_config':
                _showFansConfigDialog();
                break;
              case 'reset':
                _showResetDialog();
                break;
              case 'records':
                _showRecordsDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  const Icon(Icons.settings),
                  const SizedBox(width: 8),
                  Text('settings'.tr),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'fans_config',
              child: Row(
                children: [
                  const Icon(Icons.casino),
                  const SizedBox(width: 8),
                  Text('fans_config'.tr),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'records',
              child: Row(
                children: [
                  const Icon(Icons.history),
                  const SizedBox(width: 8),
                  Text('records'.tr),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'reset',
              child: Row(
                children: [
                  const Icon(Icons.refresh, color: Colors.red),
                  const SizedBox(width: 8),
                  Text('reset'.tr, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 麻将桌区域
          SizedBox(
            height: 380,
            child: _buildMahjongTable(),
          ),
          const SizedBox(height: 20),
          
          // 基础分设置
          _buildBaseScoreSection(),
          const SizedBox(height: 16),
          
          // 积分统计模块
          _buildScoreStatisticsSection(),
          const SizedBox(height: 20), // 底部留一些空间
        ],
      ),
    );
  }

  Widget _buildMahjongTable() {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 麻将桌背景
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFF8BC34A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4CAF50), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 麻将桌纹理
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF8BC34A),
                            const Color(0xFF7CB342),
                            const Color(0xFF689F38),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 麻将桌中心图案
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.casino,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  // 麻将桌边缘装饰
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 东 - 右侧
          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildPlayerSeat(0, 'east'.tr),
            ),
          ),
          
          // 南 - 底部
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: _buildPlayerSeat(1, 'south'.tr),
            ),
          ),
          
          // 西 - 左侧
          Positioned(
            left: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildPlayerSeat(2, 'west'.tr),
            ),
          ),
          
          // 北 - 顶部
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: _buildPlayerSeat(3, 'north'.tr),
            ),
          ),
          
          // 操作按钮 - 放在右下角，不干扰玩家位置
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    _showPositionSwitchDialog();
                  },
                  backgroundColor: const Color(0xFF2196F3),
                  child: const Icon(Icons.swap_horiz, color: Colors.white),
                  mini: true,
                  heroTag: 'position_switch',
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () {
                    _showResetDialog();
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.refresh, color: Colors.white),
                  mini: true,
                  heroTag: 'reset',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSeat(int playerIndex, String direction) {
    return Obx(() {
      final playerName = controller.playerNames[playerIndex];
      final playerScore = controller.playerScores[playerIndex];
      
      return GestureDetector(
        onTap: () {
          controller.selectedPlayer.value = playerIndex;
          _showPlayerEditDialog(playerIndex, playerName, playerScore);
        },
        child: Container(
          width: 85,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 方向标识
              Text(
                direction,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              
              // 玩家名称
              Text(
                playerName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              
              // 分数显示
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: playerScore >= 0 ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: playerScore >= 0 ? const Color(0xFF4CAF50) : Colors.red,
                    width: 1,
                  ),
                ),
                child: Text(
                  playerScore.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: playerScore >= 0 ? const Color(0xFF4CAF50) : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBaseScoreSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Text('base_score'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: controller.baseScore.toString()),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'base_score'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                final score = int.tryParse(value);
                if (score != null && score > 0) {
                  controller.baseScore.value = score;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // 积分统计模块
  Widget _buildScoreStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'score_statistics'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            // 计算排名
            final scores = controller.playerScores;
            final sortedPlayers = List.generate(4, (index) => index)
                ..sort((a, b) => scores[b].compareTo(scores[a]));
            
            return Column(
              children: [
                // 玩家积分详情
                ...sortedPlayers.map((playerIndex) {
                  final playerName = controller.playerNames[playerIndex];
                  final playerScore = scores[playerIndex];
                  final rank = sortedPlayers.indexOf(playerIndex) + 1;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: rank == 1 ? Colors.amber.shade50 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: rank == 1 ? Colors.amber.shade200 : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        // 排名
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: rank == 1 ? Colors.amber : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '$rank',
                              style: TextStyle(
                                color: rank == 1 ? Colors.white : Colors.white,
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
                                playerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${['east'.tr, 'south'.tr, 'west'.tr, 'north'.tr][playerIndex]}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // 分数
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: playerScore >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: playerScore >= 0 ? Colors.green.shade200 : Colors.red.shade200,
                            ),
                          ),
                          child: Text(
                            '${playerScore >= 0 ? '+' : ''}$playerScore',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: playerScore >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            );
          }),
        ],
      ),
    );
  }



  // 显示玩家编辑对话框
  void _showPlayerEditDialog(int playerIndex, String currentName, int currentScore) {
    String newName = currentName;
    int newScore = currentScore;
    
    Get.dialog(
      CustomDialog(
        title: 'player_operations_title'.tr.replaceAll('{player}', controller.playerNames[playerIndex]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 主要游戏操作 - 突出显示
            Text('game_operations'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      _showWinDialog();
                    },
                    icon: const Icon(Icons.emoji_events, color: Colors.white),
                    label: Text('win_game'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      _showGangDialog();
                    },
                    icon: const Icon(Icons.diamond, color: Colors.white),
                    label: Text('gang'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 8),
            
            // 玩家信息编辑 - 弱化显示
            Row(
              children: [
                Icon(Icons.edit, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('edit_info'.tr, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 8),
            
            // 玩家名称编辑
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${'name'.tr}: $currentName',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Get.back();
                    _showPlayerNameEditDialog(playerIndex, currentName);
                  },
                  icon: Icon(Icons.edit, size: 16, color: Colors.grey[600]),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            
            // 玩家分数编辑
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${'score'.tr}: $currentScore',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Get.back();
                    _showPlayerScoreEditDialog(playerIndex, currentName, currentScore);
                  },
                  icon: Icon(Icons.edit, size: 16, color: Colors.grey[600]),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
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

  // 显示玩家名称编辑对话框
  void _showPlayerNameEditDialog(int playerIndex, String currentName) {
    Get.dialog(
      CustomInputDialog(
        title: 'modify_player_name'.tr.replaceAll('{index}', (playerIndex + 1).toString()),
        labelText: 'player_name'.tr,
        initialValue: currentName,
        onConfirm: (newName) {
          if (newName.trim().isNotEmpty) {
            controller.setPlayerName(playerIndex, newName.trim());
            Get.snackbar(
              'manual_modify_success'.tr,
              'manual_score_update'.tr,
              snackPosition: SnackPosition.TOP,
              backgroundColor: const Color(0xFF4CAF50),
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          }
        },
      ),
    );
  }

  // 显示玩家分数编辑对话框
  void _showPlayerScoreEditDialog(int playerIndex, String playerName, int currentScore) {
    Get.dialog(
      CustomInputDialog(
        title: 'modify_player_name'.tr.replaceAll('{index}', playerName),
        labelText: 'score'.tr,
        initialValue: currentScore.toString(),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'please_input_score'.tr;
          }
          final score = int.tryParse(value);
          if (score == null) {
            return 'please_input_valid_number'.tr;
          }
          if (score < -999 || score > 999) {
            return 'score_range_mahjong'.tr;
          }
          return null;
        },
        onConfirm: (newScore) {
          final score = int.tryParse(newScore);
          if (score != null) {
            _updatePlayerScore(playerIndex, currentScore, score);
          }
        },
      ),
    );
  }

  // 显示番数编辑对话框
  void _showFansEditDialog(String winMethod) {
    Get.dialog(
      CustomInputDialog(
        title: 'modify_fans'.tr,
        labelText: 'fans'.tr,
        initialValue: controller.selectedFans.value.toString(),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'please_input_fans'.tr;
          }
          final fans = int.tryParse(value);
          if (fans == null) {
            return 'please_input_valid_number'.tr;
          }
          if (fans <= 0) {
            return 'fans_must_be_positive'.tr;
          }
          return null;
        },
        onConfirm: (newValue) async {
          final newFans = int.tryParse(newValue);
          if (newFans != null && newFans > 0) {
            controller.updateSelectedFans(newFans);
            // 根据胡牌方式保存到对应的配置
            if (winMethod == 'self_draw') {
              await controller.updateFansForWinTypeSelfDraw(
                controller.selectedWinType.value,
                newFans,
              );
            } else if (winMethod == 'point_pao') {
              await controller.updateFansForWinTypePointPao(
                controller.selectedWinType.value,
                newFans,
              );
            }
            Get.snackbar(
              'fans_config_save_success'.tr,
              '${controller.selectedWinType.value.tr}的${winMethod.tr}番数已更新',
              snackPosition: SnackPosition.TOP,
              backgroundColor: const Color(0xFF4CAF50),
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          }
        },
      ),
    );
  }

  // 显示杠牌番数编辑对话框
  void _showGangScoreEditDialog(String gangMethod, RxInt gangScore) {
    Get.dialog(
      CustomInputDialog(
        title: 'modify_gang_score'.tr,
        labelText: 'fans'.tr,
        initialValue: gangScore.value.toString(),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'please_input_fans'.tr;
          }
          final score = int.tryParse(value);
          if (score == null) {
            return 'please_input_valid_number'.tr;
          }
          if (score < 0) {
            return 'fans_cannot_be_negative'.tr;
          }
          return null;
        },
        onConfirm: (newValue) {
          final newScore = int.tryParse(newValue);
          if (newScore != null && newScore >= 0) {
            gangScore.value = newScore;
            Get.snackbar(
              'fans_config_save_success'.tr,
              '${gangMethod}番数已更新为${newScore}番',
              snackPosition: SnackPosition.TOP,
              backgroundColor: const Color(0xFF4CAF50),
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          }
        },
      ),
    );
  }



  // 更新玩家分数的通用方法
  void _updatePlayerScore(int playerIndex, int currentScore, int newScore) {
    // 记录变化前的分数
    final oldScores = List<int>.from(controller.playerScores);
    
    controller.playerScores[playerIndex] = newScore;
    
          // 添加手动修改记录
      final record = MahjongRecord(
        playerIndex: playerIndex,
        playerName: controller.playerNames[playerIndex],
        score: newScore - currentScore,
        description: 'manual_modify_description'.tr.replaceAll('{old_score}', currentScore.toString()).replaceAll('{new_score}', newScore.toString()),
        timestamp: DateTime.now(),
        scoresAtTime: oldScores,
        scoreChanges: {
          for (int i = 0; i < controller.playerNames.length; i++)
            controller.playerNames[i]: controller.playerScores[i] - oldScores[i],
        },
      );
      controller.records.add(record);
    
    controller.savePlayerScores();
    
    Get.snackbar(
      '✅ 修改成功',
      '玩家分数已更新',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // 显示胡牌对话框
  void _showWinDialog() {
    // 胡牌方式选择状态
    final RxString winMethod = ''.obs;
    final RxInt selectedLoser = (-1).obs;
    final RxInt zhuamaFans = 0.obs; // 抓码番数，默认0
    
    Get.dialog(
      CustomDialog(
        title: 'win_game'.tr,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一步：选择胡牌方式
            Text('select_win_method'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: () async {
                      winMethod.value = 'self_draw';
                      // 更新为自摸番数
                      final fans = await controller.getFansForWinTypeSelfDraw(controller.selectedWinType.value);
                      controller.selectedFans.value = fans;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: winMethod.value == 'self_draw' 
                        ? const Color(0xFF4CAF50) 
                        : Colors.grey.shade300,
                      foregroundColor: winMethod.value == 'self_draw' 
                        ? Colors.white 
                        : Colors.black87,
                    ),
                    child: Text('self_draw'.tr),
                  )),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: () async {
                      winMethod.value = 'point_pao';
                      // 更新为点炮番数
                      final fans = await controller.getFansForWinTypePointPao(controller.selectedWinType.value);
                      controller.selectedFans.value = fans;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: winMethod.value == 'point_pao' 
                        ? const Color(0xFF4CAF50) 
                        : Colors.grey.shade300,
                      foregroundColor: winMethod.value == 'point_pao' 
                        ? Colors.white 
                        : Colors.black87,
                    ),
                    child: Text('point_pao'.tr),
                  )),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 第二步：点炮时选择被点炮者
            Obx(() {
              if (winMethod.value != 'point_pao') return const SizedBox.shrink();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('select_loser'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: controller.playerNames.asMap().entries.map((entry) {
                      final index = entry.key;
                      final name = entry.value;
                      final isSelected = selectedLoser.value == index;
                      
                      return GestureDetector(
                        onTap: () {
                          selectedLoser.value = index;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.red : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? Colors.red : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }),
            
            const SizedBox(height: 16),
            
            // 第三步：选择胡牌类型和番数
            Obx(() {
              if (winMethod.value.isEmpty || 
                  (winMethod.value == 'point_pao' && selectedLoser.value == -1)) {
                return const SizedBox.shrink();
              }
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('select_win_type_and_fans'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  
                  // 胡牌类型选择
                  DropdownButtonFormField<String>(
                    value: controller.selectedWinType.value,
                    decoration: InputDecoration(
                      labelText: 'win_type'.tr,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: controller.winTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type.tr));
                    }).toList(),
                    onChanged: (value) async {
                      if (value != null) {
                        controller.selectedWinType.value = value;
                        // 根据当前胡牌方式更新番数
                        if (winMethod.value == 'self_draw') {
                          final fans = await controller.getFansForWinTypeSelfDraw(value);
                          controller.selectedFans.value = fans;
                        } else if (winMethod.value == 'point_pao') {
                          final fans = await controller.getFansForWinTypePointPao(value);
                          controller.selectedFans.value = fans;
                        }
                      }
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 番数显示和修改
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => Text(
                          '${'fans'.tr}: ${controller.selectedFans.value}',
                          style: const TextStyle(fontSize: 14),
                        )),
                      ),
                      IconButton(
                        onPressed: () {
                          _showFansEditDialog(winMethod.value);
                        },
                        icon: Icon(Icons.edit, size: 16, color: Colors.grey[600]),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 抓码番数输入
                  Row(
                    children: [
                      Text('${'zhuama'.tr}: ', style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: zhuamaFans.value.toString()),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '0',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 14),
                          onChanged: (value) {
                            final fans = int.tryParse(value);
                            if (fans != null && fans >= 0) {
                              zhuamaFans.value = fans;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 总番数显示
                  Obx(() => Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text(
                      '${'total_fans'.tr}: ${controller.selectedFans.value + zhuamaFans.value}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                  )),
                ],
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          Obx(() => ElevatedButton(
            onPressed: (winMethod.value.isNotEmpty && 
                       (winMethod.value != 'point_pao' || selectedLoser.value != -1))
                ? () {
                    // 执行胡牌操作
                    if (winMethod.value == 'self_draw') {
                      // 自摸：使用当前点击的玩家
                      _confirmSelfDraw(controller.selectedPlayer.value, zhuamaFans.value);
                    } else {
                      // 点炮：胡牌者是当前点击的玩家，被点炮者是选择的玩家
                      _confirmPointPao(controller.selectedPlayer.value, selectedLoser.value, zhuamaFans.value);
                    }
                    Navigator.of(Get.context!).pop(); // 使用 Navigator 关闭对话框
                  }
                : null,
            child: Text('confirm'.tr),
          )),
        ],
      ),
    );
  }

  // 确认自摸
  void _confirmSelfDraw(int winnerIndex, int zhuamaFans) {
    final fans = controller.selectedFans.value;
    final baseScore = controller.baseScore.value;
    final totalFans = fans + zhuamaFans; // 总番数 = 胡牌番数 + 抓码番数
    final totalScore = totalFans * baseScore;
    
    // 记录变化前的分数
    final oldScores = List<int>.from(controller.playerScores);
    
    // 自摸：一个人收三家人的积分
    controller.playerScores[winnerIndex] += totalScore * 3;
    
    // 其他三家扣分
    for (int i = 0; i < controller.playerScores.length; i++) {
      if (i != winnerIndex) {
        controller.playerScores[i] -= totalScore;
      }
    }
    
    // 添加详细记录
    final record = MahjongRecord(
      playerIndex: winnerIndex,
      playerName: controller.playerNames[winnerIndex],
      score: totalScore * 3,
              description: 'self_draw_description'.tr.replaceAll('{win_type}', controller.selectedWinType.value.tr).replaceAll('{fans}', fans.toString()).replaceAll('{zhuama_text}', zhuamaFans > 0 ? 'with_zhuama'.tr.replaceAll('{zhuama}', zhuamaFans.toString()) : ''),
      timestamp: DateTime.now(),
      scoresAtTime: oldScores,
      scoreChanges: {
        for (int i = 0; i < controller.playerNames.length; i++)
          controller.playerNames[i]: controller.playerScores[i] - oldScores[i],
      },
    );
    controller.records.add(record);
    
    // 为其他玩家添加扣分记录
    for (int i = 0; i < controller.playerScores.length; i++) {
      if (i != winnerIndex) {
        final loseRecord = MahjongRecord(
          playerIndex: i,
          playerName: controller.playerNames[i],
          score: -totalScore,
          description: 'be_self_draw_description'.tr.replaceAll('{win_type}', controller.selectedWinType.value.tr).replaceAll('{total_fans}', (fans + zhuamaFans).toString()).replaceAll('{zhuama_text}', zhuamaFans > 0 ? 'with_zhuama'.tr.replaceAll('{zhuama}', zhuamaFans.toString()) : ''),
          timestamp: DateTime.now(),
          scoresAtTime: oldScores,
          scoreChanges: {
            for (int j = 0; j < controller.playerNames.length; j++)
              controller.playerNames[j]: controller.playerScores[j] - oldScores[j],
          },
        );
        controller.records.add(loseRecord);
      }
    }
    
    controller.savePlayerScores();
    
    Get.snackbar(
      'self_draw_success'.tr,
      'self_draw_announce'.tr.replaceAll('{player}', controller.playerNames[winnerIndex]).replaceAll('{score}', (totalScore * 3).toString()).replaceAll('{zhuama_text}', zhuamaFans > 0 ? 'with_zhuama'.tr.replaceAll('{zhuama}', zhuamaFans.toString()) : ''),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // 确认点炮
  void _confirmPointPao(int winnerIndex, int loserIndex, int zhuamaFans) {
    final fans = controller.selectedFans.value;
    final baseScore = controller.baseScore.value;
    final totalFans = fans + zhuamaFans; // 总番数 = 胡牌番数 + 抓码番数
    final totalScore = totalFans * baseScore;
    
    // 记录变化前的分数
    final oldScores = List<int>.from(controller.playerScores);
    
    // 点炮：胡牌者赢，被点炮者输
    controller.playerScores[winnerIndex] += totalScore;
    controller.playerScores[loserIndex] -= totalScore;
    
    // 添加胡牌者记录
    final winRecord = MahjongRecord(
      playerIndex: winnerIndex,
      playerName: controller.playerNames[winnerIndex],
      score: totalScore,
              description: 'point_pao_description'.tr.replaceAll('{win_type}', controller.selectedWinType.value.tr).replaceAll('{fans}', fans.toString()).replaceAll('{zhuama_text}', zhuamaFans > 0 ? 'with_zhuama'.tr.replaceAll('{zhuama}', zhuamaFans.toString()) : ''),
      timestamp: DateTime.now(),
      scoresAtTime: oldScores,
      scoreChanges: {
        for (int i = 0; i < controller.playerNames.length; i++)
          controller.playerNames[i]: controller.playerScores[i] - oldScores[i],
      },
    );
    controller.records.add(winRecord);
    
    // 添加被点炮者记录
    final loseRecord = MahjongRecord(
      playerIndex: loserIndex,
      playerName: controller.playerNames[loserIndex],
      score: -totalScore,
        description: 'be_point_pao_description'.tr.replaceAll('{win_type}', controller.selectedWinType.value.tr).replaceAll('{total_fans}', (fans + zhuamaFans).toString()).replaceAll('{zhuama_text}', zhuamaFans > 0 ? 'with_zhuama'.tr.replaceAll('{zhuama}', zhuamaFans.toString()) : ''),
      timestamp: DateTime.now(),
      scoresAtTime: oldScores,
      scoreChanges: {
        for (int i = 0; i < controller.playerNames.length; i++)
          controller.playerNames[i]: controller.playerScores[i] - oldScores[i],
      },
    );
    controller.records.add(loseRecord);
    
    controller.savePlayerScores();
    
    Get.snackbar(
      'point_pao_success'.tr,
      'point_pao_announce'.tr.replaceAll('{winner}', controller.playerNames[winnerIndex]).replaceAll('{loser}', controller.playerNames[loserIndex]).replaceAll('{score}', totalScore.toString()).replaceAll('{zhuama_text}', zhuamaFans > 0 ? 'with_zhuama'.tr.replaceAll('{zhuama}', zhuamaFans.toString()) : ''),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // 显示杠牌对话框
  void _showGangDialog() {
    // 杠牌方式选择状态
    final RxString gangMethod = 'ming_gang'.obs;
    final RxInt selectedLoser = (-1).obs;
    final RxInt gangScore = 1.obs; // 默认1番
    
    Get.dialog(
      CustomDialog(
        title: 'gang'.tr,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一步：选择杠牌方式
            Text('select_gang_method'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: () {
                      gangMethod.value = 'ming_gang';
                      gangScore.value = 1; // 明杠1倍
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gangMethod.value == 'ming_gang' 
                        ? const Color(0xFF4CAF50) 
                        : Colors.grey.shade300,
                      foregroundColor: gangMethod.value == 'ming_gang' 
                        ? Colors.white 
                        : Colors.black87,
                    ),
                    child: Text('ming_gang'.tr),
                  )),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: () {
                      gangMethod.value = 'an_gang';
                      gangScore.value = 2; // 暗杠2倍
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gangMethod.value == 'an_gang' 
                        ? const Color(0xFF4CAF50) 
                        : Colors.grey.shade300,
                      foregroundColor: gangMethod.value == 'an_gang' 
                        ? Colors.white 
                        : Colors.black87,
                    ),
                    child: Text('an_gang'.tr),
                  )),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: () {
                      gangMethod.value = 'dian_gang';
                      gangScore.value = 2; // 点杠2倍
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gangMethod.value == 'dian_gang' 
                        ? const Color(0xFF4CAF50) 
                        : Colors.grey.shade300,
                      foregroundColor: gangMethod.value == 'dian_gang' 
                        ? Colors.white 
                        : Colors.black87,
                    ),
                    child: Text('dian_gang'.tr),
                  )),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 第二步：点杠时选择被杠者
            Obx(() {
              if (gangMethod.value != 'dian_gang') return const SizedBox.shrink();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('select_gang_loser'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: controller.playerNames.asMap().entries.map((entry) {
                      final index = entry.key;
                      final name = entry.value;
                      final isSelected = selectedLoser.value == index;
                      
                      return GestureDetector(
                        onTap: () {
                          selectedLoser.value = index;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.red : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? Colors.red : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
            
            // 第三步：番数显示和修改
            Row(
              children: [
                Expanded(
                  child: Obx(() => Text(
                    '${'fans'.tr}: ${gangScore.value}',
                    style: const TextStyle(fontSize: 14),
                  )),
                ),
                IconButton(
                  onPressed: () {
                    _showGangScoreEditDialog(gangMethod.value, gangScore);
                  },
                  icon: Icon(Icons.edit, size: 16, color: Colors.grey[600]),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // 杠牌说明
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Obx(() => Text(
                '${'gang_player'.tr}: ${controller.playerNames[controller.selectedPlayer.value]}',
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              )),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          Obx(() => ElevatedButton(
            onPressed: (gangMethod.value.isNotEmpty && 
                       (gangMethod.value != 'dian_gang' || selectedLoser.value != -1))
                ? () {
                    // 执行杠牌操作
                    if (gangMethod.value == 'ming_gang' || gangMethod.value == 'an_gang') {
                      _confirmGang(controller.selectedPlayer.value, gangMethod.value, gangScore.value);
                    } else {
                      _confirmGangPoint(controller.selectedPlayer.value, selectedLoser.value, gangMethod.value, gangScore.value);
                    }
                    Navigator.of(Get.context!).pop();
                  }
                : null,
            child: Text('confirm'.tr),
          )),
        ],
      ),
    );
  }

  // 确认杠牌（明杠/暗杠）
  void _confirmGang(int playerIndex, String gangMethod, int gangScore) {
    final baseScore = controller.baseScore.value;
    final totalScore = baseScore * gangScore;
    
    // 记录变化前的分数
    final oldScores = List<int>.from(controller.playerScores);
    
    // 杠牌：杠牌者赢，其他人输
    controller.playerScores[playerIndex] += totalScore * 3;
    
    for (int i = 0; i < controller.playerScores.length; i++) {
      if (i != playerIndex) {
        controller.playerScores[i] -= totalScore;
      }
    }
    
    // 添加杠牌者记录
    final gangRecord = MahjongRecord(
      playerIndex: playerIndex,
      playerName: controller.playerNames[playerIndex],
      score: totalScore * 3,
      description: 'gang_description'.tr.replaceAll('{gang_type}', gangMethod).replaceAll('{score}', (totalScore * 3).toString()),
      timestamp: DateTime.now(),
      scoresAtTime: oldScores,
      scoreChanges: {
        for (int i = 0; i < controller.playerNames.length; i++)
          controller.playerNames[i]: controller.playerScores[i] - oldScores[i],
      },
    );
    controller.records.add(gangRecord);
    
    // 为其他玩家添加扣分记录
    for (int i = 0; i < controller.playerScores.length; i++) {
      if (i != playerIndex) {
        final loseRecord = MahjongRecord(
          playerIndex: i,
          playerName: controller.playerNames[i],
          score: -totalScore,
          description: 'be_gang_description'.tr.replaceAll('{gang_type}', gangMethod).replaceAll('{score}', totalScore.toString()),
          timestamp: DateTime.now(),
          scoresAtTime: oldScores,
          scoreChanges: {
            for (int j = 0; j < controller.playerNames.length; j++)
              controller.playerNames[j]: controller.playerScores[j] - oldScores[j],
          },
        );
        controller.records.add(loseRecord);
      }
    }
    
    controller.savePlayerScores();
    
    Get.snackbar(
      'gang_success'.tr,
      'gang_announce'.tr.replaceAll('{player}', controller.playerNames[playerIndex]).replaceAll('{gang_type}', gangMethod).replaceAll('{score}', (totalScore * 3).toString()),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // 确认杠牌（点杠）
  void _confirmGangPoint(int playerIndex, int loserIndex, String gangMethod, int gangScore) {
    final baseScore = controller.baseScore.value;
    final totalScore = baseScore * gangScore;
    
    // 记录变化前的分数
    final oldScores = List<int>.from(controller.playerScores);
    
    // 点杠：杠牌者赢，被杠者输
    controller.playerScores[playerIndex] += totalScore;
    controller.playerScores[loserIndex] -= totalScore;
    
    // 添加杠牌者记录
    final gangRecord = MahjongRecord(
      playerIndex: playerIndex,
      playerName: controller.playerNames[playerIndex],
      score: totalScore,
      description: 'gang_point_description'.tr.replaceAll('{score}', totalScore.toString()),
      timestamp: DateTime.now(),
      scoresAtTime: oldScores,
      scoreChanges: {
        for (int i = 0; i < controller.playerNames.length; i++)
          controller.playerNames[i]: controller.playerScores[i] - oldScores[i],
      },
    );
    controller.records.add(gangRecord);
    
    // 添加被杠者记录
    final loseRecord = MahjongRecord(
      playerIndex: loserIndex,
      playerName: controller.playerNames[loserIndex],
      score: -totalScore,
      description: 'be_gang_point_description'.tr.replaceAll('{score}', totalScore.toString()),
      timestamp: DateTime.now(),
      scoresAtTime: oldScores,
      scoreChanges: {
        for (int i = 0; i < controller.playerNames.length; i++)
          controller.playerNames[i]: controller.playerScores[i] - oldScores[i],
      },
    );
    controller.records.add(loseRecord);
    
    controller.savePlayerScores();
    
    Get.snackbar(
      'gang_point_success'.tr,
      'gang_point_announce'.tr.replaceAll('{player}', controller.playerNames[playerIndex]).replaceAll('{loser}', controller.playerNames[loserIndex]).replaceAll('{score}', totalScore.toString()),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // 显示设置对话框
  void _showSettingsDialog() {
    Get.dialog(
      CustomConfirmDialog(
        title: 'game_settings_mahjong'.tr,
        content: 'game_settings_content'.tr,
        confirmText: 'confirm'.tr,
        cancelText: 'cancel'.tr,
        onConfirm: () {
          Get.back();
        },
      ),
    );
  }

  // 显示重置对话框
  void _showResetDialog() {
    Get.dialog(
      CustomConfirmDialog(
        title: 'confirm_reset_mahjong'.tr,
        content: 'confirm_reset_mahjong_content'.tr,
        confirmText: 'confirm'.tr,
        cancelText: 'cancel'.tr,
        onConfirm: () {
          controller.resetAllScores();
          Get.snackbar(
            'reset_complete_mahjong'.tr,
            'all_data_reset'.tr,
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFF4CAF50),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        },
      ),
    );
  }

  // 显示记录对话框
  void _showRecordsDialog() {
    Get.dialog(
      CustomConfirmDialog(
        title: 'game_records_mahjong'.tr,
        content: 'game_records_content'.tr,
        confirmText: 'confirm'.tr,
        cancelText: 'cancel'.tr,
        onConfirm: () {
          Get.back();
        },
      ),
    );
  }

  // 显示自定义番数对话框
  void _showCustomFansDialog(String winMethod) {
    Get.dialog(
      CustomDialog(
        title: 'custom_fans_title'.tr.replaceAll('{win_type}', controller.selectedWinType.value.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('current_win_type'.tr.replaceAll('{win_type}', controller.selectedWinType.value.tr)),
            const SizedBox(height: 4),
            Text('win_method'.tr.replaceAll('{method}', winMethod), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: controller.selectedFans.value.toString()),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'fans'.tr,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                final fans = int.tryParse(value);
                if (fans != null && fans > 0) {
                  controller.updateSelectedFans(fans);
                }
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                'fans_hint'.tr.replaceAll('{method}', winMethod),
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              // 根据胡牌方式保存到对应的配置
              if (winMethod == 'self_draw') {
                await controller.updateFansForWinTypeSelfDraw(
                  controller.selectedWinType.value,
                  controller.selectedFans.value,
                );
              } else if (winMethod == 'point_pao') {
                await controller.updateFansForWinTypePointPao(
                  controller.selectedWinType.value,
                  controller.selectedFans.value,
                );
              }
              Get.back();
              Get.snackbar(
                'fans_config_save_success'.tr,
                'fans_config_saved'.tr,
                snackPosition: SnackPosition.TOP,
                backgroundColor: const Color(0xFF4CAF50),
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }

  // 显示预设番数对话框
  void _showPresetFansDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('preset_fans_title'.tr.replaceAll('{win_type}', controller.selectedWinType.value.tr)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: controller.fanOptions.length,
            itemBuilder: (context, index) {
              final fans = controller.fanOptions[index];
              return ListTile(
                title: Text('fans_options'.tr.replaceAll('{fans}', fans.toString())),
                trailing: fans == controller.selectedFans.value ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () async {
                  controller.updateSelectedFans(fans);
                  await controller.updateFansForWinType(
                    controller.selectedWinType.value,
                    fans,
                  );
                  Get.back();
                  Get.snackbar(
                    'fans_set_success'.tr,
                    'fans_set_description'.tr.replaceAll('{win_type}', controller.selectedWinType.value.tr).replaceAll('{fans}', fans.toString()),
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: const Color(0xFF4CAF50),
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                },
              );
            },
          ),
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

  // 显示位置切换对话框
  void _showPositionSwitchDialog() {
    // 使用响应式状态管理
    final RxMap<int, int> newPositions = <int, int>{}.obs;
    final List<String> directions = ['east'.tr, 'south'.tr, 'west'.tr, 'north'.tr];
    
    // 初始化：每个玩家默认保持当前位置
    for (int i = 0; i < 4; i++) {
      newPositions[i] = i;
    }
    
    Get.dialog(
      CustomDialog(
        title: 'switch_position'.tr,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('select_new_position_for_each_player'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // 玩家位置选择
            ...List.generate(4, (playerIndex) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${controller.playerNames[playerIndex]} (${'current'.tr}: ${directions[playerIndex]})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        Text('select'.tr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Obx(() => Row(
                      children: directions.asMap().entries.map((entry) {
                        final positionIndex = entry.key;
                        final direction = entry.value;
                        final isSelected = newPositions[playerIndex] == positionIndex;
                        final isOccupied = newPositions.values.where((pos) => pos == positionIndex).length > 1;
                        
                        return Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // 检查是否被其他玩家占用
                                if (isOccupied && !isSelected) {
                                  Get.snackbar(
                                    '⚠️ ${'position_conflict_error'.tr}',
                                    '${'position_occupied'.tr.replaceAll('{direction}', direction)}',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.orange,
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 2),
                                  );
                                  return;
                                }
                                
                                // 更新选择
                                newPositions[playerIndex] = positionIndex;
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 4),
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                    ? const Color(0xFF4CAF50) 
                                    : isOccupied 
                                      ? Colors.red.shade100 
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isSelected 
                                      ? const Color(0xFF4CAF50) 
                                      : isOccupied 
                                        ? Colors.red 
                                        : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  direction,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected 
                                      ? Colors.white 
                                      : isOccupied 
                                        ? Colors.red 
                                        : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )),
                  ],
                ),
              );
            }).toList(),
            
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                'green_selected_red_conflict'.tr,
                style: const TextStyle(fontSize: 10, color: Colors.blue),
              ),
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
              // 检查是否所有位置都被分配
              final usedPositions = newPositions.values.toSet();
              if (usedPositions.length != 4) {
                Get.snackbar(
                  'position_allocation_incomplete'.tr,
                  'please_ensure_each_position_has_player'.tr,
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
                return;
              }
              
              // 检查是否有位置冲突
              final hasConflict = newPositions.values.toSet().length != 4;
              if (hasConflict) {
                Get.snackbar(
                  'position_conflict_error'.tr,
                  'please_ensure_one_player_per_position'.tr,
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
                return;
              }
              
              // 执行位置切换
              controller.switchPlayerPositionsFlexible(newPositions);
              Get.back();
              Get.snackbar(
                'position_switch_success'.tr,
                'position_switch_complete'.tr,
                snackPosition: SnackPosition.TOP,
                backgroundColor: const Color(0xFF4CAF50),
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }

  // 显示番数配置对话框
  void _showFansConfigDialog() {
    Get.dialog(
      CustomDialog(
        title: 'fans_config'.tr,
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 自摸番数配置
                Text('self_draw_fans_config'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                const SizedBox(height: 8),
                ...controller.winTypes.map((winType) => _buildFansConfigItem(winType, 'win_selfdraw')).toList(),
                
                const Divider(),
                const SizedBox(height: 8),
                
                // 点炮番数配置
                Text('point_pao_fans_config'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                const SizedBox(height: 8),
                ...controller.winTypes.map((winType) => _buildFansConfigItem(winType, 'win_pointpao')).toList(),
                
                const Divider(),
                const SizedBox(height: 8),
                
                // 抓码番数配置
                Text('zhuama_fans'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildFansConfigItem('抓码', 'zhuama'),
                
                const Divider(),
                const SizedBox(height: 8),
                
                // 杠牌番数配置
                Text('gang_score'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...controller.gangTypes.map((gangType) => _buildFansConfigItem(gangType, 'gang')).toList(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.saveAllFansConfig();
              Get.back();
              Get.snackbar(
                '✅ 保存成功',
                '番数配置已保存',
                snackPosition: SnackPosition.TOP,
                backgroundColor: const Color(0xFF4CAF50),
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  // 构建番数配置项
  Widget _buildFansConfigItem(String type, String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(type, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextField(
              controller: TextEditingController(
                text: controller.getFansForType(type, category).toString(),
              ),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '番数',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              onChanged: (value) {
                final fans = int.tryParse(value);
                if (fans != null && fans >= 0) {
                  controller.setFansForType(type, category, fans);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
} 