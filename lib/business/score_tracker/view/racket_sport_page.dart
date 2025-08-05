import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/base/base_view.dart';
import '../controller/racket_sport_controller.dart';

class RacketSportPage extends BaseView<RacketSportController> {
  const RacketSportPage({super.key});

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
          title: Text('${controller.sportName}${'scoring'.tr}'),
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
      title: Text('${controller.sportName}${'scoring'.tr}'),
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
            Get.toNamed('/racket_sport_history', arguments: controller.sportType);
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
            // 游戏信息
            _buildGameInfo(),
            const SizedBox(height: 16),
            
            // 计分系统选择
            _buildScoreSystemSection(),
            const SizedBox(height: 16),
            
            // 比分显示
            _buildScoreDisplay(),
            const SizedBox(height: 16),
            

            
            // 计分按钮
            _buildScoreButtons(),
            const SizedBox(height: 16),
            
            // 操作区域
            _buildOperationSection(),
          ],
        ),
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
        child: Row(
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
      ),
    );
  }

  Widget _buildGameInfo() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            controller.gameStatus,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.winConditionDescription,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ));
  }

  Widget _buildScoreSystemSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'scoring_system'.tr,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Row(
            children: controller.scoreSystems.map((score) {
              final isSelected = controller.selectedScoreSystem.value == score;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ElevatedButton(
                    onPressed: () {
                      controller.setScoreSystem(score);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade50,
                      foregroundColor: isSelected ? Colors.white : Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      'score_points'.tr.replaceAll('{score}', score.toString()),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
  }

  Widget _buildScoreDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4CAF50)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 队伍1分数（可点击修改）
          SizedBox(
            width: 80,
            child: Obx(() => GestureDetector(
              onTap: () => _showScoreEditDialog(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  controller.team1Score.value.toString(),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )),
          ),
          const Text(
            ':',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          // 队伍2分数（可点击修改）
          SizedBox(
            width: 80,
            child: Obx(() => GestureDetector(
              onTap: () => _showScoreEditDialog(2),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  controller.team2Score.value.toString(),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTeamNameField(1),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTeamNameField(2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamNameField(int teamNumber) {
    final isTeam1 = teamNumber == 1;
    final teamName = isTeam1 ? controller.team1Name.value : controller.team2Name.value;
    final label = isTeam1 ? 'Team A' : 'Team B';
    
    return GestureDetector(
      onTap: () => _showTeamNameDialog(teamNumber),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                teamName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.edit,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildTeamScoreButton(1, controller.team1Name.value),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTeamScoreButton(2, controller.team2Name.value),
        ),
      ],
    );
  }

  Widget _buildTeamScoreButton(int team, String teamName) {
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
            'team_score'.tr.replaceAll('{team}', teamName),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (team == 1) {
                  controller.addTeam1Score();
                } else {
                  controller.addTeam2Score();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                '+1',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationSection() {
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
            'operations'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                controller.resetGame();
              },
              icon: const Icon(Icons.refresh),
              label: Text('reset_match'.tr),
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
        ],
      ),
    );
  }

  void _showTeamNameDialog(int teamNumber) {
    final currentName = teamNumber == 1 ? controller.team1Name.value : controller.team2Name.value;
    
    Get.dialog(
      AlertDialog(
        title: Text('set_team_name'.tr.replaceAll('{team}', teamNumber.toString())),
        content: TextField(
          controller: TextEditingController(text: currentName),
          decoration: InputDecoration(
            labelText: 'team_name'.tr,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              final textController = (Get.dialog as AlertDialog).content as TextField;
              final value = textController.controller?.text ?? '';
              if (value.trim().isNotEmpty) {
                if (teamNumber == 1) {
                  controller.team1Name.value = value.trim();
                } else {
                  controller.team2Name.value = value.trim();
                }
              }
              Get.back();
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

  void _showScoreEditDialog(int teamNumber) {
    final isTeam1 = teamNumber == 1;
    final currentScore = isTeam1 ? controller.team1Score.value : controller.team2Score.value;
    final textController = TextEditingController(text: currentScore.toString());
    
    Get.dialog(
      AlertDialog(
        title: Text('modify_team_score'.tr.replaceAll('{team}', isTeam1 ? controller.team1Name.value : controller.team2Name.value)),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'new_score'.tr,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              final newScore = int.tryParse(textController.text);
              if (newScore != null && newScore >= 0) {
                controller.setScore(
                  teamNumber == 1 ? newScore : controller.team1Score.value,
                  teamNumber == 2 ? newScore : controller.team2Score.value,
                );
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
  
  // 横屏模式布局方法
  Widget _buildLandscapeTeamSection(int teamNumber) {
    final isTeam1 = teamNumber == 1;
    final teamName = isTeam1 ? controller.team1Name.value : controller.team2Name.value;
    final teamScore = isTeam1 ? controller.team1Score.value : controller.team2Score.value;
    
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // 队伍名称
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isTeam1 ? Colors.blue[900] : Colors.red[900],
            ),
            child: Center(
              child: Text(
                teamName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // 分数显示
          Expanded(
            child: GestureDetector(
              onTap: () {
                controller.toggleAppBarVisibility();
              },
              child: Center(
                child: Text(
                  teamScore.toString(),
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // 得分按钮
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (teamNumber == 1) {
                    controller.addTeam1Score();
                  } else {
                    controller.addTeam2Score();
                  }
                },
                icon: Icon(
                  isTeam1 ? Icons.sports_tennis : Icons.sports_tennis,
                  color: Colors.white,
                ),
                label: Text(
                  'team_score_button'.tr.replaceAll('{team}', teamName),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTeam1 ? Colors.blue[700] : Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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