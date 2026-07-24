import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Added for json.decode
import '../../../core/base/base_controller.dart';
import '../../../core/data/game_result.dart';
import '../../../core/utils/game_result_manager.dart';
import 'package:common_ui/common_ui.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart'; // Added for Color

class TexasHoldemRecord {
  final List<String> players;
  final Map<String, int> finalScores; // 最终积分
  final Map<String, int> finalChips; // 最终筹码
  final Map<String, int> winLoss; // 输赢情况
  final int initialChips; // 初始筹码
  final DateTime timestamp;

  TexasHoldemRecord({
    required this.players,
    required this.finalScores,
    required this.finalChips,
    required this.winLoss,
    required this.initialChips,
    required this.timestamp,
  });
}

class TexasHoldemController extends BaseController {
  // 玩家列表
  final RxList<String> players = <String>[].obs;
  
  // 初始筹码设置
  final RxInt initialChips = 500.obs;
  
  // 玩家积分记录 {玩家名: 积分}
  final RxMap<String, int> playerScores = <String, int>{}.obs;
  
  // 玩家最终筹码记录 {玩家名: 最终筹码}
  final RxMap<String, int> playerFinalChips = <String, int>{}.obs;
  
  // 历史记录
  final RxList<TexasHoldemRecord> records = <TexasHoldemRecord>[].obs;
  
  // 语音播报
  final VoiceAnnouncer voiceAnnouncer = VoiceAnnouncer();
  
