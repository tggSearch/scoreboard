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

class BasketballController extends BaseController {
  // Time related
  final _remainingTime = (12 * 60).obs; // Default 12 minutes, unit: seconds
  final _isTimerRunning = false.obs;
  final _isTimerPaused = false.obs;
  Timer? _timer;

  // Team information
  final _team1Name = 'home_team'.tr.obs;
  final _team2Name = 'away_team'.tr.obs;
  final _team1Score = 0.obs;
  final _team2Score = 0.obs;

  // Time settings
  final _gameTimeMinutes = 12.obs;

  // Voice announcement
  final _isVoiceEnabled = true.obs;

  // Landscape mode related
  final _isLandscapeMode = false.obs;
  final _showTimeInSeconds = false.obs;
  final _isScreenWakeLockEnabled = false.obs;
  final _isFullScreenEnabled = false.obs;
  final _isAppBarVisible = false.obs; // New: control AppBar display in landscape mode

  // Announcement related
  final Set<int> _announcedTimes = <int>{};
  final VoiceAnnouncer voiceAnnouncer = VoiceAnnouncer();

  // Game start time
  DateTime? _gameStartTime;

  // Storage keys
  static const String _keyTeam1Name = 'basketball_team1_name';
  static const String _keyTeam2Name = 'basketball_team2_name';
  static const String _keyTeam1Score = 'basketball_team1_score';
  static const String _keyTeam2Score = 'basketball_team2_score';
  static const String _keyGameTimeMinutes = 'basketball_game_time_minutes';
  static const String _keyRemainingTime = 'basketball_remaining_time';
  static const String _keyIsVoiceEnabled = 'basketball_is_voice_enabled';
  static const String _keyIsLandscapeMode = 'basketball_is_landscape_mode';
  static const String _keyShowTimeInSeconds = 'basketball_show_time_in_seconds';
  static const String _keyIsScreenWakeLockEnabled = 'basketball_is_screen_wake_lock_enabled';
  static const String _keyIsFullScreenEnabled = 'basketball_is_full_screen_enabled';

  // Getters
  int get remainingTime => _remainingTime.value;
  bool get isTimerRunning => _isTimerRunning.value;
  bool get isTimerPaused => _isTimerPaused.value;
  String get team1Name => _team1Name.value;
  String get team2Name => _team2Name.value;
  int get team1Score => _team1Score.value;
  int get team2Score => _team2Score.value;
  int get gameTimeMinutes => _gameTimeMinutes.value;
  bool get isVoiceEnabled => _isVoiceEnabled.value;
  bool get isLandscapeMode => _isLandscapeMode.value;
  bool get showTimeInSeconds => _showTimeInSeconds.value;
  bool get isScreenWakeLockEnabled => _isScreenWakeLockEnabled.value;
  bool get isFullScreenEnabled => _isFullScreenEnabled.value;
  bool get isAppBarVisible => _isAppBarVisible.value; // New getter

