import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/base/base_view.dart';
import '../controller/football_controller.dart';

class FootballPage extends BaseView<FootballController> {
  const FootballPage({super.key});

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
          title: Text(
            'football_scoring'.tr,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            // 横屏模式切换
            Obx(() => IconButton(
              onPressed: () {
                controller.toggleLandscapeMode();
              },
                          icon: Icon(
              controller.isLandscapeMode ? Icons.screen_rotation : Icons.screen_rotation_alt,
              color: controller.isLandscapeMode ? Colors.yellow : Colors.white,
            ),
            )),
            // 语音开关
            Obx(() => IconButton(
              onPressed: () {
                controller.toggleVoice();
              },
              icon: Icon(
                controller.isVoiceEnabled ? Icons.volume_up : Icons.volume_off,
                color: controller.isVoiceEnabled ? Colors.white : Colors.white.withValues(alpha: 0.6),
              ),
            )),
            // 历史记录按钮
            IconButton(
              onPressed: () {
                Get.toNamed('/football_history');
              },
              icon: const Icon(
                Icons.history,
                color: Colors.white,
              ),
            ),
            // 设置菜单
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
                      const Icon(Icons.settings),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'settings'.tr,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'reset',
                  child: Row(
                    children: [
                      const Icon(Icons.refresh, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'reset'.tr,
                          style: const TextStyle(color: Colors.red),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      } else {
        return null; // 横屏模式下隐藏导航栏
      }
    } else {
      // 竖屏模式下的AppBar
      return AppBar(
        title: Text(
          'football_scoring'.tr,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 横屏模式切换
          Obx(() => IconButton(
            onPressed: () {
              controller.toggleLandscapeMode();
            },
            icon: Icon(
              controller.isLandscapeMode ? Icons.screen_rotation : Icons.screen_rotation_alt,
              color: controller.isLandscapeMode ? Colors.yellow : Colors.white,
            ),
          )),
          // 语音开关
          Obx(() => IconButton(
            onPressed: () {
              controller.toggleVoice();
            },
            icon: Icon(
              controller.isVoiceEnabled ? Icons.volume_up : Icons.volume_off,
              color: controller.isVoiceEnabled ? Colors.white : Colors.white.withValues(alpha: 0.6),
            ),
          )),
          // 历史记录按钮
          IconButton(
            onPressed: () {
              Get.toNamed('/football_history');
            },
            icon: const Icon(
              Icons.history,
              color: Colors.white,
            ),
          ),
          // 设置菜单
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
                    const Icon(Icons.settings),
                    const SizedBox(width: 8),
                    Text('settings'.tr),
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
  }

  @override
  Widget buildContent(BuildContext context) {
    return Obx(() {
      if (controller.isLandscapeMode) {
        // 横屏模式：直接显示横屏布局
        return _buildLandscapeLayout();
      } else {
        // 竖屏模式：保持原有样式
        return _buildPortraitLayout();
      }
    });
  }

  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 时间显示
          _buildTimerSection(),
          const SizedBox(height: 24),
          
          // 比分显示
          _buildScoreSection(),
          const SizedBox(height: 24),
          
          // 得分按钮
          _buildScoreButtons(),
          const SizedBox(height: 24),
          
          // 比赛信息
          _buildGameInfo(),
        ],
      ),
    );
  }

