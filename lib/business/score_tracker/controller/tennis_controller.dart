import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/data/game_result.dart';
import '../../../core/utils/game_result_manager.dart';
import 'package:common_ui/common_ui.dart';

class TennisRecord {
  final int team1Score;
  final int team2Score;
  final String description;
  final DateTime timestamp;
  final List<int> scoresAtTime; // 记录当前比分

  TennisRecord({
    required this.team1Score,
    required this.team2Score,
    required this.description,
    required this.timestamp,
    required this.scoresAtTime,
  });
}

class TennisController extends BaseController {
  // 队伍信息
  final RxString team1Name = 'Team A'.obs;
  final RxString team2Name = 'Team B'.obs;
  
  // 比赛结构：Match -> Set -> Game -> Point
  // 当前分数（Point级别）
  final RxInt team1Points = 0.obs;
  final RxInt team2Points = 0.obs;
  
  // 当前局数（Game级别）
  final RxInt team1Games = 0.obs;
  final RxInt team2Games = 0.obs;
  
  // 当前盘数（Set级别）
  final RxInt team1Sets = 0.obs;
  final RxInt team2Sets = 0.obs;
  
  // 比赛状态
  final RxBool isGameOver = false.obs;
  final RxString winner = ''.obs;
  
  // 当前比赛阶段
  final RxString currentStage = 'point'.obs; // point, game, set, match
  
  // 历史记录
  final RxList<TennisRecord> records = <TennisRecord>[].obs;
  
  // 语音播报
  final VoiceAnnouncer voiceAnnouncer = VoiceAnnouncer();
  
  // 横屏模式相关
  final RxBool isLandscapeMode = false.obs;
  final RxBool isAppBarVisible = true.obs;
  final RxBool isScreenWakeLockEnabled = false.obs;
  final RxBool isFullScreenEnabled = false.obs;
  final RxBool showTimeInSeconds = false.obs;
  
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
  
  // 横屏模式相关 getters
  bool get isLandscapeModeValue => isLandscapeMode.value;
  bool get isAppBarVisibleValue => isAppBarVisible.value;
  bool get isScreenWakeLockEnabledValue => isScreenWakeLockEnabled.value;
  bool get isFullScreenEnabledValue => isFullScreenEnabled.value;
  bool get showTimeInSecondsValue => showTimeInSeconds.value;
  
  // 获取当前分数显示
  String get currentScoreDisplay {
    if (isGameOver.value) {
      return '${team1Sets.value}-${team2Sets.value} (${team1Games.value}-${team2Games.value})';
    }
    
    // 显示格式：Set-Game-Point
    final setScore = '${team1Sets.value}-${team2Sets.value}';
    final gameScore = '${team1Games.value}-${team2Games.value}';
    final pointScore = _getPointDisplay(team1Points.value, team2Points.value);
    
    return '$setScore ($gameScore) $pointScore';
  }
  
  // 获取领先队伍
  String get leadingTeam {
    if (team1Sets.value > team2Sets.value) return team1Name.value;
    if (team2Sets.value > team1Sets.value) return team2Name.value;
    if (team1Games.value > team2Games.value) return team1Name.value;
    if (team2Games.value > team1Games.value) return team2Name.value;
    if (team1Points.value > team2Points.value) return team1Name.value;
    if (team2Points.value > team1Points.value) return team2Name.value;
    return 'tied'.tr;
  }
  
  // 网球计分逻辑 - Point级别
  String _getPointDisplay(int points1, int points2) {
    final tennisScores = [0, 15, 30, 40];
    
    // 获取网球分数显示
    String getTennisScore(int points) {
      if (points >= tennisScores.length) {
        return 'win'.tr;
      }
      return tennisScores[points].toString();
    }
    
    final score1Tennis = getTennisScore(points1);
    final score2Tennis = getTennisScore(points2);
    
    // 检查平局（40:40）
    if (points1 >= 3 && points2 >= 3 && points1 == points2) {
      return 'deuce'.tr;
    }
    
    // 检查优势（Advantage）
    if (points1 >= 3 && points2 >= 3) {
      if (points1 > points2) {
        return '${score1Tennis}:${score2Tennis}（${'advantage'.tr}）';
      } else if (points2 > points1) {
        return '${score1Tennis}:${score2Tennis}（${'disadvantage'.tr}）';
      }
    }
    
    // 正常计分
    return '${score1Tennis}:${score2Tennis}';
  }
  
  // 获取网球分数显示（用于历史记录）
  String getTennisScoreDisplay(int points) {
    final tennisScores = [0, 15, 30, 40];
    if (points >= tennisScores.length) {
      return 'win'.tr;
    }
    return tennisScores[points].toString();
  }
  
  // 获取当前局比分显示（公共方法）
  String getCurrentPointDisplay() {
    return _getPointDisplay(team1Points.value, team2Points.value);
  }
  
