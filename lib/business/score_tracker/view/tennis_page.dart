import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/base/base_view.dart';
import '../controller/tennis_controller.dart';
import 'package:common_ui/common_ui.dart';

class TennisPage extends BaseView<TennisController> {
  const TennisPage({super.key});

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
    if (controller.isLandscapeModeValue) {
      if (controller.isAppBarVisibleValue) {
        return AppBar(
          title: Text('tennis_scoring'.tr),
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
                controller.isLandscapeModeValue ? Icons.screen_rotation : Icons.screen_rotation_alt,
                color: controller.isLandscapeModeValue ? Colors.yellow : Colors.white,
              ),
            ),
          ],
        );
      } else {
        return null; // 横屏模式下隐藏导航栏
      }
    }
    
    // 竖屏模式下的AppBar
    return AppBar(
      title: Text('tennis_scoring'.tr),
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
            controller.isLandscapeModeValue ? Icons.screen_rotation : Icons.screen_rotation_alt,
            color: controller.isLandscapeModeValue ? Colors.yellow : Colors.white,
          ),
        ),
        // 重置按钮
        IconButton(
          onPressed: () {
            controller.resetGame();
          },
          icon: const Icon(Icons.refresh),
        ),
        // 历史记录按钮
        IconButton(
          onPressed: () {
            Get.toNamed('/tennis-history');
          },
          icon: const Icon(Icons.history),
        ),
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Obx(() {
      if (controller.isLandscapeModeValue) {
        return _buildLandscapeLayout();
      } else {
        return _buildPortraitLayout();
      }
    });
  }
  
  Widget _buildPortraitLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 总比分显示（Set-Game）
            _buildTotalScoreDisplay(),
            const SizedBox(height: 20),
            // 当前局比分显示（Point级别）
            _buildCurrentGameScore(),
            const SizedBox(height: 20),
            // 得分按钮
            _buildScoreButtons(),
            const SizedBox(height: 20),
            // 设置按钮
            _buildSettingsButtons(),
          ],
        ),
      ),
    );
  }
  
  // 总比分显示（Set-Game）
  Widget _buildTotalScoreDisplay() {
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
            'total_score'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTeamTotalScore(1, controller.team1Name.value),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildTeamTotalScore(2, controller.team2Name.value),
              ),
            ],
          ),
        ],
      ),
    ));
  }
  
  Widget _buildTeamTotalScore(int teamNumber, String teamName) {
    return Obx(() {
      final teamSets = teamNumber == 1 ? controller.team1Sets.value : controller.team2Sets.value;
      final teamGames = teamNumber == 1 ? controller.team1Games.value : controller.team2Games.value;
    
      return GestureDetector(
        onTap: () {
          _showTeamNameDialog(teamNumber);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Row(
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
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        'set'.tr,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        teamSets.toString(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'game'.tr,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        teamGames.toString(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
  
  // 当前局比分显示（Point级别）
  Widget _buildCurrentGameScore() {
    return Obx(() {
      final team1Name = controller.team1Name.value;
      final team2Name = controller.team2Name.value;
      final team1Point = controller.getTennisScoreDisplay(controller.team1Points.value);
      final team2Point = controller.getTennisScoreDisplay(controller.team2Points.value);

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
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
            Text('current_game'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            Text(
              '	$team1Point : $team2Point',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              '$team1Name    vs    $team2Name',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    });
  }
  
  Widget _buildTeamCurrentScore(int teamNumber, String teamName) {
    final teamPoints = teamNumber == 1 ? controller.team1Points.value : controller.team2Points.value;
    final tennisScore = controller.getTennisScoreDisplay(teamPoints);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: teamNumber == 1 ? Colors.blue.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: teamNumber == 1 ? Colors.blue.shade200 : Colors.red.shade200,
        ),
      ),
      child: Column(
        children: [
          Text(
            teamName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: teamNumber == 1 ? Colors.blue.shade700 : Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tennisScore,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: teamNumber == 1 ? Colors.blue.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
  
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
            'score'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 队伍1得分按钮
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.isGameOver.value ? null : () {
                    controller.addScore(1);
                  },
                  icon: const Icon(Icons.sports_tennis),
                  label: Text('team_score_button'.tr.replaceAll('{team}', controller.team1Name.value)),
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
              // 队伍2得分按钮
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.isGameOver.value ? null : () {
                    controller.addScore(2);
                  },
                  icon: const Icon(Icons.sports_tennis),
                  label: Text('team_score_button'.tr.replaceAll('{team}', controller.team2Name.value)),
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
  
  Widget _buildSettingsButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _showSettingsDialog();
              },
              icon: const Icon(Icons.settings),
              label: Text('settings'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _showResetDialog();
              },
              icon: const Icon(Icons.refresh, color: Colors.red),
              label: Text('reset_all'.tr, style: const TextStyle(color: Colors.red)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 横屏布局
  Widget _buildLandscapeLayout() {
    return GestureDetector(
      onTap: () {
        controller.toggleAppBarVisibility();
      },
      behavior: HitTestBehavior.opaque,
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
            // 悬浮当前局比分显示
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
                                     child: Text(
                     controller.getCurrentPointDisplay(),
                     style: const TextStyle(
                       fontSize: 24,
                       fontWeight: FontWeight.bold,
                       color: Colors.white,
                     ),
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
    final teamName = isTeam1 ? controller.team1Name.value : controller.team2Name.value;
    final teamSets = isTeam1 ? controller.team1Sets.value : controller.team2Sets.value;
    final teamGames = isTeam1 ? controller.team1Games.value : controller.team2Games.value;
    final teamPoints = isTeam1 ? controller.team1Points.value : controller.team2Points.value;
    final tennisScore = controller.getTennisScoreDisplay(teamPoints);
    
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
          // 总比分显示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.grey[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      'Set',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      teamSets.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Game',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      teamGames.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 当前局分数显示
          Expanded(
            child: Center(
              child: Text(
                tennisScore,
                style: const TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // 得分按钮
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: controller.isGameOver.value ? null : () {
                  controller.addScore(teamNumber);
                },
                icon: const Icon(Icons.sports_tennis, color: Colors.white),
                label: Text(
                  'team_score_button'.tr.replaceAll('{team}', teamName),
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
  
  // 队伍名称编辑对话框
  void _showTeamNameDialog(int teamNumber) {
    final textController = TextEditingController(
      text: teamNumber == 1 ? controller.team1Name.value : controller.team2Name.value,
    );
    
    Get.dialog(
      AlertDialog(
        title: Text('set_team_name'.tr.replaceAll('{team}', teamNumber.toString())),
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
                  controller.setTeamNames(newName, controller.team2Name.value);
                } else {
                  controller.setTeamNames(controller.team1Name.value, newName);
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
    Get.dialog(
      AlertDialog(
        title: Text('settings'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('voice_announcement'.tr),
              subtitle: Text(controller.voiceAnnouncer.isEnabled.value ? 'enabled'.tr : 'disabled'.tr),
              trailing: Switch(
                value: controller.voiceAnnouncer.isEnabled.value,
                onChanged: (value) {
                  controller.toggleVoice();
                },
              ),
            ),
            ListTile(
              title: Text('screen_wake_lock'.tr),
              subtitle: Text(controller.isScreenWakeLockEnabledValue ? 'enabled'.tr : 'disabled'.tr),
              trailing: Switch(
                value: controller.isScreenWakeLockEnabledValue,
                onChanged: (value) {
                  controller.toggleScreenWakeLock();
                },
              ),
            ),
            ListTile(
              title: Text('full_screen_mode'.tr),
              subtitle: Text(controller.isFullScreenEnabledValue ? 'enabled'.tr : 'disabled'.tr),
              trailing: Switch(
                value: controller.isFullScreenEnabledValue,
                onChanged: (value) {
                  controller.toggleFullScreen();
                },
              ),
            ),
          ],
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
  
  // 重置对话框
  void _showResetDialog() {
    Get.dialog(
      CustomConfirmDialog(
        title: 'confirm_reset_all'.tr,
        content: 'confirm_reset_all_content'.tr,
        confirmText: 'confirm'.tr,
        cancelText: 'cancel'.tr,
        onConfirm: () {
          controller.resetGame();
          Get.back();
          Get.snackbar(
            'reset_complete'.tr,
            'score_time_timer_reset'.tr,
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFF4CAF50),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        },
      ),
    );
  }
} 