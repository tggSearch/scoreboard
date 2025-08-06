import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/data/game_result.dart';
import '../../../core/utils/game_result_manager.dart';
import 'package:common_ui/common_ui.dart';

class FootballController extends BaseController {
  // 时间相关
  final _remainingTime = (45 * 60).obs; // 默认45分钟，单位：秒
  final _isTimerRunning = false.obs;
  final _isTimerPaused = false.obs;
  Timer? _timer;

  // 队伍信息
  final _team1Name = 'home_team'.obs;
  final _team2Name = 'away_team'.obs;
  final _team1Score = 0.obs;
  final _team2Score = 0.obs;

  // 比赛阶段
  final _currentHalf = 1.obs; // 1: 上半场, 2: 下半场, 3: 加时上半场, 4: 加时下半场
  final _isExtraTime = false.obs; // 是否进入加时
  final _halfTimeMinutes = 45.obs; // 半场时间（分钟）
  final _extraTimeMinutes = 15.obs; // 加时半场时间（分钟）

  // 语音报分
  final _isVoiceEnabled = true.obs;
  final VoiceAnnouncer voiceAnnouncer = VoiceAnnouncer();

  // 横屏模式相关
  final _isLandscapeMode = false.obs;
  final _isAppBarVisible = true.obs;
  final _isScreenWakeLockEnabled = false.obs;
  final _isFullScreenEnabled = false.obs;
  final _showTimeInSeconds = false.obs;

  // 播报相关
  final Set<int> _announcedTimes = <int>{};

  // 比赛开始时间
  DateTime? _gameStartTime;

  // 历史记录
  final RxList<FootballRecord> records = <FootballRecord>[].obs;

  // 存储键名
  static const String _keyTeam1Name = 'football_team1_name';
  static const String _keyTeam2Name = 'football_team2_name';
  static const String _keyTeam1Score = 'football_team1_score';
  static const String _keyTeam2Score = 'football_team2_score';
  static const String _keyCurrentHalf = 'football_current_half';
  static const String _keyIsExtraTime = 'football_is_extra_time';
  static const String _keyHalfTimeMinutes = 'football_half_time_minutes';
  static const String _keyExtraTimeMinutes = 'football_extra_time_minutes';
  static const String _keyRemainingTime = 'football_remaining_time';
  static const String _keyIsVoiceEnabled = 'football_is_voice_enabled';
  static const String _keyIsLandscapeMode = 'football_is_landscape_mode';
  static const String _keyIsAppBarVisible = 'football_is_appbar_visible';
  static const String _keyIsScreenWakeLockEnabled = 'football_is_screen_wake_lock_enabled';
  static const String _keyIsFullScreenEnabled = 'football_is_full_screen_enabled';
  static const String _keyShowTimeInSeconds = 'football_show_time_in_seconds';

  // Getters
  int get remainingTime => _remainingTime.value;
  bool get isTimerRunning => _isTimerRunning.value;
  bool get isTimerPaused => _isTimerPaused.value;
  String get team1Name => _team1Name.value;
  String get team2Name => _team2Name.value;
  int get team1Score => _team1Score.value;
  int get team2Score => _team2Score.value;
  int get currentHalf => _currentHalf.value;
  bool get isExtraTime => _isExtraTime.value;
  int get halfTimeMinutes => _halfTimeMinutes.value;
  int get extraTimeMinutes => _extraTimeMinutes.value;
  bool get isVoiceEnabled => _isVoiceEnabled.value;
  
  // 横屏模式相关 getters
  bool get isLandscapeMode => _isLandscapeMode.value;
  bool get isAppBarVisible => _isAppBarVisible.value;
  bool get isScreenWakeLockEnabled => _isScreenWakeLockEnabled.value;
  bool get isFullScreenEnabled => _isFullScreenEnabled.value;
  bool get showTimeInSeconds => _showTimeInSeconds.value;

