import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/data/game_result.dart';
import '../../../core/utils/game_result_manager.dart';
import 'package:common_ui/common_ui.dart';

class RacketSportRecord {
  final int team1Score;
  final int team2Score;
  final String description;
  final DateTime timestamp;
  final List<int> scoresAtTime; // 记录当前比分

  RacketSportRecord({
    required this.team1Score,
    required this.team2Score,
    required this.description,
    required this.timestamp,
    required this.scoresAtTime,
  });
}

class RacketSportController extends BaseController {
  // 运动类型
  final String sportType; // 'badminton'、'pingpong' 或 'volleyball'
  
  // 分数制选择
  final RxInt selectedScoreSystem = 11.obs; // 默认11分制
  final List<int> scoreSystems = [3, 5, 11, 21];
  
  // 队伍信息
  final RxString team1Name = 'home_team'.obs;
  final RxString team2Name = 'away_team'.obs;
  
  // 比分
  final RxInt team1Score = 0.obs;
  final RxInt team2Score = 0.obs;
  
  // 比赛状态
  final RxBool isGameOver = false.obs;
  final RxString winner = ''.obs;
  
  // 历史记录
  final RxList<RacketSportRecord> records = <RacketSportRecord>[].obs;
  
  // 语音播报
  final VoiceAnnouncer voiceAnnouncer = VoiceAnnouncer();
  
  // 横屏模式相关
  final RxBool isLandscapeMode = false.obs;
  final RxBool isAppBarVisible = true.obs;
  final RxBool isScreenWakeLockEnabled = false.obs;
  final RxBool isFullScreenEnabled = false.obs;
  final RxBool showTimeInSeconds = false.obs;
  
  RacketSportController(this.sportType);
  