  // Format time display
  String get formattedTime {
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Time display in landscape mode (minutes:seconds)
  String get formattedTimeInSeconds {
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Get leading team
  String get leadingTeam {
    if (team1Score > team2Score) return team1Name;
    if (team2Score > team1Score) return team2Name;
    return 'draw'.tr;
  }

  // Get score difference
  int get scoreDifference {
    return (team1Score - team2Score).abs();
  }

  @override
  void onInit() {
    super.onInit();
    _loadGameSettings();
    loadHistory(); // 加载历史记录
    
    // Ensure reset to portrait mode every time entering the page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void onClose() {
    _disableWakeLock();
    _saveDebounceTimer?.cancel();
    // Ensure restore device orientation when exiting
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.onClose();
  }

  // Load game settings
  Future<void> _loadGameSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 加载队伍名称
      _team1Name.value = prefs.getString(_keyTeam1Name) ?? 'home_team'.tr;
      _team2Name.value = prefs.getString(_keyTeam2Name) ?? 'away_team'.tr;
      
      // 加载比分 - 只有在SharedPreferences中存在且不为0时才加载
      final savedTeam1Score = prefs.getInt(_keyTeam1Score);
      final savedTeam2Score = prefs.getInt(_keyTeam2Score);
      
      if (savedTeam1Score != null && savedTeam1Score > 0) {
        _team1Score.value = savedTeam1Score;
      } else {
        _team1Score.value = 0;
      }
      
      if (savedTeam2Score != null && savedTeam2Score > 0) {
        _team2Score.value = savedTeam2Score;
      } else {
        _team2Score.value = 0;
      }
      
      // 加载游戏时间设置
      _gameTimeMinutes.value = prefs.getInt(_keyGameTimeMinutes) ?? 12;
      
      // 加载剩余时间（如果之前有保存的话且不为0）
      final savedRemainingTime = prefs.getInt(_keyRemainingTime);
      if (savedRemainingTime != null && savedRemainingTime > 0) {
        _remainingTime.value = savedRemainingTime;
      } else {
        _remainingTime.value = _gameTimeMinutes.value * 60;
      }
      
      // 加载语音设置
      _isVoiceEnabled.value = prefs.getBool(_keyIsVoiceEnabled) ?? true;
      
      // 加载横屏模式设置 - 每次进入页面都重置为竖屏模式
      _isLandscapeMode.value = false; // 强制重置为竖屏模式
      _showTimeInSeconds.value = prefs.getBool(_keyShowTimeInSeconds) ?? false;
      
      // 加载屏幕长亮设置
      _isScreenWakeLockEnabled.value = prefs.getBool(_keyIsScreenWakeLockEnabled) ?? false;
      
      // 加载全屏模式设置
      _isFullScreenEnabled.value = prefs.getBool(_keyIsFullScreenEnabled) ?? false;
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
      await prefs.setInt(_keyGameTimeMinutes, _gameTimeMinutes.value);
      await prefs.setInt(_keyRemainingTime, _remainingTime.value);
      await prefs.setBool(_keyIsVoiceEnabled, _isVoiceEnabled.value);
      await prefs.setBool(_keyIsLandscapeMode, _isLandscapeMode.value);
      await prefs.setBool(_keyShowTimeInSeconds, _showTimeInSeconds.value);
      await prefs.setBool(_keyIsScreenWakeLockEnabled, _isScreenWakeLockEnabled.value);
      await prefs.setBool(_keyIsFullScreenEnabled, _isFullScreenEnabled.value);
    } catch (e) {
      // 保存设置失败
    }
  }

  // 切换横屏模式
  void toggleLandscapeMode() {
    _isLandscapeMode.value = !_isLandscapeMode.value;
    if (_isLandscapeMode.value) {
      // 1. 横屏处理
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      
      // 2. 长亮屏幕
      _isScreenWakeLockEnabled.value = true;
      _enableWakeLock();
      
      // 3. 隐藏导航栏
      _isAppBarVisible.value = false;
    } else {
      // 退出横屏模式
      // 恢复设备方向为竖屏
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      
      // 禁用屏幕长亮
      _isScreenWakeLockEnabled.value = false;
      _disableWakeLock();
      
      // 显示导航栏
      _isAppBarVisible.value = true;
    }
    _saveGameSettings();
  }

  // 点击屏幕切换导航栏显示状态
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

