import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/data/game_result.dart';
import '../../../core/utils/game_result_manager.dart';
import 'package:common_ui/common_ui.dart';

class UnoPlayer {
  String name;
  int score;
  int wins;
  int remainingCards;

  UnoPlayer({
    required this.name,
    this.score = 0,
    this.wins = 0,
    this.remainingCards = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'score': score,
      'wins': wins,
      'remainingCards': remainingCards,
    };
  }

  factory UnoPlayer.fromJson(Map<String, dynamic> json) {
    return UnoPlayer(
      name: json['name'] ?? '',
      score: json['score'] ?? 0,
      wins: json['wins'] ?? 0,
      remainingCards: json['remainingCards'] ?? 0,
    );
  }
}

class UnoRecord {
  final String winnerName;
  final List<UnoPlayer> players;
  final int roundScore;
  final DateTime timestamp;

  UnoRecord({
    required this.winnerName,
    required this.players,
    required this.roundScore,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'winnerName': winnerName,
      'players': players.map((p) => p.toJson()).toList(),
      'roundScore': roundScore,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory UnoRecord.fromJson(Map<String, dynamic> json) {
    return UnoRecord(
      winnerName: json['winnerName'] ?? '',
      players: (json['players'] as List?)
          ?.map((p) => UnoPlayer.fromJson(p))
          .toList() ?? [],
      roundScore: json['roundScore'] ?? 0,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class UnoController extends BaseController {
  // 玩家列表
  final RxList<UnoPlayer> players = <UnoPlayer>[].obs;
  
  // 游戏设置
  final RxInt playerCount = 2.obs;
  final RxInt targetScore = 500.obs;
  final RxBool isAccumulateMode = true.obs; // true: 累计积分模式, false: 只记录赢家模式
  
  // 当前轮次数据
  final RxInt currentWinnerIndex = 0.obs;
  final RxList<int> currentRemainingCards = <int>[].obs;
  
  // 游戏记录
  final RxList<UnoRecord> records = <UnoRecord>[].obs;
  
  // 语音播报
  final VoiceAnnouncer voiceAnnouncer = VoiceAnnouncer();

  @override
  void onInit() {
    super.onInit();
    _loadGameData();
    _initializePlayers();
  }

  @override
  void onClose() {
    _saveGameData();
    super.onClose();
  }

  // 初始化玩家
  void _initializePlayers() {
    players.clear();
    currentRemainingCards.clear();
    
    for (int i = 0; i < playerCount.value; i++) {
      players.add(UnoPlayer(name: 'player'.tr + '${i + 1}'));
      currentRemainingCards.add(0);
    }
  }

  // 设置玩家数量
  void setPlayerCount(int count) {
    if (count >= 2 && count <= 10) {
      playerCount.value = count;
      _initializePlayers();
      _saveGameData();
    }
  }

  // 删除玩家
  void removePlayer(int index) {
    if (players.length > 2 && index >= 0 && index < players.length) {
      players.removeAt(index);
      playerCount.value = players.length;
      
      // 调整当前轮次数据
      currentRemainingCards.clear();
      for (int i = 0; i < players.length; i++) {
        currentRemainingCards.add(0);
      }
      
      _saveGameData();
    }
  }

  // 设置目标分数
  void setTargetScore(int score) {
    if (score > 0) {
      targetScore.value = score;
      _saveGameData();
    }
  }

  // 切换计分模式
  void toggleScoreMode() {
    isAccumulateMode.value = !isAccumulateMode.value;
    _saveGameData();
  }

  // 设置玩家名称
  Future<void> setPlayerName(int index, String name) async {
    if (index >= 0 && index < players.length && name.trim().isNotEmpty) {
      players[index].name = name.trim();
      _saveGameData();
    }
  }

  // 设置当前轮次赢家
  void setCurrentWinner(int index) {
    if (index >= 0 && index < players.length) {
      currentWinnerIndex.value = index;
    }
  }

  // 设置玩家剩余手牌
  void setRemainingCards(int playerIndex, int cards) {
    if (playerIndex >= 0 && playerIndex < currentRemainingCards.length) {
      currentRemainingCards[playerIndex] = cards;
    }
  }

  // 计算手牌分数
  int _calculateCardScore(int cards) {
    // 简化计算：每张牌10分
    return cards * 10;
  }

  // 结束当前轮次
  void endRound() {
    // 自动检测赢家：没有牌数的玩家
    int winnerIndex = -1;
    for (int i = 0; i < currentRemainingCards.length; i++) {
      if (currentRemainingCards[i] == 0) {
        winnerIndex = i;
        break;
      }
    }

    if (winnerIndex == -1) {
      Get.snackbar('error'.tr, 'no_winner_found'.tr);
      return;
    }

    final winner = players[winnerIndex];
    int roundScore = 0;

    if (isAccumulateMode.value) {
      // 累计积分模式：赢家获得其他人手牌总分
      for (int i = 0; i < players.length; i++) {
        if (i != winnerIndex) {
          int playerScore = _calculateCardScore(currentRemainingCards[i]);
          roundScore += playerScore;
        }
      }
      winner.score += roundScore;
    } else {
      // 只记录赢家模式：赢家获得1胜场
      winner.wins += 1;
      roundScore = 1;
    }

    // 创建记录
    final record = UnoRecord(
      winnerName: winner.name,
      players: List.from(players),
      roundScore: roundScore,
      timestamp: DateTime.now(),
    );
    records.add(record);

    // 保存到游戏结果管理器
    _addRecord(record);

    // 语音播报
    if (isAccumulateMode.value) {
      voiceAnnouncer.announce('uno_player_wins_points'.tr.replaceAll('{player}', winner.name).replaceAll('{points}', roundScore.toString()));
    } else {
      voiceAnnouncer.announce('uno_player_wins_round'.tr.replaceAll('{player}', winner.name));
    }

    // 重置当前轮次数据
    currentRemainingCards.clear();
    for (int i = 0; i < players.length; i++) {
      currentRemainingCards.add(0);
    }

    _saveGameData();
  }

  // 重置游戏
  void resetGame() {
    for (var player in players) {
      player.score = 0;
      player.wins = 0;
    }
    records.clear();
    currentWinnerIndex.value = 0;
    currentRemainingCards.clear();
    for (int i = 0; i < players.length; i++) {
      currentRemainingCards.add(0);
    }
    _saveGameData();
    voiceAnnouncer.announce('uno_game_reset'.tr);
  }

  // 检查是否有玩家达到目标分数
  bool get hasWinner {
    if (isAccumulateMode.value) {
      return players.any((player) => player.score >= targetScore.value);
    } else {
      return players.any((player) => player.wins >= targetScore.value);
    }
  }

  // 获取获胜者
  List<UnoPlayer> get winners {
    if (isAccumulateMode.value) {
      final maxScore = players.map((p) => p.score).reduce((a, b) => a > b ? a : b);
      return players.where((p) => p.score == maxScore).toList();
    } else {
      final maxWins = players.map((p) => p.wins).reduce((a, b) => a > b ? a : b);
      return players.where((p) => p.wins == maxWins).toList();
    }
  }

  // 获取积分榜（按分数排序）
  List<UnoPlayer> get leaderboard {
    final sortedPlayers = List<UnoPlayer>.from(players);
    if (isAccumulateMode.value) {
      sortedPlayers.sort((a, b) => b.score.compareTo(a.score));
    } else {
      sortedPlayers.sort((a, b) => b.wins.compareTo(a.wins));
    }
    return sortedPlayers;
  }

  // 添加记录到游戏结果管理器
  void _addRecord(UnoRecord record) {
    // 为UNO游戏创建简化的GameResult
    final gameResult = GameResult(
      id: 'uno_${record.timestamp.millisecondsSinceEpoch}',
      gameType: 'uno',
      team1Name: record.winnerName,
      team2Name: 'other_players'.tr,
      team1Score: isAccumulateMode.value ? record.roundScore : 1,
      team2Score: 0,
      startTime: record.timestamp,
      endTime: record.timestamp,
      duration: 60, // 1分钟
    );
    GameResultManager.saveGameResult(gameResult);
  }

  // 保存游戏数据
  Future<void> _saveGameData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 保存游戏设置
      await prefs.setInt('uno_player_count', playerCount.value);
      await prefs.setInt('uno_target_score', targetScore.value);
      await prefs.setBool('uno_accumulate_mode', isAccumulateMode.value);
      
      // 保存玩家数据
      final playersData = players.map((p) => p.toJson()).toList();
      await prefs.setString('uno_players', playersData.toString());
      
      // 保存记录
      final recordsData = records.map((r) => r.toJson()).toList();
      await prefs.setString('uno_records', recordsData.toString());
    } catch (e) {
      print('save_uno_game_data_failed'.tr + ': $e');
    }
  }

  // 加载游戏数据
  Future<void> _loadGameData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 加载游戏设置
      playerCount.value = prefs.getInt('uno_player_count') ?? 2;
      targetScore.value = prefs.getInt('uno_target_score') ?? 500;
      isAccumulateMode.value = prefs.getBool('uno_accumulate_mode') ?? true;
      
      // 加载玩家数据
      final playersString = prefs.getString('uno_players');
      if (playersString != null && playersString.isNotEmpty) {
        try {
          // 解析JSON字符串
          final playersData = jsonDecode(playersString) as List;
          players.clear();
          for (var data in playersData) {
            players.add(UnoPlayer.fromJson(data));
          }
        } catch (e) {
          print('parse_uno_player_data_failed'.tr + ': $e');
          _initializePlayers();
        }
      }
      
      // 加载记录
      final recordsString = prefs.getString('uno_records');
      if (recordsString != null && recordsString.isNotEmpty) {
        try {
          // 解析JSON字符串
          final recordsData = jsonDecode(recordsString) as List;
          records.clear();
          for (var data in recordsData) {
            records.add(UnoRecord.fromJson(data));
          }
        } catch (e) {
          print('parse_uno_record_data_failed'.tr + ': $e');
          records.clear();
        }
      }
    } catch (e) {
      print('load_uno_game_data_failed'.tr + ': $e');
      _initializePlayers();
    }
  }
} 