  @override
  void onInit() {
    super.onInit();
    _loadGameData();
    
    // 确保每次进入页面时都重置为竖屏模式
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  
  @override
  void onClose() {
    // 确保退出时恢复设备方向
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.onClose();
  }
  
  // 获取存储键前缀
  String get _storagePrefix => '${sportType}_';
  
  // 获取运动名称
  String get sportName {
    switch (sportType) {
      case 'badminton':
        return 'badminton'.tr;
      case 'pingpong':
        return 'pingpong'.tr;
      case 'volleyball':
        return 'volleyball'.tr;
      default:
        return 'racket_sport'.tr;
    }
  }
  
  // 横屏模式相关 getters
  bool get isLandscapeModeValue => isLandscapeMode.value;
  bool get isAppBarVisibleValue => isAppBarVisible.value;
  bool get isScreenWakeLockEnabledValue => isScreenWakeLockEnabled.value;
  bool get isFullScreenEnabledValue => isFullScreenEnabled.value;
  bool get showTimeInSecondsValue => showTimeInSeconds.value;
  
  // 加载游戏数据
  Future<void> _loadGameData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 加载队伍名称
          team1Name.value = prefs.getString('${_storagePrefix}team1_name') ?? 'home_team'.tr;
    team2Name.value = prefs.getString('${_storagePrefix}team2_name') ?? 'away_team'.tr;
      
      // 加载分数
      team1Score.value = prefs.getInt('${_storagePrefix}team1_score') ?? 0;
      team2Score.value = prefs.getInt('${_storagePrefix}team2_score') ?? 0;
      
      // 加载分数制
      selectedScoreSystem.value = prefs.getInt('${_storagePrefix}score_system') ?? 11;
      
      // 重置比赛状态
      isGameOver.value = false;
      winner.value = '';
      
      // 加载横屏模式设置 - 每次进入页面都重置为竖屏模式
      isLandscapeMode.value = false; // 强制重置为竖屏模式
      isAppBarVisible.value = prefs.getBool('${_storagePrefix}is_appbar_visible') ?? true;
      isScreenWakeLockEnabled.value = prefs.getBool('${_storagePrefix}is_screen_wake_lock_enabled') ?? false;
      isFullScreenEnabled.value = prefs.getBool('${_storagePrefix}is_full_screen_enabled') ?? false;
      showTimeInSeconds.value = prefs.getBool('${_storagePrefix}show_time_in_seconds') ?? false;
    } catch (e) {
      print('加载${sportName}数据失败: $e');
    }
  }
  
  // 设置队伍名称
  Future<void> setTeamName(int teamIndex, String name) async {
    if (teamIndex == 1) {
      team1Name.value = name;
    } else if (teamIndex == 2) {
      team2Name.value = name;
    }
    
    // 保存到本地存储
    try {
      final prefs = await SharedPreferences.getInstance();
      if (teamIndex == 1) {
        await prefs.setString('${_storagePrefix}team1_name', name);
      } else if (teamIndex == 2) {
        await prefs.setString('${_storagePrefix}team2_name', name);
      }
    } catch (e) {
      print('save_team_name_failed'.tr + ': $e');
    }
  }
  
  // 设置分数制
  Future<void> setScoreSystem(int scoreSystem) async {
    if (scoreSystems.contains(scoreSystem)) {
      selectedScoreSystem.value = scoreSystem;
      
      // 保存到本地存储
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('${_storagePrefix}score_system', scoreSystem);
      } catch (e) {
        print('保存分数制失败: $e');
      }
    }
  }
  
  // 保存分数
  Future<void> _saveScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('${_storagePrefix}team1_score', team1Score.value);
      await prefs.setInt('${_storagePrefix}team2_score', team2Score.value);
    } catch (e) {
      print('保存分数失败: $e');
    }
  }
  
  // 判断是否获胜
  bool _checkWinCondition(int score1, int score2) {
    final maxScore = selectedScoreSystem.value;
    
    // 3分制和5分制：先达到分数者获胜
    if (maxScore == 3 || maxScore == 5) {
      return score1 >= maxScore || score2 >= maxScore;
    }
    
    // 11分制和21分制：必须领先2分
    if (maxScore == 11 || maxScore == 21) {
      // 如果一方达到最大分数，必须领先2分
      if (score1 >= maxScore) {
        return score1 - score2 >= 2;
      }
      if (score2 >= maxScore) {
        return score2 - score1 >= 2;
      }
    }
    
    return false;
  }
  
  // 判断是否平局（需要继续比赛）
  bool _isDeuce(int score1, int score2) {
    final maxScore = selectedScoreSystem.value;
    
    // 11分制和21分制：达到最大分数但未领先2分
    if (maxScore == 11 || maxScore == 21) {
      if (score1 >= maxScore && score1 - score2 == 1) {
        return true; // 10:11, 20:21 等情况
      }
      if (score2 >= maxScore && score2 - score1 == 1) {
        return true; // 11:10, 21:20 等情况
      }
    }
    
    return false;
  }
  
  // 队伍1得分
  Future<void> addTeam1Score() async {
    if (isGameOver.value) return;
    
    final newScore = team1Score.value + 1;
    final oldScore = team2Score.value;
    
    // 检查是否获胜
    if (_checkWinCondition(newScore, oldScore)) {
      team1Score.value = newScore;
      isGameOver.value = true;
      winner.value = team1Name.value;
      
              _addRecord(newScore, oldScore, 'team_wins_record'.tr.replaceAll('{team}', team1Name.value));
      
      // 语音播报
              voiceAnnouncer.announce('team_wins_announce'.tr.replaceAll('{team}', team1Name.value).replaceAll('{score1}', newScore.toString()).replaceAll('{score2}', oldScore.toString()));
    } else {
      team1Score.value = newScore;
      
      String description = 'team_scores_record'.tr.replaceAll('{team}', team1Name.value);
      if (_isDeuce(newScore, oldScore)) {
        description += 'draw_continue_game'.tr;
      }
      
      _addRecord(newScore, oldScore, description);
      
      // 语音播报
              voiceAnnouncer.announce('team_scores_announce'.tr.replaceAll('{team}', team1Name.value).replaceAll('{score1}', newScore.toString()).replaceAll('{score2}', oldScore.toString()));
    }
    
    await _saveScores();
  }

  // 队伍2得分
  Future<void> addTeam2Score() async {
    if (isGameOver.value) return;
    
    final oldScore = team1Score.value;
    final newScore = team2Score.value + 1;
    
    // 检查是否获胜
    if (_checkWinCondition(oldScore, newScore)) {
      team2Score.value = newScore;
      isGameOver.value = true;
      winner.value = team2Name.value;
      
              _addRecord(oldScore, newScore, 'team_wins_record'.tr.replaceAll('{team}', team2Name.value));
      
      // 语音播报
              voiceAnnouncer.announce('team_wins_announce'.tr.replaceAll('{team}', team2Name.value).replaceAll('{score1}', oldScore.toString()).replaceAll('{score2}', newScore.toString()));
    } else {
      team2Score.value = newScore;
      
      String description = 'team_scores_record'.tr.replaceAll('{team}', team2Name.value);
      if (_isDeuce(oldScore, newScore)) {
        description += 'draw_continue_game'.tr;
      }
      
      _addRecord(oldScore, newScore, description);
      
      // 语音播报
              voiceAnnouncer.announce('team_scores_announce'.tr.replaceAll('{team}', team2Name.value).replaceAll('{score1}', oldScore.toString()).replaceAll('{score2}', newScore.toString()));
    }
    
    await _saveScores();
  }
  
  // 手动修改分数
  Future<void> setScore(int team1NewScore, int team2NewScore) async {
    if (isGameOver.value) return;
    
    final oldTeam1Score = team1Score.value;
    final oldTeam2Score = team2Score.value;
    
    team1Score.value = team1NewScore;
    team2Score.value = team2NewScore;
    
    // 检查是否获胜
    if (_checkWinCondition(team1NewScore, team2NewScore)) {
      isGameOver.value = true;
      if (team1NewScore > team2NewScore) {
        winner.value = team1Name.value;
      } else {
        winner.value = team2Name.value;
      }
      
              _addRecord(team1NewScore, team2NewScore, 'manual_modify_team_wins'.tr.replaceAll('{winner}', winner.value));
      
      // 语音播报
              voiceAnnouncer.announce('manual_score_team_wins'.tr.replaceAll('{winner}', winner.value));
    } else {
      _addRecord(team1NewScore, team2NewScore, 'manual_modify_score'.tr);
      
      // 语音播报
              voiceAnnouncer.announce('manual_score_announce'.tr.replaceAll('{score1}', team1NewScore.toString()).replaceAll('{score2}', team2NewScore.toString()));
    }
    
    await _saveScores();
  }
  
  // 添加记录
  void _addRecord(int team1Score, int team2Score, String description) {
    final record = RacketSportRecord(
      team1Score: team1Score,
      team2Score: team2Score,
      description: description,
      timestamp: DateTime.now(),
      scoresAtTime: [team1Score, team2Score],
    );
    
    records.add(record);
  }
  
  // 重置比赛
  Future<void> resetGame() async {
    team1Score.value = 0;
    team2Score.value = 0;
    isGameOver.value = false;
    winner.value = '';
    
    await _saveScores();
    
    // 语音播报
    voiceAnnouncer.announce('match_reset_announce'.tr);
  }
  
  // 获取当前状态描述
  String get gameStatus {
    if (isGameOver.value) {
      return 'game_over_winner'.tr.replaceAll('{winner}', winner.value);
    }
    
    final maxScore = selectedScoreSystem.value;
    final score1 = team1Score.value;
    final score2 = team2Score.value;
    
    if (_isDeuce(score1, score2)) {
      return 'draw_continue'.tr;
    }
    
    if (score1 >= maxScore || score2 >= maxScore) {
      return 'match_point_need_lead'.tr;
    }
    
    return 'in_progress'.tr;
  }
  
  // 获取获胜条件描述
  String get winConditionDescription {
    final maxScore = selectedScoreSystem.value;
    
    if (maxScore == 3 || maxScore == 5) {
      return 'win_condition_simple'.tr.replaceAll('{score}', maxScore.toString());
    } else {
      return 'win_condition_advanced'.tr.replaceAll('{score}', maxScore.toString());
    }
  }
  
  // 保存游戏结果
  Future<void> saveGameResult() async {
    final gameResult = GameResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gameType: sportType,
      team1Name: team1Name.value,
      team2Name: team2Name.value,
      team1Score: team1Score.value,
      team2Score: team2Score.value,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      duration: 0,
      additionalData: {
        'scoreSystem': selectedScoreSystem.value,
        'isGameOver': isGameOver.value,
        'winner': winner.value,
        'records': records.map((record) => {
          'team1Score': record.team1Score,
          'team2Score': record.team2Score,
          'description': record.description,
          'timestamp': record.timestamp.millisecondsSinceEpoch,
        }).toList(),
      },
    );

    await GameResultManager.saveGameResult(gameResult);
    
    Get.snackbar(
      'save_success'.tr,
      'match_result_saved'.tr,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
  
  // 横屏模式相关方法
  void toggleLandscapeMode() {
    if (!isLandscapeMode.value) {
      // 进入横屏模式：先隐藏AppBar，再切换方向
      isAppBarVisible.value = false;
      
      Future.delayed(const Duration(milliseconds: 300), () {
        isLandscapeMode.value = true;
        // 使用try-catch避免方向切换错误
        try {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        } catch (e) {
          // 如果方向切换失败，至少更新UI状态
          print('orientation_switch_failed'.tr + ': $e');
        }
        
        // 自动启用屏幕长亮
        _enableWakeLock();
      });
    } else {
      // 退出横屏模式：先切换方向，再显示AppBar
      isLandscapeMode.value = false;
      
      // 使用try-catch避免方向切换错误
      try {
        // 先设置所有方向，然后限制为竖屏
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        
        // 延迟后限制为竖屏
        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
          } catch (e) {
            print('portrait_orientation_switch_failed'.tr + ': $e');
          }
        });
      } catch (e) {
        print('方向切换失败: $e');
      }
      
      // 显示AppBar
      isAppBarVisible.value = true;
      
      // 禁用屏幕长亮
      _disableWakeLock();
    }
  }
  
  void toggleAppBarVisibility() {
    isAppBarVisible.value = !isAppBarVisible.value;
  }
  
  void showAppBar() {
    isAppBarVisible.value = true;
  }
  
  void hideAppBar() {
    isAppBarVisible.value = false;
  }
  
  void toggleFullScreen() {
    isFullScreenEnabled.value = !isFullScreenEnabled.value;
    
    if (isFullScreenEnabled.value) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
  
  void toggleTimeDisplayMode() {
    showTimeInSeconds.value = !showTimeInSeconds.value;
  }
  
  void _enableWakeLock() {
    WakelockPlus.enable();
    isScreenWakeLockEnabled.value = true;
  }
  
  void _disableWakeLock() {
    WakelockPlus.disable();
    isScreenWakeLockEnabled.value = false;
  }
} 