  // 格式化时间显示
  String get formattedTime {
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 横屏模式下的时间显示（分钟:秒）
  String get formattedTimeInSeconds {
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 获取当前阶段名称
  String get currentHalfName {
    if (isExtraTime) {
      return currentHalf == 3 ? 'extra_time_first_half'.tr : 'extra_time_second_half'.tr;
    } else {
      return currentHalf == 1 ? 'first_half'.tr : 'second_half'.tr;
    }
  }

  // 获取领先队伍
  String get leadingTeam {
    if (team1Score > team2Score) return team1Name;
    if (team2Score > team1Score) return team2Name;
    return 'draw'.tr;
  }

  // 获取比分差
  int get scoreDifference {
    return (team1Score - team2Score).abs();
  }

  @override
  void onInit() {
    super.onInit();
    _loadGameSettings();
    _loadHistory();
    
    // 确保每次进入页面时都重置为竖屏模式
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void onClose() {
    _stopTimer();
    _saveGameSettings();
    // 确保退出时恢复设备方向
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.onClose();
  }

  // 加载游戏设置
  Future<void> _loadGameSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 加载队伍名称
      _team1Name.value = prefs.getString(_keyTeam1Name) ?? 'home_team'.tr;
      _team2Name.value = prefs.getString(_keyTeam2Name) ?? 'away_team'.tr;
      
      // 加载比分
      _team1Score.value = prefs.getInt(_keyTeam1Score) ?? 0;
      _team2Score.value = prefs.getInt(_keyTeam2Score) ?? 0;
      
      // 加载比赛阶段
      _currentHalf.value = prefs.getInt(_keyCurrentHalf) ?? 1;
      _isExtraTime.value = prefs.getBool(_keyIsExtraTime) ?? false;
      
      // 加载时间设置
      _halfTimeMinutes.value = prefs.getInt(_keyHalfTimeMinutes) ?? 45;
      _extraTimeMinutes.value = prefs.getInt(_keyExtraTimeMinutes) ?? 15;
      
      // 加载剩余时间
      final savedRemainingTime = prefs.getInt(_keyRemainingTime);
      if (savedRemainingTime != null && savedRemainingTime > 0) {
        _remainingTime.value = savedRemainingTime;
      } else {
        _remainingTime.value = _halfTimeMinutes.value * 60;
      }
      
      // 加载语音设置
      _isVoiceEnabled.value = prefs.getBool(_keyIsVoiceEnabled) ?? true;
      
      // 加载横屏模式设置 - 每次进入页面都重置为竖屏模式
      _isLandscapeMode.value = false; // 强制重置为竖屏模式
      _isAppBarVisible.value = prefs.getBool(_keyIsAppBarVisible) ?? true;
      _isScreenWakeLockEnabled.value = prefs.getBool(_keyIsScreenWakeLockEnabled) ?? false;
      _isFullScreenEnabled.value = prefs.getBool(_keyIsFullScreenEnabled) ?? false;
      _showTimeInSeconds.value = prefs.getBool(_keyShowTimeInSeconds) ?? false;
      
      update();
    } catch (e) {
      // 加载设置失败
    }
  }

  // 保存游戏设置
  Future<void> _saveGameSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyTeam1Name, _team1Name.value);
      await prefs.setString(_keyTeam2Name, _team2Name.value);
      await prefs.setInt(_keyTeam1Score, _team1Score.value);
      await prefs.setInt(_keyTeam2Score, _team2Score.value);
      await prefs.setInt(_keyCurrentHalf, _currentHalf.value);
      await prefs.setBool(_keyIsExtraTime, _isExtraTime.value);
      await prefs.setInt(_keyHalfTimeMinutes, _halfTimeMinutes.value);
      await prefs.setInt(_keyExtraTimeMinutes, _extraTimeMinutes.value);
      await prefs.setInt(_keyRemainingTime, _remainingTime.value);
      await prefs.setBool(_keyIsVoiceEnabled, _isVoiceEnabled.value);
      await prefs.setBool(_keyIsLandscapeMode, _isLandscapeMode.value);
      await prefs.setBool(_keyIsAppBarVisible, _isAppBarVisible.value);
      await prefs.setBool(_keyIsScreenWakeLockEnabled, _isScreenWakeLockEnabled.value);
      await prefs.setBool(_keyIsFullScreenEnabled, _isFullScreenEnabled.value);
      await prefs.setBool(_keyShowTimeInSeconds, _showTimeInSeconds.value);
    } catch (e) {
      // 保存设置失败
    }
  }

  // 横屏模式相关方法
  void toggleLandscapeMode() {
    if (!_isLandscapeMode.value) {
      // 进入横屏模式：先隐藏AppBar，再切换方向
      _isAppBarVisible.value = false;
      
      Future.delayed(const Duration(milliseconds: 300), () {
        _isLandscapeMode.value = true;
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
        _isScreenWakeLockEnabled.value = true;
        _enableWakeLock();
      });
    } else {
      // 退出横屏模式：先切换方向，再显示AppBar
      _isLandscapeMode.value = false;
      
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
        Future.delayed(const Duration(milliseconds: 200), () {
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
      _isAppBarVisible.value = true;
      
      // 禁用屏幕长亮
      _isScreenWakeLockEnabled.value = false;
      _disableWakeLock();
    }
    _saveGameSettings();
  }

  // 切换导航栏显示状态
  void toggleAppBarVisibility() {
    if (_isLandscapeMode.value) {
      _isAppBarVisible.value = !_isAppBarVisible.value;
    }
  }

  // 显示导航栏
  void showAppBar() {
    _isAppBarVisible.value = true;
  }

  // 隐藏导航栏
  void hideAppBar() {
    if (_isLandscapeMode.value) {
      _isAppBarVisible.value = false;
    }
  }

  // 切换全屏模式
  void toggleFullScreen() {
    _isFullScreenEnabled.value = !_isFullScreenEnabled.value;
    _saveGameSettings();
  }

  // 切换时间显示模式（横屏模式下）
  void toggleTimeDisplayMode() {
    if (_isLandscapeMode.value) {
      _showTimeInSeconds.value = !_showTimeInSeconds.value;
      _saveGameSettings();
    }
  }

  // 启用屏幕长亮
  void _enableWakeLock() {
    try {
      WakelockPlus.enable();
    } catch (e) {
      // 启用屏幕长亮失败
    }
  }

  // 禁用屏幕长亮
  void _disableWakeLock() {
    try {
      WakelockPlus.disable();
    } catch (e) {
      // 禁用屏幕长亮失败
    }
  }

  // 重置所有数据
  void resetAll() {
    _team1Score.value = 0;
    _team2Score.value = 0;
    _currentHalf.value = 1;
    _isExtraTime.value = false;
    _remainingTime.value = _halfTimeMinutes.value * 60;
    _isTimerRunning.value = false;
    _isTimerPaused.value = false;
    _stopTimer();
    _gameStartTime = null;
    
    update();
    _saveGameSettings();
  }

  // 保存比赛结果
  Future<bool> saveGameResult() async {
    if (_gameStartTime == null) {
      return false;
    }

    try {
      final endTime = DateTime.now();
      final duration = endTime.difference(_gameStartTime!).inSeconds;
      
      final result = GameResult(
        id: GameResultManager.generateId(),
        gameType: 'football',
        team1Name: _team1Name.value,
        team2Name: _team2Name.value,
        team1Score: _team1Score.value,
        team2Score: _team2Score.value,
        startTime: _gameStartTime!,
        endTime: endTime,
        duration: duration,
        additionalData: {
          'currentHalf': _currentHalf.value,
          'isExtraTime': _isExtraTime.value,
          'halfTimeMinutes': _halfTimeMinutes.value,
          'extraTimeMinutes': _extraTimeMinutes.value,
          'remainingTime': _remainingTime.value,
        },
      );

      final success = await GameResultManager.saveGameResult(result);
      if (success) {
        Get.snackbar(
          'save_success'.tr,
          'match_result_saved'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'save_failed'.tr,
          'match_result_save_failed'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }

  // 开始计时
  void startTimer() {
    if (_timer != null) return;
    
    _isTimerRunning.value = true;
    _isTimerPaused.value = false;
    _gameStartTime = DateTime.now(); // 记录比赛开始时间
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.value > 0) {
        _remainingTime.value--;
        update();
      } else {
        _handleHalfEnd();
      }
    });
    
    update();
    _saveGameSettings();
  }

  // 暂停计时
  void pauseTimer() {
    print('pause_football_timer'.tr);
    _isTimerPaused.value = true;
    _stopTimer();
    update();
    _saveGameSettings();
  }

  // 重置计时
  void resetTimer() {
    _stopTimer();
    _currentHalf.value = 1;
    _isExtraTime.value = false;
    _remainingTime.value = _halfTimeMinutes.value * 60;
    _isTimerRunning.value = false;
    _isTimerPaused.value = false;
    update();
    _saveGameSettings();
  }

  // 停止计时器
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isTimerRunning.value = false;
  }

  // 处理半场结束
  void _handleHalfEnd() {
    _stopTimer();
    
    if (!isExtraTime) {
      if (currentHalf == 1) {
        // 上半场结束，进入下半场
        _currentHalf.value = 2;
        _remainingTime.value = _halfTimeMinutes.value * 60;
        _announceHalfEnd('first_half_end'.tr);
      } else {
        // 下半场结束，检查是否需要加时
        if (team1Score == team2Score) {
          // 平局，进入加时
          _isExtraTime.value = true;
          _currentHalf.value = 3;
          _remainingTime.value = _extraTimeMinutes.value * 60;
          _announceHalfEnd('second_half_end_extra_time'.tr);
        } else {
          // 有胜负，比赛结束
          _announceGameEnd();
        }
      }
    } else {
      if (currentHalf == 3) {
        // 加时上半场结束
        _currentHalf.value = 4;
        _remainingTime.value = _extraTimeMinutes.value * 60;
        _announceHalfEnd('extra_time_first_half_end'.tr);
      } else {
        // 加时下半场结束，比赛结束
        _announceGameEnd();
      }
    }
    
    update();
    _saveGameSettings();
  }

  // 加分
  void addScore(int team, int points) {
    if (team == 1) {
      _team1Score.value += points;
    } else {
      _team2Score.value += points;
    }
    
    update();
    _announceScore(team, points);
    _saveGameSettings();
    
    // 记录历史记录
    final teamName = team == 1 ? team1Name : team2Name;
    final description = 'football_score_change_record'.tr.replaceAll('{team}', teamName).replaceAll('{points}', points.toString());
    _recordScoreChange(description);
  }

  // 设置队伍名称
  void setTeamNames(String team1Name, String team2Name) {
    _team1Name.value = team1Name;
    _team2Name.value = team2Name;
    update();
    _saveGameSettings();
  }

  // 设置半场时间
  void setHalfTime(int minutes) {
    _halfTimeMinutes.value = minutes;
    if (currentHalf <= 2) {
      _remainingTime.value = minutes * 60;
    }
    update();
    _saveGameSettings();
  }

  // 设置加时时间
  void setExtraTime(int minutes) {
    _extraTimeMinutes.value = minutes;
    if (currentHalf >= 3) {
      _remainingTime.value = minutes * 60;
    }
    update();
    _saveGameSettings();
  }

  // 设置剩余时间
  void setRemainingTime(int seconds) {
    _remainingTime.value = seconds;
    update();
    _saveGameSettings();
  }

  // 切换语音报分
  void toggleVoice() {
    _isVoiceEnabled.value = !_isVoiceEnabled.value;
    update();
    _saveGameSettings();
  }

  // 语音报分
  void _announceScore(int team, int points) {
    if (!_isVoiceEnabled.value) return;
    
    final teamName = team == 1 ? team1Name : team2Name;
    final scoreText = points > 0 ? '+$points' : '$points';
    
    // 使用VoiceAnnouncer进行语音播报
    voiceAnnouncer.announce('football_goal_announce'.tr.replaceAll('{team}', teamName).replaceAll('{score}', scoreText).replaceAll('{score1}', team1Score.toString()).replaceAll('{score2}', team2Score.toString()));
    
    // 同时显示snackbar
    Get.snackbar(
      'goal'.tr,
      'football_goal_message'.tr.replaceAll('{team}', teamName).replaceAll('{score}', scoreText).replaceAll('{score1}', team1Score.toString()).replaceAll('{score2}', team2Score.toString()),
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
    );
  }

  // 半场结束报分
  void _announceHalfEnd(String message) {
    if (!_isVoiceEnabled.value) return;
    
    // 使用VoiceAnnouncer进行语音播报
    voiceAnnouncer.announce('football_half_end_announce'.tr.replaceAll('{message}', message).replaceAll('{score1}', team1Score.toString()).replaceAll('{score2}', team2Score.toString()));
    
    Get.snackbar(
      'half_end'.tr,
      'football_half_end_message'.tr.replaceAll('{message}', message).replaceAll('{score1}', team1Score.toString()).replaceAll('{score2}', team2Score.toString()),
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  // 游戏结束报分
  void _announceGameEnd() {
    if (!_isVoiceEnabled.value) return;
    
    String announcement = 'football_game_end_announce'.tr.replaceAll('{score1}', team1Score.toString()).replaceAll('{score2}', team2Score.toString());
    
    if (team1Score > team2Score) {
      announcement += 'football_team_wins'.tr.replaceAll('{team}', team1Name);
    } else if (team2Score > team1Score) {
      announcement += 'football_team_wins'.tr.replaceAll('{team}', team2Name);
    } else {
      announcement += 'football_draw'.tr;
    }
    
    // 使用VoiceAnnouncer进行语音播报
    voiceAnnouncer.announce(announcement);
    
    Get.snackbar(
      'game_end'.tr,
      announcement,
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // 重置报分
  void _announceReset() {
    if (!_isVoiceEnabled.value) return;
    
    // 使用VoiceAnnouncer进行语音播报
    voiceAnnouncer.announce('football_reset_announce'.tr);
    
    Get.snackbar(
      'reset'.tr,
      'football_reset_message'.tr,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  // 快速加分方法
  void addOneGoal(int team) => addScore(team, 1);

  // 加载历史记录
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyList = prefs.getStringList('football_history') ?? [];
      records.value = historyList
          .map((json) => FootballRecord.fromJson(json))
          .toList();
    } catch (e) {
      print('Failed to load football history: $e');
    }
  }

  // 保存历史记录
  Future<void> saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = records
          .map((record) => record.toJson())
          .toList();
      await prefs.setStringList('football_history', historyJson);
    } catch (e) {
      print('Failed to save football history: $e');
    }
  }

  // 添加记录
  void addRecord(String description) {
    final record = FootballRecord(
      team1Name: team1Name,
      team2Name: team2Name,
      team1Score: team1Score,
      team2Score: team2Score,
      duration: _gameStartTime != null ? DateTime.now().difference(_gameStartTime!).inSeconds : 0,
      totalGoals: team1Score + team2Score,
      description: description,
      timestamp: DateTime.now(),
    );
    records.add(record);
    saveHistory();
  }

  // 删除记录
  void deleteRecord(FootballRecord record) {
    records.remove(record);
    saveHistory();
  }

  // 清空历史记录
  void clearHistory() {
    records.clear();
    saveHistory();
  }

  // 在分数变化时自动记录
  void _recordScoreChange(String description) {
    addRecord(description);
  }
}

// 足球记录模型
class FootballRecord {
  final String team1Name;
  final String team2Name;
  final int team1Score;
  final int team2Score;
  final int duration;
  final int totalGoals;
  final String description;
  final DateTime timestamp;

  FootballRecord({
    required this.team1Name,
    required this.team2Name,
    required this.team1Score,
    required this.team2Score,
    required this.duration,
    required this.totalGoals,
    required this.description,
    required this.timestamp,
  });

  // 转换为JSON
  String toJson() {
    return jsonEncode({
      'team1Name': team1Name,
      'team2Name': team2Name,
      'team1Score': team1Score,
      'team2Score': team2Score,
      'duration': duration,
      'totalGoals': totalGoals,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    });
  }

  // 从JSON创建
  factory FootballRecord.fromJson(String jsonString) {
    final json = jsonDecode(jsonString);
    return FootballRecord(
      team1Name: json['team1Name'] ?? '',
      team2Name: json['team2Name'] ?? '',
      team1Score: json['team1Score'] ?? 0,
      team2Score: json['team2Score'] ?? 0,
      duration: json['duration'] ?? 0,
      totalGoals: json['totalGoals'] ?? 0,
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
} 