  // 检查是否赢得一局（Game）
  bool _checkGameWin(int points1, int points2) {
    return (points1 >= 4 && points1 - points2 >= 2) ||
           (points2 >= 4 && points2 - points1 >= 2);
  }
  
  // 检查是否赢得一盘（Set）
  bool _checkSetWin(int games1, int games2) {
    return (games1 >= 6 && games1 - games2 >= 2) ||
           (games2 >= 6 && games2 - games1 >= 2);
  }
  
  // 检查是否赢得比赛（Match）
  bool _checkMatchWin(int sets1, int sets2) {
    // 3盘2胜制
    return sets1 >= 2 || sets2 >= 2;
  }
  
  // 添加分数
  void addScore(int teamNumber) {
    if (isGameOver.value) return;
    
    if (teamNumber == 1) {
      team1Points.value++;
    } else {
      team2Points.value++;
    }
    
    // 检查是否赢得一局
    if (_checkGameWin(team1Points.value, team2Points.value)) {
      _winGame(team1Points.value > team2Points.value ? 1 : 2);
    }
    
    _saveGameData();
  }
  
  // 赢得一局
  void _winGame(int winningTeam) {
    if (winningTeam == 1) {
      team1Games.value++;
    } else {
      team2Games.value++;
    }
    
    // 重置分数
    team1Points.value = 0;
    team2Points.value = 0;
    
    // 检查是否赢得一盘
    if (_checkSetWin(team1Games.value, team2Games.value)) {
      _winSet(team1Games.value > team2Games.value ? 1 : 2);
    }
    
    // 记录
    final winner = winningTeam == 1 ? team1Name.value : team2Name.value;
    _addRecord(team1Games.value, team2Games.value, '${winner} ${'wins_game'.tr}');
    
    // 语音播报
    if (voiceAnnouncer.isEnabled.value) {
      voiceAnnouncer.announce('${winner} ${'wins_game'.tr}');
    }
  }
  
  // 赢得一盘
  void _winSet(int winningTeam) {
    if (winningTeam == 1) {
      team1Sets.value++;
    } else {
      team2Sets.value++;
    }
    
    // 重置局数
    team1Games.value = 0;
    team2Games.value = 0;
    
    // 检查是否赢得比赛
    if (_checkMatchWin(team1Sets.value, team2Sets.value)) {
      _winMatch(team1Sets.value > team2Sets.value ? 1 : 2);
    }
    
    // 记录
    final winner = winningTeam == 1 ? team1Name.value : team2Name.value;
    _addRecord(team1Sets.value, team2Sets.value, '${winner} ${'wins_set'.tr}');
    
    // 语音播报
    if (voiceAnnouncer.isEnabled.value) {
      voiceAnnouncer.announce('${winner} ${'wins_set'.tr}');
    }
  }
  
  // 赢得比赛
  void _winMatch(int winningTeam) {
    isGameOver.value = true;
    winner.value = winningTeam == 1 ? team1Name.value : team2Name.value;
    
    // 记录
    _addRecord(team1Sets.value, team2Sets.value, '${winner.value} ${'wins_match'.tr}');
    
    // 语音播报
    if (voiceAnnouncer.isEnabled.value) {
      voiceAnnouncer.announce('${winner.value} ${'wins_match'.tr}');
    }
  }
  
  // 加载游戏数据
  Future<void> _loadGameData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 强制重置为竖屏模式
      isLandscapeMode.value = false;
      isAppBarVisible.value = true;
      
      team1Name.value = prefs.getString('tennis_team1_name') ?? 'Team A';
      team2Name.value = prefs.getString('tennis_team2_name') ?? 'Team B';
      team1Points.value = prefs.getInt('tennis_team1_points') ?? 0;
      team2Points.value = prefs.getInt('tennis_team2_points') ?? 0;
      team1Games.value = prefs.getInt('tennis_team1_games') ?? 0;
      team2Games.value = prefs.getInt('tennis_team2_games') ?? 0;
      team1Sets.value = prefs.getInt('tennis_team1_sets') ?? 0;
      team2Sets.value = prefs.getInt('tennis_team2_sets') ?? 0;
      isGameOver.value = prefs.getBool('tennis_is_game_over') ?? false;
      winner.value = prefs.getString('tennis_winner') ?? '';
      