  // 切换屏幕长亮
  void toggleScreenWakeLock() {
    _isScreenWakeLockEnabled.value = !_isScreenWakeLockEnabled.value;
    
    if (_isScreenWakeLockEnabled.value) {
      _enableWakeLock();
    } else {
      _disableWakeLock();
    }
    
    _saveGameSettings();
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

  // 时间播报
  void _announceTime(int remainingSeconds) {
    if (!_isVoiceEnabled.value) return;
    
    // 避免重复播报
    if (_announcedTimes.contains(remainingSeconds)) return;
    _announcedTimes.add(remainingSeconds);
    
    String announcement = '';
    
    if (remainingSeconds == 600) { // 10分钟
      announcement = 'remaining_10_minutes'.tr;
    } else if (remainingSeconds == 300) { // 5分钟
      announcement = 'remaining_5_minutes'.tr;
    } else if (remainingSeconds == 60) { // 1分钟
      announcement = 'remaining_1_minute'.tr;
    } else if (remainingSeconds == 30) { // 30秒
      announcement = 'remaining_30_seconds'.tr;
    } else if (remainingSeconds <= 10 && remainingSeconds > 0) { // 10秒倒计时
      announcement = remainingSeconds.toString();
    } else if (remainingSeconds == 0) { // 时间到
      announcement = 'time_up_game_over'.tr;
    }
    
    if (announcement.isNotEmpty) {
      // 只进行语音播报，不显示snackbar
      voiceAnnouncer.announce(announcement);
    }
  }

  // 设置队伍名称
  Future<void> setTeamName(int teamIndex, String name) async {
    if (teamIndex == 1) {
      _team1Name.value = name;
    } else if (teamIndex == 2) {
      _team2Name.value = name;
    }
    await _saveGameSettings();
  }

  // 设置游戏时间
  Future<void> setGameTime(int minutes) async {
    _gameTimeMinutes.value = minutes;
    _remainingTime.value = minutes * 60;
    await _saveGameSettings();
  }

  // 设置剩余时间
  void setRemainingTime(int seconds) {
    _remainingTime.value = seconds;
    update();
    _saveGameSettings();
  }

  // 设置队伍名称（兼容旧方法）
  void setTeamNames(String team1, String team2) {
    _team1Name.value = team1.isEmpty ? 'home_team'.tr : team1;
    _team2Name.value = team2.isEmpty ? 'away_team'.tr : team2;
    update();
    _saveGameSettings();
  }

  // 切换语音报分
  void toggleVoice() {
    _isVoiceEnabled.value = !_isVoiceEnabled.value;
    _saveGameSettings();
  }

  // 开始计时器
  void startTimer() {
    if (_timer != null) return;
    
    _isTimerRunning.value = true;
    _isTimerPaused.value = false;
    _gameStartTime = DateTime.now(); // 记录比赛开始时间
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.value > 0) {
        _remainingTime.value--;
        
        // 立即播报时间，不等待update
        _announceTime(_remainingTime.value);
        
        update();
      } else {
        _handleGameEnd();
      }
    });
    
    update();
    _saveGameSettings();
  }

  // 暂停计时器
  void pauseTimer() {
    _timer?.cancel();
    _timer = null;
    _isTimerRunning.value = false;
    _isTimerPaused.value = true;
    update();
    _saveGameSettings();
  }

  // 停止计时器
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isTimerRunning.value = false;
    _isTimerPaused.value = false;
    update();
    _saveGameSettings();
  }

  // 重置计时器
  void resetTimer() {
    _stopTimer();
    _remainingTime.value = _gameTimeMinutes.value * 60;
    _announcedTimes.clear(); // 清除播报记录
    update();
    _saveGameSettings();
  }

  // 加分功能
  void addScore(int team, int points) {
    if (team == 1) {
      _team1Score.value += points;
    } else if (team == 2) {
      _team2Score.value += points;
    }
    
    // 语音播报得分
    _announceScore(team, points);
    
    // 记录历史
    final teamName = team == 1 ? team1Name : team2Name;
    _recordScoreChange('$teamName +$points');
    
    // 延迟保存设置，避免频繁保存导致抖动
    _debounceSave();
  }

  // 防抖保存设置
  Timer? _saveDebounceTimer;
  void _debounceSave() {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _saveGameSettings();
    });
  }

  // 减分功能
  void subtractScore(int team, int points) {
    if (team == 1) {
      _team1Score.value = (_team1Score.value - points).clamp(0, 999);
    } else if (team == 2) {
      _team2Score.value = (_team2Score.value - points).clamp(0, 999);
    }
    
    // 语音播报得分
    _announceScore(team, -points);
    
    // 记录历史
    final teamName = team == 1 ? team1Name : team2Name;
    _recordScoreChange('$teamName -$points');
    
    update();
    _saveGameSettings();
  }

  // 通用加分方法
  void addPoints(int team, int points) {
    addScore(team, points);
  }

  // 通用减分方法
  void subtractPoints(int team, int points) {
    subtractScore(team, points);
  }

  // 手动设置比分
  void setScore(int team, int score) {
    if (team == 1) {
      _team1Score.value = score.clamp(0, 999);
    } else if (team == 2) {
      _team2Score.value = score.clamp(0, 999);
    }
    
    update();
    _saveGameSettings();
  }

  // 重置比分
  void resetScore() async {
    // 先清除保存的分数数据
    await _clearSavedScores();
    
    // 重置内存中的值
    _team1Score.value = 0;
    _team2Score.value = 0;
    
    update();
    _announceReset();
    
    // 最后保存设置
    _saveGameSettings();
  }

  // 重置所有数据
  void resetAll() async {
    // 先清除保存的分数数据，确保重新加载时不会恢复旧分数
    await _clearSavedScores();
    
    // 重置内存中的值
    _team1Score.value = 0;
    _team2Score.value = 0;
    _gameTimeMinutes.value = 12; // 重置为默认12分钟
    _remainingTime.value = 12 * 60; // 重置为12分钟对应的秒数
    _isTimerRunning.value = false;
    _isTimerPaused.value = false;
    _announcedTimes.clear(); // 清除播报记录
    _stopTimer();
    _gameStartTime = null;
    
    update();
    
    // 最后保存设置
    _saveGameSettings();
  }

  // 清除保存的分数数据
  Future<void> _clearSavedScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyTeam1Score);
      await prefs.remove(_keyTeam2Score);
      await prefs.remove(_keyRemainingTime);
      await prefs.remove(_keyGameTimeMinutes); // 也清除保存的游戏时间设置
    } catch (e) {
      // 清除保存的分数数据失败
    }
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
        gameType: 'basketball',
        team1Name: _team1Name.value,
        team2Name: _team2Name.value,
        team1Score: _team1Score.value,
        team2Score: _team2Score.value,
        startTime: _gameStartTime!,
        endTime: endTime,
        duration: duration,
        additionalData: {
          'gameTimeMinutes': _gameTimeMinutes.value,
          'remainingTime': _remainingTime.value,
        },
      );

      final success = await GameResultManager.saveGameResult(result);
      if (success) {
        Get.snackbar(
          'save_success'.tr,
          'game_result_saved'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'save_failed'.tr,
          'game_result_save_failed'.tr,
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

  // 处理游戏结束
  void _handleGameEnd() {
    _stopTimer();
    _announceGameEnd();
    update();
    _saveGameSettings();
  }

  // 语音报分
  void _announceScore(int team, int points) {
    if (!_isVoiceEnabled.value) return;
    
    final teamName = team == 1 ? team1Name : team2Name;
    final scoreText = points > 0 ? '+$points' : '$points';
    
    // 使用VoiceAnnouncer进行语音播报
    voiceAnnouncer.announce('$teamName $scoreText${'points_current_score'.tr} $team1Score ${'vs'.tr} $team2Score');
    
    // 同时显示snackbar
    Get.snackbar(
      'score'.tr,
      '$teamName $scoreText${'points_current_score'.tr} $team1Score ${'vs'.tr} $team2Score',
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
    );
  }

  // 游戏结束报分
  void _announceGameEnd() {
    if (!_isVoiceEnabled.value) return;
    
    String announcement = 'game_over'.tr + '！${'final_score'.tr} $team1Score ${'vs'.tr} $team2Score';
    
    if (team1Score > team2Score) {
      announcement += '，$team1Name ${'wins'.tr}';
    } else if (team2Score > team1Score) {
      announcement += '，$team2Name ${'wins'.tr}';
    } else {
      announcement += '，${'draw'.tr}';
    }
    
    // 使用VoiceAnnouncer进行语音播报
    voiceAnnouncer.announce(announcement);
    
    Get.snackbar(
      'game_over'.tr,
      announcement,
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  // 重置报分
  void _announceReset() {
    if (!_isVoiceEnabled.value) return;
    
    // 使用VoiceAnnouncer进行语音播报
    voiceAnnouncer.announce('score_reset_to_zero'.tr);
    
    Get.snackbar(
      'reset'.tr,
      'score_reset_to_zero'.tr,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  // 快速加分方法
  void addOnePoint(int team) => addScore(team, 1);
  void addTwoPoints(int team) => addScore(team, 2);
  void addThreePoints(int team) => addScore(team, 3);

  // 快速减分方法
  void subtractOnePoint(int team) => subtractScore(team, 1);
  void subtractTwoPoints(int team) => subtractScore(team, 2);
  void subtractThreePoints(int team) => subtractScore(team, 3);

  // 历史记录相关
  final RxList<BasketballRecord> records = <BasketballRecord>[].obs;

  // 加载历史记录
  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('basketball_history') ?? [];
      records.value = historyJson
          .map((json) => BasketballRecord.fromJson(json))
          .toList();
    } catch (e) {
      print('Failed to load basketball history: $e');
    }
  }

  // 保存历史记录
  Future<void> saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = records
          .map((record) => record.toJson())
          .toList();
      await prefs.setStringList('basketball_history', historyJson);
    } catch (e) {
      print('Failed to save basketball history: $e');
    }
  }

  // 添加记录
  void addRecord(String description) {
    final record = BasketballRecord(
      team1Name: team1Name,
      team2Name: team2Name,
      team1Score: team1Score,
      team2Score: team2Score,
      gameTime: gameTimeMinutes,
      description: description,
      timestamp: DateTime.now(),
    );
    records.add(record);
    saveHistory();
  }

  // 删除记录
  void deleteRecord(BasketballRecord record) {
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

// 篮球记录模型
class BasketballRecord {
  final String team1Name;
  final String team2Name;
  final int team1Score;
  final int team2Score;
  final int gameTime;
  final String description;
  final DateTime timestamp;

  BasketballRecord({
    required this.team1Name,
    required this.team2Name,
    required this.team1Score,
    required this.team2Score,
    required this.gameTime,
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
      'gameTime': gameTime,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    });
  }

  // 从JSON创建
  factory BasketballRecord.fromJson(String jsonString) {
    final json = jsonDecode(jsonString);
    return BasketballRecord(
      team1Name: json['team1Name'] ?? '',
      team2Name: json['team2Name'] ?? '',
      team1Score: json['team1Score'] ?? 0,
      team2Score: json['team2Score'] ?? 0,
      gameTime: json['gameTime'] ?? 0,
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
} 