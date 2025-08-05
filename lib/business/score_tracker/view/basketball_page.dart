import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/base/base_view.dart';
import '../controller/basketball_controller.dart';
import 'package:common_ui/common_ui.dart';

class BasketballPage extends BaseView<BasketballController> {
  const BasketballPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: buildAppBar(context),
        body: buildBody(context),
      );
    });
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    // 横屏模式下，根据点击状态决定是否显示AppBar
    if (controller.isLandscapeMode) {
      if (controller.isAppBarVisible) {
        return AppBar(
          title: Text('basketball_scoring'.tr),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            // 横屏模式切换
            IconButton(
              onPressed: () {
                controller.toggleLandscapeMode();
              },
              icon: const Icon(Icons.screen_rotation_alt),
            ),
            // 全屏模式切换
            IconButton(
              onPressed: () {
                controller.toggleFullScreen();
              },
              icon: Icon(
                controller.isFullScreenEnabled ? Icons.fullscreen_exit : Icons.fullscreen,
                color: controller.isFullScreenEnabled ? Colors.yellow : Colors.white,
              ),
            ),
          ],
        );
      } else {
        return null;
      }
    }
    
    // 竖屏模式下显示正常AppBar
    return AppBar(
        title: Text('basketball_scoring'.tr),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 横屏模式切换
          IconButton(
            onPressed: () {
              controller.toggleLandscapeMode();
            },
            icon: Icon(
              controller.isLandscapeMode ? Icons.screen_rotation : Icons.screen_rotation_alt,
              color: controller.isLandscapeMode ? Colors.yellow : Colors.white,
            ),
          ),
          // History button
          IconButton(
            onPressed: () {
              Get.toNamed('/basketball-history');
            },
            icon: Icon(
              Icons.history,
              color: Colors.white,
            ),
          ),
          // Voice switch
          IconButton(
            onPressed: () {
              controller.toggleVoice();
            },
            icon: Icon(
              controller.isVoiceEnabled ? Icons.volume_up : Icons.volume_off,
              color: controller.isVoiceEnabled ? Colors.white : Colors.white.withOpacity(0.6),
            ),
          ),
          // Settings menu
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  _showSettingsDialog();
                  break;
                case 'reset':
                  _showResetDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('settings'.tr),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever),
                    SizedBox(width: 8),
                    Text('reset_all'.tr),
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
    return Obx(() {
      if (controller.isLandscapeMode) {
        // 横屏模式：直接显示横屏布局，不在这里处理AppBar
        return _buildLandscapeLayout();
      } else {
        // 竖屏模式：保持原有样式
        return _buildPortraitLayout();
      }
    });
  }

  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 游戏信息区域
          _buildGameInfo(),
          
          const SizedBox(height: 20),
          
          // 队伍分数区域
          Row(
            children: [
              // 主队
              Expanded(
                child: _buildTeamCard(
                  teamName: controller.team1Name,
                  score: controller.team1Score,
                  teamNumber: 1,
                  isLeading: controller.team1Score > controller.team2Score,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 客队
              Expanded(
                child: _buildTeamCard(
                  teamName: controller.team2Name,
                  score: controller.team2Score,
                  teamNumber: 2,
                  isLeading: controller.team2Score > controller.team1Score,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 分数按钮区域
          _buildScoreButtons(),
        ],
      ),
    );
  }

  Widget _buildGameInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 时间显示
          Obx(() => GestureDetector(
            onTap: () {
              _showTimeSettingDialog();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    controller.isTimerRunning ? Icons.pause : Icons.play_arrow,
                    color: const Color(0xFF4CAF50),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.formattedTime,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.timer,
                    color: const Color(0xFF4CAF50),
                    size: 20,
                  ),
                ],
              ),
            ),
          )),
          
          const SizedBox(height: 12),
          
          // 计时器控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 开始/暂停按钮
              Obx(() => ElevatedButton.icon(
                onPressed: () {
                  if (controller.isTimerRunning) {
                    controller.pauseTimer();
                  } else {
                  controller.startTimer();
                  }
                },
                icon: Icon(
                  controller.isTimerRunning ? Icons.pause : Icons.play_arrow,
                ),
                label: Text(controller.isTimerRunning ? 'pause'.tr : 'start'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
              )),
              
              // 重置按钮
              ElevatedButton.icon(
                onPressed: () {
                  _showResetScoreDialog();
                },
                icon: const Icon(Icons.refresh),
                label: Text('reset'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard({
    required String teamName,
    required int score,
    required int teamNumber,
    required bool isLeading,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLeading ? const Color(0xFF4CAF50) : Colors.grey[300]!,
          width: isLeading ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 队伍名称
          GestureDetector(
            onTap: () => _showTeamNameDialog(teamNumber),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                teamName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isLeading ? const Color(0xFF4CAF50) : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 分数显示
          GestureDetector(
            onTap: () => _showScoreEditDialog(teamNumber),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                score.toString(),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return GestureDetector(
      onTap: () {
        // 点击屏幕切换导航栏显示状态
        controller.toggleAppBarVisibility();
      },
      behavior: HitTestBehavior.opaque, // 确保点击事件能被捕获
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Stack(
          children: [
            // 主内容区域
            Row(
              children: [
                // 左侧队伍
                Expanded(
                  child: _buildLandscapeTeamSection(1),
                ),
                // 中间分隔线
                Container(
                  width: 2,
                  color: Colors.grey[700],
                ),
                // 右侧队伍
                Expanded(
                  child: _buildLandscapeTeamSection(2),
                ),
              ],
            ),
            // 悬浮时间显示
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 播放/暂停按钮
                      Obx(() => IconButton(
                        onPressed: () {
                          if (controller.isTimerRunning) {
                            controller.pauseTimer();
                          } else {
                            controller.startTimer();
                          }
                        },
                        icon: Icon(
                          controller.isTimerRunning ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      )),
                      const SizedBox(width: 8),
                      // 时间显示（可点击切换显示模式）
                      GestureDetector(
                        onTap: () {
                          controller.toggleTimeDisplayMode();
                        },
                        child: Obx(() => Text(
                          controller.formattedTimeInSeconds,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )),
                      ),
                      const SizedBox(width: 8),
                      // 重置按钮
                      IconButton(
                        onPressed: () {
                          controller.resetTimer();
                        },
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeTeamSection(int teamNumber) {
    final isTeam1 = teamNumber == 1;
    final teamName = isTeam1 ? controller.team1Name : controller.team2Name;
    final teamScore = isTeam1 ? controller.team1Score : controller.team2Score;
    final isFullScreen = controller.isFullScreenEnabled;
    
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // 队伍名称
          Expanded(
            flex: 2,
            child: Center(
              child: GestureDetector(
                onTap: () => _showTeamNameDialog(teamNumber),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    teamName,
                    style: TextStyle(
                      fontSize: isFullScreen ? 36 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
          
          // 分数显示
          Expanded(
            flex: 4,
            child: Center(
              child: GestureDetector(
                onTap: () => _showScoreEditDialog(teamNumber),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    teamScore.toString(),
                    style: TextStyle(
                      fontSize: isFullScreen ? 140 : 100,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // 加分按钮区域
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [1, 2, 3].map((points) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: ElevatedButton(
                  onPressed: () {
                    controller.addPoints(teamNumber, points);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    overlayColor: Colors.transparent,
                  ),
                  child: Text(
                    '+$points',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeScoreButton({required int points, required int teamNumber, required bool isAdd}) {
    final color = isAdd ? Colors.green : Colors.red;
    return Container(
      margin: const EdgeInsets.all(2),
      child: ElevatedButton(
        onPressed: () {
          if (isAdd) {
            controller.addPoints(teamNumber, points);
          } else {
            controller.subtractPoints(teamNumber, points);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          points.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'quick_score'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // 主队加分按钮
          Row(
            children: [
              Expanded(
                child: Text(
                  controller.team1Name,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              ..._buildTeamScoreButtons(1),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 客队加分按钮
          Row(
            children: [
              Expanded(
                child: Text(
                  controller.team2Name,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              ..._buildTeamScoreButtons(2),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTeamScoreButtons(int teamNumber) {
    return [1, 2, 3].map((points) => Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton(
          onPressed: () {
            controller.addPoints(teamNumber, points);
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.grey[700]),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            elevation: MaterialStateProperty.all(0),
            shadowColor: MaterialStateProperty.all(Colors.transparent),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            minimumSize: MaterialStateProperty.all(const Size(0, 48)),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            '+$points',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    )).toList();
  }

  void _showTimeEditDialog() {
    final minutesController = TextEditingController(
      text: (controller.remainingTime ~/ 60).toString()
    );
    final secondsController = TextEditingController(
      text: (controller.remainingTime % 60).toString()
    );
    
    Get.dialog(
      AlertDialog(
        title: Text('modify_time'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: minutesController,
                    decoration: InputDecoration(
                      labelText: 'minutes'.tr,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(':', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: secondsController,
                    decoration: InputDecoration(
                      labelText: 'seconds'.tr,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('quick_setup'.tr),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: [
                                    _buildQuickTimeButton('five_minutes'.tr, 5 * 60),
              _buildQuickTimeButton('ten_minutes'.tr, 10 * 60),
              _buildQuickTimeButton('twelve_minutes'.tr, 12 * 60),
              _buildQuickTimeButton('twenty_four_minutes'.tr, 24 * 60),
                    ],
                  ),
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
          ElevatedButton(
            onPressed: () {
              final minutes = int.tryParse(minutesController.text) ?? 0;
              final seconds = int.tryParse(secondsController.text) ?? 0;
              final totalSeconds = minutes * 60 + seconds;
              
              if (totalSeconds > 0) {
                controller.setGameTime(minutes);
                controller.setRemainingTime(totalSeconds);
                Get.back();
              } else {
                        Get.snackbar(
          'input_error'.tr,
          'please_input_valid_time'.tr,
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTimeButton(String label, int seconds) {
    return ElevatedButton(
      onPressed: () {
        final minutes = seconds ~/ 60;
        controller.setGameTime(minutes);
        controller.setRemainingTime(seconds);
        Get.back();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 32),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildScoreSection() {
    return Obx(() => Column(
      children: [
        Row(
          children: [
            // 队伍1
            Expanded(
              child: _buildTeamScore(1, controller.team1Name, controller.team1Score),
            ),
            // 比分分隔符
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'VS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
            // 队伍2
            Expanded(
              child: _buildTeamScore(2, controller.team2Name, controller.team2Score),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 比赛状态
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'leading_team'.tr.replaceAll('{team}', controller.leadingTeam),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'score_difference'.tr + ': ${controller.scoreDifference}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget _buildTeamScore(int teamNumber, String teamName, int score) {
      return Container(
      padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            // 队伍名称 - 可点击修改
            GestureDetector(
              onTap: () {
              _showTeamNameDialog(teamNumber);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    teamName,
                  style: const TextStyle(
                    fontSize: 16,
                      fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 比分显示 - 可点击修改
            GestureDetector(
              onTap: () {
              _showScoreEditDialog(teamNumber);
              },
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
              child: SizedBox(
                width: 60,
                child: Text(
                  score.toString(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildScoreButton(String text, VoidCallback onPressed, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOperationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            'operation'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showResetScoreDialog();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text('reset_score'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showResetDialog();
                  },
                  icon: const Icon(Icons.clear_all),
                  label: Text('reset_all_data'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
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

  void _showTeamNameDialog(int teamNumber) {
    final currentName = teamNumber == 1 ? controller.team1Name : controller.team2Name;
    
    Get.dialog(
      CustomInputDialog(
        title: 'set_team_name'.tr.replaceAll('{number}', teamNumber.toString()),
                labelText: 'team_name'.tr,
        initialValue: currentName,
        onConfirm: (value) {
          if (value.trim().isNotEmpty) {
            controller.setTeamName(teamNumber, value.trim());
          }
        },
      ),
    );
  }

  void _showScoreEditDialog(int teamNumber) {
    final currentScore = teamNumber == 1 ? controller.team1Score : controller.team2Score;
    
    Get.dialog(
      CustomInputDialog(
        title: 'set_team_score'.tr.replaceAll('{number}', teamNumber.toString()),
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
          if (score < 0 || score > 999) {
            return 'score_range'.tr;
          }
          return null;
        },
        onConfirm: (value) {
          final newScore = int.tryParse(value.trim());
          if (newScore != null) {
            controller.setScore(teamNumber, newScore);
          }
        },
      ),
    );
  }

  void _showSettingsDialog() {
    Get.dialog(
      CustomDialog(
        title: 'settings'.tr,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Voice settings
            ListTile(
              leading: Icon(
                controller.isVoiceEnabled ? Icons.volume_up : Icons.volume_off,
                color: const Color(0xFF4CAF50),
              ),
              title: Text('voice_announcement'.tr),
              subtitle: Text(controller.isVoiceEnabled ? 'enabled'.tr : 'disabled'.tr),
              trailing: Switch(
                value: controller.isVoiceEnabled,
                onChanged: (value) {
                  controller.toggleVoice();
                  Get.back();
                },
                activeColor: const Color(0xFF4CAF50),
              ),
            ),
            // Screen wake lock settings
            ListTile(
              leading: Icon(
                controller.isScreenWakeLockEnabled ? Icons.wb_sunny : Icons.brightness_2,
                color: const Color(0xFF4CAF50),
              ),
              title: Text('screen_wake_lock'.tr),
              subtitle: Text(controller.isScreenWakeLockEnabled ? 'enabled'.tr : 'disabled'.tr),
              trailing: Switch(
                value: controller.isScreenWakeLockEnabled,
                onChanged: (value) {
                  controller.toggleScreenWakeLock();
                  Get.back();
                },
                activeColor: const Color(0xFF4CAF50),
              ),
            ),
            // Full screen settings
            ListTile(
              leading: Icon(
                controller.isFullScreenEnabled ? Icons.fullscreen_exit : Icons.fullscreen,
                color: const Color(0xFF4CAF50),
              ),
              title: Text('full_screen_mode'.tr),
              subtitle: Text(controller.isFullScreenEnabled ? 'enabled'.tr : 'disabled'.tr),
              trailing: Switch(
                value: controller.isFullScreenEnabled,
                    onChanged: (value) {
                  controller.toggleFullScreen();
                  Get.back();
                    },
                activeColor: const Color(0xFF4CAF50),
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'close'.tr,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    Get.dialog(
      CustomConfirmDialog(
        title: 'confirm_reset_all'.tr,
        content: 'confirm_reset_all_content'.tr,
        confirmText: 'confirm'.tr,
        cancelText: 'cancel'.tr,
        onConfirm: () async {
          // Execute reset
          controller.resetAll();
          // Show reset completion prompt
          await Future.delayed(const Duration(milliseconds: 100));
          Get.snackbar(
            'reset_complete'.tr,
            'score_time_timer_reset'.tr,
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

  void _showTimeSettingDialog() {
    Get.dialog(
      CustomInputDialog(
        title: 'set_game_time'.tr,
        labelText: 'game_time_minutes'.tr,
        initialValue: controller.gameTimeMinutes.toString(),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'please_input_game_time'.tr;
          }
          final time = int.tryParse(value);
          if (time == null) {
            return 'please_input_valid_number'.tr;
          }
          if (time <= 0 || time > 120) {
            return 'time_range'.tr;
          }
          return null;
        },
        onConfirm: (value) {
          final newTime = int.tryParse(value.trim());
          if (newTime != null && newTime > 0) {
            controller.setGameTime(newTime);
          }
        },
      ),
    );
  }

  void _showResetScoreDialog() {
    Get.dialog(
      CustomConfirmDialog(
        title: 'confirm_reset_score_time'.tr,
        content: 'confirm_reset_score_time_content'.tr,
        confirmText: 'confirm'.tr,
        cancelText: 'cancel'.tr,
        onConfirm: () async {
          // Execute reset
          controller.resetAll();
          // Show reset completion prompt
          await Future.delayed(const Duration(milliseconds: 100));
          Get.snackbar(
            'reset_complete'.tr,
            'score_time_reset'.tr,
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
} 