  // 时间显示区域
  Widget _buildTimerSection() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // 时间显示 - 可点击修改
          GestureDetector(
            onTap: () {
              _showTimeEditDialog();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.formattedTime,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.edit,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'click_to_modify_time'.tr,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: controller.isTimerRunning ? null : () {
                  controller.startTimer();
                },
                icon: const Icon(Icons.play_arrow),
                label: Text('start'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: controller.isTimerRunning ? () {
                  controller.pauseTimer();
                } : null,
                icon: const Icon(Icons.pause),
                label: Text('pause'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _showResetDialog();
                },
                icon: const Icon(Icons.refresh),
                label: Text('reset'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  // 时间修改对话框
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
                      border: const OutlineInputBorder(),
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
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('quick_settings'.tr + ': '),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: [
                      _buildQuickTimeButton('30_minutes'.tr, 30 * 60),
                      _buildQuickTimeButton('45_minutes'.tr, 45 * 60),
                      _buildQuickTimeButton('90_minutes'.tr, 90 * 60),
                      _buildQuickTimeButton('15_minutes'.tr, 15 * 60),
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
                controller.setRemainingTime(totalSeconds);
                Get.back();
              } else {
                Get.snackbar(
                  'input_error'.tr,
                  'please_enter_valid_time'.tr,
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

  // 比分显示区域
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
      ],
    ));
  }

  // 队伍分数显示
  Widget _buildTeamScore(int teamNumber, String teamName, int score) {
    return Obx(() {
      final isLeading = (teamNumber == 1 && controller.team1Score > controller.team2Score) ||
                       (teamNumber == 2 && controller.team2Score > controller.team1Score);
      
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLeading ? const Color(0xFF4CAF50) : Colors.grey.shade300,
            width: isLeading ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // 队伍名称 - 可点击修改
            GestureDetector(
              onTap: () {
                _showTeamNameEditDialog(Get.context!, controller, teamNumber, teamName);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      teamName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isLeading ? const Color(0xFF4CAF50) : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
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
            // 分数 - 可点击修改
            GestureDetector(
              onTap: () {
                _showScoreEditDialog(Get.context!, controller, teamNumber, teamName, score);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  score.toString(),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isLeading ? const Color(0xFF4CAF50) : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // 得分按钮区域
  Widget _buildScoreButtons() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            'goal'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 主队进球按钮
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.addOneGoal(1);
                  },
                  icon: const Icon(Icons.sports_soccer),
                  label: Text(
                    'team_goal'.tr.replaceAll('{team}', controller.team1Name),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    overlayColor: Colors.transparent,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 客队进球按钮
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.addOneGoal(2);
                  },
                  icon: const Icon(Icons.sports_soccer),
                  label: Text(
                    'team_goal'.tr.replaceAll('{team}', controller.team2Name),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    overlayColor: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  // 比赛信息区域
  Widget _buildGameInfo() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'match_info'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Color(0xFF4CAF50)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'leading'.tr + ': ${controller.leadingTeam}',
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'score_difference'.tr + ': ${controller.scoreDifference} ' + 'goals'.tr,
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'status'.tr + ': ${controller.isTimerRunning ? "in_progress".tr : controller.isTimerPaused ? "paused".tr : "not_started".tr}',
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  // 队伍名称编辑对话框
  void _showTeamNameEditDialog(BuildContext context, FootballController controller, int teamNumber, String currentName) {
    final textController = TextEditingController(text: currentName);
    
    Get.dialog(
      AlertDialog(
        title: Text('modify_team_name'.tr.replaceAll('{team}', teamNumber == 1 ? 'home_team'.tr : 'away_team'.tr)),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: 'team_name'.tr,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = textController.text.trim();
              if (newName.isNotEmpty) {
                if (teamNumber == 1) {
                  controller.setTeamNames(newName, controller.team2Name);
                } else {
                  controller.setTeamNames(controller.team1Name, newName);
                }
                Get.back();
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

  // 分数编辑对话框
  void _showScoreEditDialog(BuildContext context, FootballController controller, int teamNumber, String teamName, int currentScore) {
    final textController = TextEditingController(text: currentScore.toString());
    
    Get.dialog(
      AlertDialog(
        title: Text('modify_team_score'.tr.replaceAll('{team}', teamName)),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: 'score'.tr,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              final newScore = int.tryParse(textController.text);
              if (newScore != null && newScore >= 0) {
                if (teamNumber == 1) {
                  controller.addScore(1, newScore - controller.team1Score);
                } else {
                  controller.addScore(2, newScore - controller.team2Score);
                }
                Get.back();
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

  // 设置对话框
  void _showSettingsDialog() {
    final team1Controller = TextEditingController(text: controller.team1Name);
    final team2Controller = TextEditingController(text: controller.team2Name);
    int selectedHalfTime = controller.halfTimeMinutes;
    int selectedExtraTime = controller.extraTimeMinutes;

    Get.dialog(
      AlertDialog(
        title: Text('match_settings'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: team1Controller,
              decoration: InputDecoration(
                labelText: 'home_team_name'.tr,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: team2Controller,
              decoration: InputDecoration(
                labelText: 'away_team_name'.tr,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  child: Text('half_time'.tr + ': '),
                ),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedHalfTime,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [30, 35, 40, 45, 50].map((minutes) {
                      return DropdownMenuItem(
                        value: minutes,
                        child: Text('$minutes ' + 'minutes'.tr),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedHalfTime = value ?? 45;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  child: Text('extra_time'.tr + ': '),
                ),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedExtraTime,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [10, 15, 20].map((minutes) {
                      return DropdownMenuItem(
                        value: minutes,
                        child: Text('$minutes ' + 'minutes'.tr),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedExtraTime = value ?? 15;
                    },
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
              controller.setTeamNames(team1Controller.text, team2Controller.text);
              controller.setHalfTime(selectedHalfTime);
              controller.setExtraTime(selectedExtraTime);
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

  // 重置对话框
  void _showResetDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('confirm_reset'.tr),
                  content: Text('confirm_reset_content'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              // 先关闭对话框
              Get.back();
              // 然后执行重置
              controller.resetAll();
              // 最后显示重置完成提示
              await Future.delayed(const Duration(milliseconds: 100));
              Get.snackbar(
                'reset_complete'.tr,
                'reset_complete_message'.tr,
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('reset'.tr),
          ),
        ],
      ),
    );
  }

  // 横屏布局
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
                        child: Obx(() => Flexible(
                          child: Text(
                            controller.formattedTimeInSeconds,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
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
    
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // 队伍名称
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: isTeam1 ? Colors.blue[900] : Colors.red[900],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  teamName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          // 分数显示
          Expanded(
            child: Center(
              child: Text(
                teamScore.toString(),
                style: const TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // 进球按钮
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.addScore(teamNumber, 1);
                },
                icon: const Icon(Icons.sports_soccer, color: Colors.white),
                                                  label: Text(
                    'team_goal'.tr.replaceAll('{team}', teamName),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTeam1 ? Colors.blue[700] : Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  overlayColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 