      // 加载历史记录
      final recordsJson = prefs.getStringList('tennis_records') ?? [];
      records.clear();
      for (final recordJson in recordsJson) {
        try {
          final recordMap = Map<String, dynamic>.from(
            Map.fromEntries(recordJson.split('|').map((e) {
              final parts = e.split(':');
              return MapEntry(parts[0], parts[1]);
            }))
          );
          
          records.add(TennisRecord(
            team1Score: int.parse(recordMap['team1Score'] ?? '0'),
            team2Score: int.parse(recordMap['team2Score'] ?? '0'),
            description: recordMap['description'] ?? '',
            timestamp: DateTime.parse(recordMap['timestamp'] ?? DateTime.now().toIso8601String()),
            scoresAtTime: (recordMap['scoresAtTime'] ?? '').split(',').where((e) => e.isNotEmpty).map((e) => int.parse(e)).toList(),
          ));
        } catch (e) {
          print('parse_tennis_record_failed'.tr + ': $e');
        }
      }
    } catch (e) {
      print('load_tennis_data_failed'.tr + ': $e');
    }
  }
  
  // 保存游戏数据
  Future<void> _saveGameData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('tennis_team1_name', team1Name.value);
      await prefs.setString('tennis_team2_name', team2Name.value);
      await prefs.setInt('tennis_team1_points', team1Points.value);
      await prefs.setInt('tennis_team2_points', team2Points.value);
      await prefs.setInt('tennis_team1_games', team1Games.value);
      await prefs.setInt('tennis_team2_games', team2Games.value);
      await prefs.setInt('tennis_team1_sets', team1Sets.value);
      await prefs.setInt('tennis_team2_sets', team2Sets.value);
      await prefs.setBool('tennis_is_game_over', isGameOver.value);
      await prefs.setString('tennis_winner', winner.value);
      
      // 保存历史记录
      final recordsJson = records.map((record) {
        return 'team1Score:${record.team1Score}|team2Score:${record.team2Score}|description:${record.description}|timestamp:${record.timestamp.toIso8601String()}|scoresAtTime:${record.scoresAtTime.join(',')}';
      }).toList();
      await prefs.setStringList('tennis_records', recordsJson);
    } catch (e) {
      print('save_tennis_data_failed'.tr + ': $e');
    }
  }
  
  // 添加记录
  void _addRecord(int team1Score, int team2Score, String description) {
    records.add(TennisRecord(
      team1Score: team1Score,
      team2Score: team2Score,
      description: description,
      timestamp: DateTime.now(),
      scoresAtTime: [team1Score, team2Score],
    ));
    
    _saveGameData();
  }
  
  // 重置游戏
  void resetGame() {
    team1Points.value = 0;
    team2Points.value = 0;
    team1Games.value = 0;
    team2Games.value = 0;
    team1Sets.value = 0;
    team2Sets.value = 0;
    isGameOver.value = false;
    winner.value = '';
    currentStage.value = 'point';
    
    _saveGameData();
  }
  
  // 切换横屏模式
  void toggleLandscapeMode() {
    isLandscapeMode.value = !isLandscapeMode.value;
    
    if (isLandscapeMode.value) {
      // 进入横屏模式时自动隐藏AppBar
      isAppBarVisible.value = false;
      
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      
      if (isFullScreenEnabled.value) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      }
      
      if (isScreenWakeLockEnabled.value) {
        WakelockPlus.enable();
      }
    } else {
      // 退出横屏模式时显示AppBar
      isAppBarVisible.value = true;
      
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      WakelockPlus.disable();
    }
  }
  
  // 切换AppBar显示
  void toggleAppBarVisibility() {
    isAppBarVisible.value = !isAppBarVisible.value;
  }
  
  // 切换屏幕常亮
  void toggleScreenWakeLock() {
    isScreenWakeLockEnabled.value = !isScreenWakeLockEnabled.value;
    
    if (isScreenWakeLockEnabled.value) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }
  
  // 切换全屏模式
  void toggleFullScreen() {
    isFullScreenEnabled.value = !isFullScreenEnabled.value;
    
    if (isFullScreenEnabled.value) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
  
  // 切换语音播报
  void toggleVoice() {
    voiceAnnouncer.toggle();
  }
  
  // 设置队伍名称
  void setTeamNames(String team1, String team2) {
    team1Name.value = team1;
    team2Name.value = team2;
    _saveGameData();
  }
  
  // 保存游戏结果到历史
  Future<void> saveGameResultToHistory() async {
    final gameResult = GameResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gameType: '网球',
      team1Name: team1Name.value,
      team2Name: team2Name.value,
      team1Score: team1Sets.value,
      team2Score: team2Sets.value,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      duration: 0,
      additionalData: {
        'team1Games': team1Games.value,
        'team2Games': team2Games.value,
        'team1Points': team1Points.value,
        'team2Points': team2Points.value,
        'winner': winner.value,
        'records': records.map((r) => {
          'team1Score': r.team1Score,
          'team2Score': r.team2Score,
          'description': r.description,
          'timestamp': r.timestamp.toIso8601String(),
        }).toList(),
      },
    );
    
    await GameResultManager.saveGameResult(gameResult);
  }
} 