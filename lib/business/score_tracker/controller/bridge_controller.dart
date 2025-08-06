import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/data/game_result.dart';
import '../../../core/utils/game_result_manager.dart';
import 'package:common_ui/common_ui.dart';

class BridgePlayer {
  String name;
  String position; // "NS" 或 "EW"

  BridgePlayer({
    required this.name,
    required this.position,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
    };
  }

  factory BridgePlayer.fromJson(Map<String, dynamic> json) {
    return BridgePlayer(
      name: json['name'] ?? '',
      position: json['position'] ?? '',
    );
  }
}

class BridgeRecord {
  final String contract; // 定约，如 "3♠"
  final String doubleStatus; // 加倍状态：无加倍/加倍/红ouble
  final String declarer; // 成交方：NS/EW
  final int tricks; // 实际赢得墩数
  final bool vulnerable; // 是否有局
  final int nsScore; // 南北得分
  final int ewScore; // 东西得分
  final DateTime timestamp;

  BridgeRecord({
    required this.contract,
    required this.doubleStatus,
    required this.declarer,
    required this.tricks,
    required this.vulnerable,
    required this.nsScore,
    required this.ewScore,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'contract': contract,
      'doubleStatus': doubleStatus,
      'declarer': declarer,
      'tricks': tricks,
      'vulnerable': vulnerable,
      'nsScore': nsScore,
      'ewScore': ewScore,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory BridgeRecord.fromJson(Map<String, dynamic> json) {
    return BridgeRecord(
      contract: json['contract'] ?? '',
      doubleStatus: json['doubleStatus'] ?? '',
      declarer: json['declarer'] ?? '',
      tricks: json['tricks'] ?? 0,
      vulnerable: json['vulnerable'] ?? false,
      nsScore: json['nsScore'] ?? 0,
      ewScore: json['ewScore'] ?? 0,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class BridgeController extends BaseController {
  // 玩家信息
  final RxList<BridgePlayer> players = <BridgePlayer>[].obs;
  
  // Current round settings
  final RxString currentContract = ''.obs;
  final RxString currentDoubleStatus = 'no_double'.tr.obs;
  final RxString currentDeclarer = 'north_south'.obs;
  final RxInt currentTricks = 6.obs;
  final RxBool currentVulnerable = false.obs;
  
  // 游戏记录
  final RxList<BridgeRecord> records = <BridgeRecord>[].obs;
  
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

  // Initialize players
  void _initializePlayers() {
    if (players.isEmpty) {
      players.addAll([
              BridgePlayer(name: 'player_1'.tr, position: 'north_south'),
      BridgePlayer(name: 'player_2'.tr, position: 'north_south'),
      BridgePlayer(name: 'player_3'.tr, position: 'east_west'),
      BridgePlayer(name: 'player_4'.tr, position: 'east_west'),
      ]);
    }
  }

  // 设置玩家名称
  Future<void> setPlayerName(int index, String name) async {
    if (index >= 0 && index < players.length && name.trim().isNotEmpty) {
      players[index].name = name.trim();
      // 触发UI更新
      players.refresh();
      _saveGameData();
    }
  }

  // 设置定约
  void setContract(String contract) {
    currentContract.value = contract;
  }

  // 设置加倍状态
  void setDoubleStatus(String status) {
    currentDoubleStatus.value = status;
  }

  // 设置成交方
  void setDeclarer(String declarer) {
    currentDeclarer.value = declarer;
  }

  // 设置墩数
  void setTricks(int tricks) {
    if (tricks >= 6 && tricks <= 13) {
      currentTricks.value = tricks;
    }
  }

  // 获取常见定约选项
  List<String> get commonContracts => [
    '1♣', '1♦', '1♥', '1♠', '1NT',
    '2♣', '2♦', '2♥', '2♠', '2NT',
    '3♣', '3♦', '3♥', '3♠', '3NT',
    '4♣', '4♦', '4♥', '4♠', '4NT',
    '5♣', '5♦', '5♥', '5♠', '5NT',
    '6♣', '6♦', '6♥', '6♠', '6NT',
    '7♣', '7♦', '7♥', '7♠', '7NT',
  ];

  // 获取常见墩数选项
  List<int> get commonTricks => [6, 7, 8, 9, 10, 11, 12, 13];

  // 设置是否有局
  void setVulnerable(bool vulnerable) {
    currentVulnerable.value = vulnerable;
  }

  // 计算桥牌得分
  Map<String, int> _calculateBridgeScore() {
    if (currentContract.value.isEmpty) {
      return {'north_south': 0, 'east_west': 0};
    }

    // 解析定约
    final contract = currentContract.value;
    final level = int.tryParse(contract[0]) ?? 0;
    final suit = contract.length > 1 ? contract.substring(1) : '';
    
    // 计算需要的墩数
    final requiredTricks = level + 6;
    final actualTricks = currentTricks.value;
    final overTricks = actualTricks - requiredTricks;
    
    // 基础得分
    int baseScore = 0;
    int bonus = 0;
    
    // 根据花色计算基础得分
    if (suit == 'NT') {
      baseScore = level * 40 + (level - 1) * 10;
    } else if (suit == '♠' || suit == '♥') {
      baseScore = level * 30;
    } else {
      baseScore = level * 20;
    }
    
    // 加倍计算
    if (currentDoubleStatus.value == 'double'.tr) {
      baseScore *= 2;
      if (overTricks > 0) {
        bonus += overTricks * 100;
      }
    } else if (currentDoubleStatus.value == 'redouble'.tr) {
      baseScore *= 4;
      if (overTricks > 0) {
        bonus += overTricks * 200;
      }
    } else {
      if (overTricks > 0) {
        bonus += overTricks * (suit == 'NT' || suit == '♠' || suit == '♥' ? 30 : 20);
      }
    }
    
    // 成局奖励
    if (baseScore >= 100) {
      if (currentVulnerable.value) {
        bonus += 500;
      } else {
        bonus += 300;
      }
    }
    
    // 小满贯奖励
    if (level >= 6) {
      if (currentVulnerable.value) {
        bonus += 750;
      } else {
        bonus += 500;
      }
    }
    
    // 大满贯奖励
    if (level >= 7) {
      if (currentVulnerable.value) {
        bonus += 1500;
      } else {
        bonus += 1000;
      }
    }
    
    final totalScore = baseScore + bonus;
    
    // 如果失败
    if (actualTricks < requiredTricks) {
      final underTricks = requiredTricks - actualTricks;
      int penalty = 0;
      
      if (currentDoubleStatus.value == 'no_double'.tr) {
        penalty = underTricks * (currentVulnerable.value ? 100 : 50);
      } else if (currentDoubleStatus.value == 'double'.tr) {
        penalty = underTricks * (currentVulnerable.value ? 200 : 100);
      } else if (currentDoubleStatus.value == 'redouble'.tr) {
        penalty = underTricks * (currentVulnerable.value ? 400 : 200);
      }
      
      return {
              'north_south': currentDeclarer.value == 'north_south' ? -penalty : penalty,
      'east_west': currentDeclarer.value == 'east_west' ? -penalty : penalty,
      };
    }
    
    return {
      'north_south': currentDeclarer.value == 'north_south' ? totalScore : -totalScore,
      'east_west': currentDeclarer.value == 'east_west' ? totalScore : -totalScore,
    };
  }

  // 结束当前局
  void endRound() {
    if (currentContract.value.isEmpty) {
      Get.snackbar('error'.tr, 'please_input_contract'.tr);
      return;
    }

    final scores = _calculateBridgeScore();
    
    // 创建记录
    final record = BridgeRecord(
      contract: currentContract.value,
      doubleStatus: currentDoubleStatus.value,
      declarer: currentDeclarer.value,
      tricks: currentTricks.value,
      vulnerable: currentVulnerable.value,
      nsScore: scores['north_south']!,
      ewScore: scores['east_west']!,
      timestamp: DateTime.now(),
    );
    records.add(record);

    // 保存到游戏结果管理器
    _addRecord(record);

    // Voice announcement
    final declarerName = currentDeclarer.value == 'north_south' ? 'north_south'.tr : 'east_west'.tr;
    final score = scores[currentDeclarer.value.toLowerCase()]!;
    if (score > 0) {
      voiceAnnouncer.announce('contract_completed'.tr.replaceAll('{declarer}', declarerName).replaceAll('{contract}', currentContract.value).replaceAll('{score}', score.toString()));
    } else {
      voiceAnnouncer.announce('contract_failed'.tr.replaceAll('{declarer}', declarerName).replaceAll('{contract}', currentContract.value).replaceAll('{score}', (-score).toString()));
    }

    // Reset current round data
    currentContract.value = '';
    currentDoubleStatus.value = 'no_double'.tr;
    currentDeclarer.value = 'north_south';
    currentTricks.value = 6;
    // 自动切换是否有局
    currentVulnerable.value = !currentVulnerable.value;

    _saveGameData();
  }

  // Reset game
  void resetGame() {
    records.clear();
    currentContract.value = '';
    currentDoubleStatus.value = 'no_double'.tr;
    currentDeclarer.value = 'north_south';
    currentTricks.value = 6;
    currentVulnerable.value = false;
    _saveGameData();
    voiceAnnouncer.announce('game_has_been_reset'.tr);
  }

  // 获取南北总分
  int get nsTotalScore {
    return records.fold(0, (sum, record) => sum + record.nsScore);
  }

  // 获取东西总分
  int get ewTotalScore {
    return records.fold(0, (sum, record) => sum + record.ewScore);
  }

  // 获取排行榜
  List<Map<String, dynamic>> get leaderboard {
    final List<Map<String, dynamic>> playerList = [];
    
    // 计算每个玩家的总分
    for (int i = 0; i < this.players.length; i++) {
      final player = this.players[i];
      int totalScore = 0;
      
      // 根据玩家位置计算总分
      for (final record in records) {
        if (player.position == 'north_south') {
          totalScore += record.nsScore;
        } else if (player.position == 'east_west') {
          totalScore += record.ewScore;
        }
      }
      
      playerList.add({
        'name': player.name,
        'score': totalScore,
        'position': player.position,
      });
    }
    
    playerList.sort((a, b) {
      final scoreA = a['score'] as int;
      final scoreB = b['score'] as int;
      return scoreB.compareTo(scoreA);
    });
    return playerList;
  }

  // 添加记录到游戏结果管理器
  void _addRecord(BridgeRecord record) {
    final gameResult = GameResult(
      id: 'bridge_${record.timestamp.millisecondsSinceEpoch}',
      gameType: 'bridge',
      team1Name: 'north_south'.tr,
      team2Name: 'east_west'.tr,
      team1Score: record.nsScore,
      team2Score: record.ewScore,
      startTime: record.timestamp,
      endTime: record.timestamp,
      duration: 60, // 1 minute
    );
    GameResultManager.saveGameResult(gameResult);
  }

  // 保存游戏数据
  Future<void> _saveGameData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 保存玩家数据
      final playersData = players.map((p) => p.toJson()).toList();
      await prefs.setString('bridge_players', jsonEncode(playersData));
      
      // 保存记录
      final recordsData = records.map((r) => r.toJson()).toList();
      await prefs.setString('bridge_records', jsonEncode(recordsData));
    } catch (e) {
      print('Failed to save bridge game data: $e');
    }
  }

  // 加载游戏数据
  Future<void> _loadGameData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 加载玩家数据
      final playersString = prefs.getString('bridge_players');
      if (playersString != null && playersString.isNotEmpty) {
        try {
          final playersData = jsonDecode(playersString) as List;
          players.clear();
          for (var data in playersData) {
            players.add(BridgePlayer.fromJson(data));
          }
        } catch (e) {
          print('Failed to parse player data: $e');
          _initializePlayers();
        }
      }
      
      // 加载记录
      final recordsString = prefs.getString('bridge_records');
      if (recordsString != null && recordsString.isNotEmpty) {
        try {
          final recordsData = jsonDecode(recordsString) as List;
          records.clear();
          for (var data in recordsData) {
            records.add(BridgeRecord.fromJson(data));
          }
        } catch (e) {
          print('Failed to parse record data: $e');
          records.clear();
        }
      }
    } catch (e) {
      print('Failed to load bridge game data: $e');
      _initializePlayers();
    }
  }
} 