  // 删除模式
  final RxBool isDeleteMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadGameData();
  }
  
  // 加载游戏数据
  Future<void> _loadGameData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 加载玩家列表
      final playersList = prefs.getStringList('texas_holdem_players') ?? [];
      
      // 如果没有玩家但有历史记录，从最近一次记录中恢复玩家
      if (playersList.isEmpty) {
        final recordsJson = prefs.getStringList('texas_holdem_records') ?? [];
        if (recordsJson.isNotEmpty) {
          try {
            // 获取最近一次记录
            final lastRecordJson = recordsJson.last;
            final lastRecord = _parseRecordFromJson(lastRecordJson);
            if (lastRecord != null) {
              playersList.addAll(lastRecord.players);
            }
          } catch (e) {
            print('解析历史记录失败: $e');
          }
        }
      }
      
      // 如果还是没有玩家，使用默认玩家
      if (playersList.isEmpty) {
        playersList.addAll(['player_1'.tr, 'player_2'.tr, 'player_3'.tr, 'player_4'.tr]);
      }
      
      players.value = playersList;
      
      // 加载初始筹码
      initialChips.value = prefs.getInt('texas_holdem_initial_chips') ?? 500;
      
      // 加载玩家积分
      final scores = <String, int>{};
      for (final player in playersList) {
        scores[player] = prefs.getInt('texas_holdem_score_$player') ?? 1; // 默认1积分
      }
      playerScores.value = scores;
      
      // 加载玩家最终筹码
      final finalChips = <String, int>{};
      for (final player in playersList) {
        final chips = prefs.getInt('texas_holdem_final_chips_$player');
        if (chips != null) {
          finalChips[player] = chips;
        } else {
          // 如果没有保存的筹码数据，使用默认的初始筹码数量（积分 * 初始筹码）
          final score = scores[player] ?? 1;
          finalChips[player] = score * initialChips.value;
        }
      }
      playerFinalChips.value = finalChips;
      
      // 加载历史记录
      await _loadRecords();
    } catch (e) {
      print('加载德州扑克数据失败: $e');
    }
  }

  // 从JSON解析记录
  TexasHoldemRecord? _parseRecordFromJson(String jsonString) {
    try {
      final Map<String, dynamic> json = Map<String, dynamic>.from(
        jsonDecode(jsonString)
      );
      
      return TexasHoldemRecord(
        players: List<String>.from(json['players'] ?? []),
        finalScores: Map<String, int>.from(json['finalScores'] ?? {}),
        finalChips: Map<String, int>.from(json['finalChips'] ?? {}),
        winLoss: Map<String, int>.from(json['winLoss'] ?? {}),
        initialChips: json['initialChips'] ?? 500,
        timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      print('解析记录JSON失败: $e');
      return null;
    }
  }

  // 加载历史记录
  Future<void> _loadRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getStringList('texas_holdem_records') ?? [];
      
      final loadedRecords = <TexasHoldemRecord>[];
      for (final recordJson in recordsJson) {
        final record = _parseRecordFromJson(recordJson);
        if (record != null) {
          loadedRecords.add(record);
        }
      }
      
      records.value = loadedRecords;
    } catch (e) {
      print('加载历史记录失败: $e');
    }
  }

  // 保存历史记录
  Future<void> _saveRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = records.map((record) => jsonEncode({
        'players': record.players,
        'finalScores': record.finalScores,
        'finalChips': record.finalChips,
        'winLoss': record.winLoss,
        'initialChips': record.initialChips,
        'timestamp': record.timestamp.toIso8601String(),
      })).toList();
      
      await prefs.setStringList('texas_holdem_records', recordsJson);
    } catch (e) {
      print('保存历史记录失败: $e');
    }
  }
  
  // 添加玩家
  Future<void> addPlayer(String name) async {
    if (name.isNotEmpty && !players.contains(name)) {
      players.add(name);
      playerScores[name] = 1; // 初始1积分
      playerFinalChips[name] = 1 * initialChips.value; // 初始剩余筹码
      await _savePlayers();
      await _savePlayerScores();
      await _savePlayerFinalChips();
    }
  }
  
  // 移除玩家
  Future<void> removePlayer(String name) async {
    players.remove(name);
    playerScores.remove(name);
    playerFinalChips.remove(name);
    await _savePlayers();
    await _savePlayerScores();
    await _savePlayerFinalChips();
  }
  
  // 更新玩家名称
  Future<void> updatePlayerName(int index, String newName) async {
    if (newName.isNotEmpty && !players.contains(newName)) {
      final oldName = players[index];
      final score = playerScores[oldName] ?? 1;
      final chips = playerFinalChips[oldName] ?? (score * initialChips.value);
      
      players[index] = newName;
      playerScores.remove(oldName);
      playerScores[newName] = score;
      playerFinalChips.remove(oldName);
      playerFinalChips[newName] = chips;
      
      await _savePlayers();
      await _savePlayerScores();
      await _savePlayerFinalChips();
    }
  }
  
  // 更新初始筹码
  Future<void> updateInitialChips(int newChips) async {
    initialChips.value = newChips;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('texas_holdem_initial_chips', newChips);
    } catch (e) {
      print('保存初始筹码失败: $e');
    }
  }
  
  // 更新玩家最终筹码
  Future<void> updatePlayerFinalChips(String player, int finalChips) async {
    playerFinalChips[player] = finalChips;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('texas_holdem_final_chips_$player', finalChips);
    } catch (e) {
      print('保存玩家最终筹码失败: $e');
    }
  }
  
  // 调整玩家积分
  Future<void> adjustPlayerScore(String player, int adjustment) async {
    if (playerScores.containsKey(player)) {
      final currentScore = playerScores[player] ?? 1;
      final newScore = currentScore + adjustment;
      
      // 确保积分不能小于1
      if (newScore >= 1) {
        playerScores[player] = newScore;
        await _savePlayerScores();
        
        // 语音播报
        if (voiceAnnouncer.isEnabled.value) {
          final action = adjustment > 0 ? 'texas_holdem_gained'.tr : 'texas_holdem_lost'.tr;
          voiceAnnouncer.announce('texas_holdem_score_adjustment'.tr.replaceAll('{player}', player).replaceAll('{action}', action).replaceAll('{adjustment}', adjustment.abs().toString()));
        }
      } else {
        // 如果尝试减到0或负数，显示提示
        Get.snackbar('提示', '次数不能少于1次');
      }
    }
  }
  
  // 计算最终筹码
  Map<String, int> calculateFinalChips(Map<String, int> finalScores) {
    final chips = <String, int>{};
    for (final entry in finalScores.entries) {
      chips[entry.key] = entry.value * initialChips.value;
    }
    return chips;
  }
  
  // 计算输赢情况
  Map<String, int> calculateWinLoss(Map<String, int> finalChips) {
    final winLoss = <String, int>{};
    for (final entry in finalChips.entries) {
      winLoss[entry.key] = entry.value - initialChips.value; // 最终筹码 - 初始筹码
    }
    return winLoss;
  }
  
  // 验证总输赢是否为0
  bool validateTotalWinLoss(Map<String, int> winLoss) {
    final total = winLoss.values.fold(0, (sum, value) => sum + value);
    return total == 0;
  }
  
  // 保存比赛结果
  Future<void> saveGameResult(Map<String, int> finalScores) async {
    final finalChips = calculateFinalChips(finalScores);
    final winLoss = calculateWinLoss(finalChips);
    
    if (!validateTotalWinLoss(winLoss)) {
      Get.snackbar('错误', '总输赢不为0，请检查数据');
      return;
    }
    
    final record = TexasHoldemRecord(
      players: List.from(players),
      finalScores: Map.from(finalScores),
      finalChips: Map.from(finalChips),
      winLoss: Map.from(winLoss),
      initialChips: initialChips.value,
      timestamp: DateTime.now(),
    );
    
    records.add(record);
    await _saveRecords(); // 保存记录
    
    // 重置积分为初始状态
    for (final player in players) {
      playerScores[player] = 1;
    }
    await _savePlayerScores();
    
    // 语音播报
    if (voiceAnnouncer.isEnabled.value) {
      voiceAnnouncer.announce('texas_holdem_result_saved'.tr);
    }
  }
  
  // 重置所有积分和剩余筹码
  Future<void> resetAllScores() async {
    for (final player in players) {
      playerScores[player] = 1; // 重置为1积分
      // 重置剩余筹码为初始筹码数量（积分 * 初始筹码）
      playerFinalChips[player] = 1 * initialChips.value;
    }
    await _savePlayerScores();
    await _savePlayerFinalChips();
  }
  
  // 保存玩家最终筹码
  Future<void> _savePlayerFinalChips() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final entry in playerFinalChips.entries) {
        await prefs.setInt('texas_holdem_final_chips_${entry.key}', entry.value);
      }
    } catch (e) {
      print('保存玩家最终筹码失败: $e');
    }
  }

  // 退出删除模式
  void exitDeleteMode() {
    isDeleteMode.value = false;
  }

  // 切换删除模式
  void toggleDeleteMode() {
    isDeleteMode.value = !isDeleteMode.value;
  }
  
  // 获取玩家统计
  Map<String, Map<String, dynamic>> getPlayerStats() {
    final stats = <String, Map<String, dynamic>>{};
    
    // 初始化所有玩家
    for (final player in players) {
      stats[player] = {
        'totalGames': 0,
        'totalWinLoss': 0,
        'averageWinLoss': 0,
      };
    }
    
    // 统计历史记录
    for (final record in records) {
      for (final entry in record.winLoss.entries) {
        final player = entry.key;
        final winLoss = entry.value;
        
        if (stats.containsKey(player)) {
          stats[player]!['totalGames'] = (stats[player]!['totalGames'] as int) + 1;
          stats[player]!['totalWinLoss'] = (stats[player]!['totalWinLoss'] as int) + winLoss;
        }
      }
    }
    
    // 计算平均输赢
    for (final entry in stats.entries) {
      final totalGames = entry.value['totalGames'] as int;
      final totalWinLoss = entry.value['totalWinLoss'] as int;
      entry.value['averageWinLoss'] = totalGames > 0 ? (totalWinLoss / totalGames).round() : 0;
    }
    
    return stats;
  }
  
  // 生成结算报告
  String generateSettlementReport() {
    final stats = getPlayerStats();
    final totalGames = records.length;
    
    // 按平均输赢排序
    final sortedPlayers = stats.entries.toList()
      ..sort((a, b) => (b.value['averageWinLoss'] as int).compareTo(a.value['averageWinLoss'] as int));
    
    StringBuffer report = StringBuffer();
    report.writeln('🎯 德州扑克统计（共${totalGames}局）');
    report.writeln();
    report.writeln('| 玩家 | 总局数 | 总输赢 | 平均输赢 |');
    report.writeln('|------|--------|--------|----------|');
    
    for (final entry in sortedPlayers) {
      final player = entry.key;
      final data = entry.value;
      final totalGames = data['totalGames'] as int;
      final totalWinLoss = data['totalWinLoss'] as int;
      final averageWinLoss = data['averageWinLoss'] as int;
      
      report.writeln('| $player | $totalGames | ${totalWinLoss > 0 ? '+' : ''}$totalWinLoss | ${averageWinLoss > 0 ? '+' : ''}$averageWinLoss |');
    }
    
    report.writeln();
    report.writeln('初始筹码：${initialChips.value} 分');
    
    return report.toString();
  }

  // 生成当前游戏统计报告
  String generateCurrentGameReport() {
    if (players.isEmpty) {
      return '暂无玩家数据';
    }
    
    StringBuffer report = StringBuffer();
    report.writeln('🎯 当前游戏统计');
    report.writeln();
    report.writeln('| 玩家姓名 | 初始筹码 | 剩余筹码 | 盈亏筹码 |');
    report.writeln('|----------|----------|----------|----------|');
    
    int totalInitialChips = 0;
    int totalFinalChips = 0;
    int totalWinLoss = 0;
    
    for (final player in players) {
      final currentScore = playerScores[player] ?? 1;
      final initialChips = currentScore * this.initialChips.value;
      final finalChips = playerFinalChips[player] ?? 0;
      final winLoss = finalChips - initialChips;
      
      totalInitialChips += initialChips;
      totalFinalChips += finalChips;
      totalWinLoss += winLoss;
      
      final winLossText = winLoss >= 0 ? '+$winLoss' : '$winLoss';
      final winLossColor = winLoss >= 0 ? '🟢' : '🔴';
      
      report.writeln('| $player | ${initialChips}分 | ${finalChips}分 | $winLossColor$winLossText分 |');
    }
    
    report.writeln();
    report.writeln('📊 统计信息：');
    report.writeln('• 玩家总数：${players.length}人');
    report.writeln('• 初始筹码：${this.initialChips.value}分');
    report.writeln('• 总初始筹码：${totalInitialChips}分');
    report.writeln('• 总剩余筹码：${totalFinalChips}分');
    report.writeln('• 总盈亏筹码：${totalWinLoss >= 0 ? '+' : ''}${totalWinLoss}分');
    
    // 显示已录入筹码的玩家数量
    final recordedPlayers = playerFinalChips.keys.length;
    report.writeln('• 已录入玩家：$recordedPlayers/${players.length}人');
    
    return report.toString();
  }

  // 保存当前游戏结果
  Future<void> saveCurrentGameResult() async {
    if (players.isEmpty) {
      Get.snackbar('错误', '没有玩家数据');
      return;
    }
    
    final finalScores = <String, int>{};
    for (final player in players) {
      finalScores[player] = playerScores[player] ?? 1;
    }
    
    final finalChips = calculateFinalChips(finalScores);
    final winLoss = calculateWinLoss(finalChips);
    final total = winLoss.values.fold(0, (sum, value) => sum + value);
    
    if (total != 0) {
      Get.snackbar('错误', '总输赢不为0，请检查数据');
      return;
    }
    
    await saveGameResult(finalScores);
    Get.snackbar('成功', '游戏结果已保存');
  }
  
  // 保存当前游戏数据到历史记录
  Future<void> saveCurrentGameDataToHistory() async {
    if (players.isEmpty) {
      Get.snackbar('错误', '没有玩家数据');
      return;
    }
    
    final finalScores = <String, int>{};
    final finalChips = <String, int>{};
    final winLoss = <String, int>{};
    
    for (final player in players) {
      finalScores[player] = playerScores[player] ?? 1;
      final playerFinalChips = this.playerFinalChips[player];
      
      if (playerFinalChips != null) {
        finalChips[player] = playerFinalChips;
        final initialChips = (playerScores[player] ?? 1) * this.initialChips.value;
        winLoss[player] = playerFinalChips - initialChips;
      } else {
        finalChips[player] = 0;
        winLoss[player] = 0;
      }
    }
    
    final record = TexasHoldemRecord(
      players: players.toList(),
      finalScores: finalScores,
      finalChips: finalChips,
      winLoss: winLoss,
      initialChips: initialChips.value,
      timestamp: DateTime.now(),
    );
    
    records.add(record);
    await _saveRecords();
    
    Get.snackbar(
      '保存成功',
      '游戏数据已保存到历史记录',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
  
  // 保存玩家列表
  Future<void> _savePlayers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('texas_holdem_players', players);
    } catch (e) {
      print('保存玩家列表失败: $e');
    }
  }
  
  // 保存玩家积分
  Future<void> _savePlayerScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final entry in playerScores.entries) {
        await prefs.setInt('texas_holdem_score_${entry.key}', entry.value);
      }
    } catch (e) {
      print('保存玩家积分失败: $e');
    }
  }
  
  // 保存游戏结果到历史
  Future<void> saveGameResultToHistory() async {
    final gameResult = GameResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gameType: '德州扑克',
      team1Name: players.isNotEmpty ? players.first : '',
      team2Name: players.length > 1 ? players[1] : '',
      team1Score: players.isNotEmpty ? (playerScores[players.first] ?? 1) : 0,
      team2Score: players.length > 1 ? (playerScores[players[1]] ?? 1) : 0,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      duration: 0,
      additionalData: {
        'initialChips': initialChips.value,
        'players': players.toList(),
        'playerScores': Map<String, int>.from(playerScores),
        'records': records.map((r) => {
          'players': r.players,
          'finalScores': r.finalScores,
          'finalChips': r.finalChips,
          'winLoss': r.winLoss,
          'initialChips': r.initialChips,
        }).toList(),
      },
    );
    
    await GameResultManager.saveGameResult(gameResult);
  }
} 