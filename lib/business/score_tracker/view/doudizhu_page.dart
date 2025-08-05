import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/base/base_view.dart';
import '../controller/mahjong_controller.dart';
import 'package:common_ui/common_ui.dart';

class DoudizhuPage extends BaseView<MahjongController> {
  const DoudizhuPage({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('斗地主'),
      backgroundColor: const Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // 语音开关
        Obx(() => IconButton(
          onPressed: () {
            print('切换语音播报');
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
            print('查看历史记录');
            Get.toNamed('/doudizhu-history');
          },
          icon: const Icon(Icons.history),
        ),
        // 设置菜单
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'settings':
                print('打开设置');
                _showSettingsDialog();
                break;
              case 'reset':
                print('打开重置确认');
                _showResetDialog();
                break;
              case 'records':
                print('查看记录');
                _showRecordsDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('设置'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'records',
              child: Row(
                children: [
                  Icon(Icons.history),
                  SizedBox(width: 8),
                  Text('记录'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'reset',
              child: Row(
                children: [
                  Icon(Icons.refresh, color: Colors.red),
                  SizedBox(width: 8),
                  Text('重置', style: TextStyle(color: Colors.red)),
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 游戏信息区域
          _buildGameInfo(),
          
          const SizedBox(height: 16),
          
          // 玩家分数区域
          _buildPlayerScoreSection(),
          
          const SizedBox(height: 16),
          
          // 游戏设置区域
          _buildOperationSection(),
          
          const SizedBox(height: 16),
          
          // 重置按钮
          Container(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                _showResetDialog();
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('重置游戏'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerScoreSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '玩家分数',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          // 3个玩家一排显示
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _buildPlayerCard(index),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(int playerIndex) {
    return Obx(() {
      final playerName = controller.playerNames[playerIndex];
      final playerScore = controller.playerScores[playerIndex];
      final isLandlord = controller.landlordPlayer.value == playerIndex;
      
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isLandlord 
              ? const Color(0xFFFF9800).withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLandlord 
                ? const Color(0xFFFF9800)
                : Colors.grey.shade200,
            width: isLandlord ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 地主标识
            if (isLandlord)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '地主',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isLandlord) const SizedBox(height: 4),
            
            // 玩家名称 - 可点击修改
            GestureDetector(
              onTap: () {
                print('修改玩家名称: $playerName');
                _showPlayerNameEditDialog(playerIndex, playerName);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                    playerName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isLandlord 
                          ? const Color(0xFFFF9800)
                          : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.edit,
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            // 分数显示 - 可点击修改
            GestureDetector(
              onTap: () {
                print('修改玩家分数: $playerScore');
                _showScoreEditDialog(playerIndex, playerName, playerScore);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  playerScore.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isLandlord 
                        ? const Color(0xFFFF9800)
                        : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildOperationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '游戏设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          // 基础分值和倍数设置 - 一行显示
          Row(
            children: [
              // 基础分值
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('基础分', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: TextEditingController(text: controller.baseScore.value.toString()),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        hintText: '分值',
                        suffixText: '分',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        controller.setBaseScore(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // 倍数设置
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('倍数', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() {
                            final currentValue = controller.currentMultiplier.value;
                            final isCustom = ![1, 2, 4, 8, 16, 32].contains(currentValue);
                            
                            return DropdownButtonFormField<int>(
                              value: isCustom ? -1 : currentValue,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                              items: [
                                ...([1, 2, 4, 8, 16, 32].map((multiplier) {
                                  return DropdownMenuItem(
                                    value: multiplier,
                                    child: Text('${multiplier}倍'),
                                  );
                                })),
                                DropdownMenuItem(
                                  value: -1, // 自定义标识
                                  child: Text(isCustom ? '${currentValue}倍' : '自定义'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  if (value == -1) {
                                    // 选择自定义，显示输入框
                                    _showCustomMultiplierDialog();
                                  } else {
                                    controller.setMultiplier(value);
                                  }
                                }
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          

          
          // 地主选择
          const Text(
            '选择地主',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Obx(() => ElevatedButton(
                    onPressed: () {
                      controller.selectLandlord(index);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.landlordPlayer.value == index
                          ? const Color(0xFFFF9800)
                          : Colors.grey.shade300,
                      foregroundColor: controller.landlordPlayer.value == index
                          ? Colors.white
                          : Colors.black87,
                    ),
                    child: Text(
                      controller.playerNames[index],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 16),
          
          // 游戏结果按钮
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showGameResultDialog(true); // 地主赢
                  },
                  icon: const Icon(Icons.emoji_events),
                  label: const Text('地主赢'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showGameResultDialog(false); // 农民赢
                  },
                  icon: const Icon(Icons.agriculture),
                  label: const Text('农民赢'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildGameInfo() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '斗地主',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                    '${controller.records.length} 局',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // 游戏统计信息
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events, color: Colors.orange[600], size: 16),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                    '领先: ${controller.leadingPlayer}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up, color: Colors.orange[600], size: 16),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                    '最高: ${controller.highestScore}分',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ));
  }

  void _showPlayerNameEditDialog(int playerIndex, String currentName) {
    Get.dialog(
      CustomInputDialog(
        title: '修改玩家${playerIndex + 1}名称',
        labelText: '玩家名称',
        initialValue: currentName,
        onConfirm: (newName) async {
          if (newName.trim().isNotEmpty) {
            print('修改玩家名称: $newName');
            await controller.setPlayerName(playerIndex, newName.trim());
          } else {
            Get.snackbar(
              '输入错误',
              '玩家名称不能为空',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }

  void _showScoreEditDialog(int playerIndex, String playerName, int currentScore) {
    Get.dialog(
      CustomInputDialog(
        title: '修改$playerName分数',
        labelText: '分数',
        initialValue: currentScore.toString(),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '请输入分数';
          }
          final score = int.tryParse(value);
          if (score == null) {
            return '请输入有效数字';
          }
          if (score < -999 || score > 999) {
            return '分数范围：-999到999';
          }
          return null;
        },
        onConfirm: (newScore) async {
          final score = int.tryParse(newScore);
          if (score != null && score >= -999 && score <= 999) {
            await controller.setPlayerScore(playerIndex, score);
          }
        },
      ),
    );
  }



  void _showWinGameDialog() async {
    int selectedWinner = controller.selectedPlayer.value;
    String selectedWinType = controller.winTypes[0];
    int selectedFans = await controller.getFansForWinType(selectedWinType);
    bool isSelfDraw = true;
    int selectedLoser = 0; // 被点炮者
    int selectedZhuama = 0; // 抓码番数
    
    // 确保初始输家不是胡牌者
    if (selectedLoser == selectedWinner) {
      for (int i = 0; i < 4; i++) {
        if (i != selectedWinner) {
          selectedLoser = i;
          break;
        }
      }
    }
    
    Get.dialog(
      AlertDialog(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.casino, color: const Color(0xFF4CAF50)),
            const SizedBox(width: 8),
            const Text('记录胡牌', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 胡牌者选择
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person, color: const Color(0xFF4CAF50)),
                              const SizedBox(width: 8),
                              const Text('胡牌者', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            value: selectedWinner,
                            decoration: InputDecoration(
                              labelText: '选择胡牌者',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            items: List.generate(4, (index) {
                              return DropdownMenuItem(
                                value: index,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: const Color(0xFF4CAF50),
                                      child: Text(
                                        controller.playerNames[index].substring(0, 1),
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        controller.playerNames[index],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                selectedWinner = value ?? 0;
                                if (selectedLoser == selectedWinner) {
                                  for (int i = 0; i < 4; i++) {
                                    if (i != selectedWinner) {
                                      selectedLoser = i;
                                      break;
                                    }
                                  }
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // 胡牌类型和番数
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: const Color(0xFF4CAF50)),
                              const SizedBox(width: 8),
                              const Text('胡牌类型', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: selectedWinType,
                            decoration: InputDecoration(
                              labelText: '选择胡牌类型',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            items: controller.winTypes.map((type) {
                              return DropdownMenuItem(value: type, child: Text(type));
                            }).toList(),
                            onChanged: (value) async {
                              setState(() {
                                selectedWinType = value ?? controller.winTypes[0];
                              });
                              final newFans = await controller.getFansForWinType(selectedWinType);
                              setState(() {
                                selectedFans = newFans;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.casino, color: const Color(0xFF4CAF50)),
                              const SizedBox(width: 8),
                              const Text('番数设置', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: selectedFans,
                                  decoration: InputDecoration(
                                    labelText: '胡牌番数',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  items: controller.fanOptions.map((fans) {
                                    return DropdownMenuItem(value: fans, child: Text('$fans 番'));
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedFans = value ?? 1;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: selectedZhuama,
                                  decoration: InputDecoration(
                                    labelText: '抓码番数',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  items: [0, 1, 2, 3, 4, 5, 6, 8, 10, 12, 16, 24, 32, 48, 64].map((fans) {
                                    return DropdownMenuItem(value: fans, child: Text('$fans 番'));
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedZhuama = value ?? 0;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // 胡牌方式
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.touch_app, color: const Color(0xFF4CAF50)),
                              const SizedBox(width: 8),
                              const Text('胡牌方式', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<bool>(
                                  title: const Text('自摸'),
                                  value: true,
                                  groupValue: isSelfDraw,
                                  activeColor: const Color(0xFF4CAF50),
                                  onChanged: (value) {
                                    setState(() {
                                      isSelfDraw = value ?? true;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<bool>(
                                  title: const Text('点炮'),
                                  value: false,
                                  groupValue: isSelfDraw,
                                  activeColor: const Color(0xFF4CAF50),
                                  onChanged: (value) {
                                    setState(() {
                                      isSelfDraw = value ?? false;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          
                          if (!isSelfDraw) ...[
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: selectedLoser,
                              decoration: InputDecoration(
                                labelText: '被点炮者',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              items: List.generate(4, (index) {
                                if (index == selectedWinner) return null;
                                return DropdownMenuItem(
                                  value: index,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: const Color(0xFF4CAF50),
                                        child: Text(
                                          controller.playerNames[index].substring(0, 1),
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          controller.playerNames[index],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).where((item) => item != null).cast<DropdownMenuItem<int>>().toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedLoser = value ?? 0;
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 保存用户自定义的番数
              await controller.updateFansForWinType(selectedWinType, selectedFans);
              
              if (isSelfDraw) {
                print('记录胡牌: ${controller.playerNames[selectedWinner]} 胡牌 $selectedWinType 自摸 ${selectedFans}番 + 抓码${selectedZhuama}番');
                await controller.winGameSelfDraw(selectedWinner, selectedFans, selectedZhuama, selectedWinType);
              } else {
                print('记录胡牌: ${controller.playerNames[selectedWinner]} 胡牌 $selectedWinType 点炮 ${controller.playerNames[selectedLoser]} ${selectedFans}番 + 抓码${selectedZhuama}番');
                await controller.winGamePointPao(selectedWinner, selectedLoser, selectedFans, selectedZhuama, selectedWinType);
              }
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('确定'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text('确认重置', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: const Text('确定要重置所有分数和记录吗？\n\n注意：玩家名字将保持不变。'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('取消'),
                    ),
                    ElevatedButton(
                                              onPressed: () async {
                          await controller.resetAllScores();
                          Get.back(); // 关闭确认对话框
                          Get.back(); // 关闭胡牌对话框
                        },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('确认重置'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('重置'),
          ),
        ],
      ),
    );
  }

  void _showCustomMultiplierDialog() {
    Get.dialog(
      CustomInputDialog(
        title: '自定义倍数',
        labelText: '倍数',
        initialValue: controller.currentMultiplier.value.toString(),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '请输入倍数';
          }
          final multiplier = int.tryParse(value);
          if (multiplier == null) {
            return '请输入有效数字';
          }
          if (multiplier <= 0 || multiplier > 999) {
            return '倍数范围：1到999';
          }
          return null;
        },
        onConfirm: (value) {
          final multiplier = int.tryParse(value);
          if (multiplier != null && multiplier > 0 && multiplier <= 999) {
            controller.setMultiplier(multiplier);
          }
        },
      ),
    );
  }

  void _showRecordsDialog() {
    Get.dialog(
      CustomDialog(
        title: '游戏记录',
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Obx(() {
            if (controller.records.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('暂无记录', style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                      backgroundColor: record.score > 0 ? Colors.green : Colors.red,
                      child: Text(
                        record.playerName.substring(0, 1),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      record.description,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: Text(
                      '${record.playerName} • ${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')}:${record.timestamp.second.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    trailing: Text(
                      '${record.score > 0 ? '+' : ''}${record.score}分',
                      style: TextStyle(
                        color: record.score > 0 ? Colors.green : Colors.red,
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
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    final fields = List.generate(3, (index) => {
      'key': 'player${index + 1}',
      'label': '玩家${index + 1}名称',
      'initialValue': controller.playerNames[index],
    });
    
    Get.dialog(
      CustomMultiInputDialog(
        title: '游戏设置',
        fields: fields,
        onConfirm: (values) async {
          for (int i = 0; i < 3; i++) {
            final name = values['player${i + 1}']?.trim();
            if (name != null && name.isNotEmpty) {
              await controller.setPlayerName(i, name);
            }
          }
        },
      ),
    );
  }

  void _showGangDialog() {
    int selectedPlayer = controller.selectedPlayer.value;
    String selectedGangType = controller.gangTypes[0];
    int selectedFans = 1; // 默认明杠1番
    bool useCustomFans = false;
    final customFansController = TextEditingController();
    int selectedTarget = 0; // 被点杠者
    
    // 确保初始被点杠者不是杠牌者
    if (selectedTarget == selectedPlayer) {
      for (int i = 0; i < 4; i++) {
        if (i != selectedPlayer) {
          selectedTarget = i;
          break;
        }
      }
    }
    
    Get.dialog(
      AlertDialog(
        title: const Text('记录杠牌'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 选择杠牌者
                DropdownButtonFormField<int>(
                  value: selectedPlayer,
                  decoration: const InputDecoration(
                    labelText: '杠牌者',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(4, (index) {
                    return DropdownMenuItem(
                      value: index,
                      child: Text(
                        controller.playerNames[index],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      selectedPlayer = value ?? 0;
                      // 如果杠牌者是被点杠者，重置被点杠者选择
                      if (selectedTarget == selectedPlayer) {
                        for (int i = 0; i < 4; i++) {
                          if (i != selectedPlayer) {
                            selectedTarget = i;
                            break;
                          }
                        }
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // 选择杠牌类型
                DropdownButtonFormField<String>(
                  value: selectedGangType,
                  decoration: const InputDecoration(
                    labelText: '杠牌类型',
                    border: OutlineInputBorder(),
                  ),
                  items: controller.gangTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                                              onChanged: (value) {
                              setState(() {
                                selectedGangType = value ?? controller.gangTypes[0];
                                // 根据杠牌类型设置默认番数
                                switch (selectedGangType) {
                                  case '明杠':
                                    selectedFans = 1;
                                    break;
                                  case '暗杠':
                                    selectedFans = 2;
                                    break;
                                  case '点杠':
                                    selectedFans = 2;
                                    break;
                                }
                              });
                            },
                ),
                const SizedBox(height: 16),
                
                // 番数选择
                Row(
                  children: [
                    const Text('番数: '),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<bool>(
                            value: false,
                            groupValue: useCustomFans,
                            onChanged: (value) {
                              setState(() {
                                useCustomFans = value ?? false;
                              });
                            },
                          ),
                          const Text('预设'),
                          const SizedBox(width: 16),
                          Radio<bool>(
                            value: true,
                            groupValue: useCustomFans,
                            onChanged: (value) {
                              setState(() {
                                useCustomFans = value ?? true;
                              });
                            },
                          ),
                          const Text('自定义'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // 番数输入
                if (useCustomFans) ...[
                  TextField(
                    controller: customFansController,
                    decoration: const InputDecoration(
                      labelText: '自定义番数',
                      border: OutlineInputBorder(),
                      hintText: '请输入番数',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ] else ...[
                  DropdownButtonFormField<int>(
                    value: selectedFans,
                    decoration: const InputDecoration(
                      labelText: '番数',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(10, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1} 番'),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        selectedFans = value ?? 1;
                      });
                    },
                  ),
                ],
                

                
                // 被点杠者选择（仅当选择点杠时显示）
                if (selectedGangType == '点杠') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('被点杠者: '),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: selectedTarget,
                          decoration: const InputDecoration(
                            labelText: '选择被点杠者',
                            border: OutlineInputBorder(),
                          ),
                          items: List.generate(4, (index) {
                            if (index == selectedPlayer) return null; // 跳过杠牌者
                            return DropdownMenuItem(
                              value: index,
                              child: Text(
                                controller.playerNames[index],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).where((item) => item != null).cast<DropdownMenuItem<int>>().toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTarget = value ?? 0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              int fans = selectedFans;
              if (useCustomFans) {
                final customFans = int.tryParse(customFansController.text);
                if (customFans != null && customFans > 0) {
                  fans = customFans;
                } else {
                  Get.snackbar(
                    '输入错误',
                    '请输入有效的番数',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }
              }
              
              if (selectedGangType == '点杠') {
                print('记录点杠: ${controller.playerNames[selectedPlayer]} 点杠 ${controller.playerNames[selectedTarget]} ${fans}番');
                await controller.gangPoint(selectedPlayer, selectedTarget, fans);
              } else {
                print('记录杠牌: ${controller.playerNames[selectedPlayer]} $selectedGangType ${fans}番');
                await controller.gang(selectedPlayer, selectedGangType, fans);
              }
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    Get.dialog(
      CustomConfirmDialog(
        title: '确认重置',
        content: '确定要重置所有分数和记录吗？\n\n重置后：\n• 所有玩家分数变为 0\n• 清空所有记录',
        confirmText: '重置',
        cancelText: '取消',
        confirmColor: Colors.red,
        onConfirm: () async {
          print('确认重置所有数据');
          controller.resetAllScores();
          await Future.delayed(const Duration(milliseconds: 100));
          Get.snackbar(
            '✅ 重置完成',
            '所有分数和记录已清空',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFF4CAF50),
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

  void _showGameResultDialog(bool landlordWins) {
    final landlordIndex = controller.landlordPlayer.value;
    final landlordName = controller.playerNames[landlordIndex];
    final baseScore = controller.baseScore.value;
    final multiplier = controller.currentMultiplier.value;
    final landlordScore = baseScore * multiplier * 2; // 地主分数 = 基础分 × 倍数 × 2
    final farmerScore = baseScore * multiplier; // 农民分数 = 基础分 × 倍数 × 1
    
    String resultText = landlordWins 
        ? '地主 $landlordName 获胜！'
        : '农民获胜！';
    
    String contentText = '基础分值: ${baseScore}分\n'
        '倍数: ${multiplier}倍\n'
        '地主分值: ${landlordScore}分 (基础分×倍数×2)\n'
        '农民分值: ${farmerScore}分 (基础分×倍数×1)\n\n'
        '${landlordWins 
            ? '地主获得 ${landlordScore} 分，农民各失去 ${farmerScore} 分'
            : '地主失去 ${landlordScore} 分，农民各获得 ${farmerScore} 分'}';
    
    Get.dialog(
      CustomConfirmDialog(
        title: resultText,
        content: contentText,
        confirmText: '确认',
        cancelText: '取消',
        confirmColor: landlordWins ? Colors.orange : Colors.green,
        onConfirm: () {
          controller.recordGameResult(landlordWins);
        },
      ),
    );
  }
} 