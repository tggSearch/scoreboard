import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/game_result.dart';

class GameResultManager {
  static const String _keyGameResults = 'game_results';
  
  // 保存比赛结果
  static Future<bool> saveGameResult(GameResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 获取现有结果列表
      final existingResultsJson = prefs.getStringList(_keyGameResults) ?? [];
      final existingResults = existingResultsJson
          .map((json) => GameResult.fromMap(jsonDecode(json)))
          .toList();
      
      // 添加新结果
      existingResults.add(result);
      
      // 按时间倒序排列（最新的在前面）
      existingResults.sort((a, b) => b.endTime.compareTo(a.endTime));
      
      // 限制保存数量，最多保存100条记录
      if (existingResults.length > 100) {
        existingResults.removeRange(100, existingResults.length);
      }
      
      // 保存回本地存储
      final resultsJson = existingResults
          .map((result) => jsonEncode(result.toMap()))
          .toList();
      
      await prefs.setStringList(_keyGameResults, resultsJson);
      
      return true;
    } catch (e) {
      print('保存比赛结果失败: $e');
      return false;
    }
  }
  
  // 获取所有比赛结果
  static Future<List<GameResult>> getAllGameResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final resultsJson = prefs.getStringList(_keyGameResults) ?? [];
      
      return resultsJson
          .map((json) => GameResult.fromMap(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('获取比赛结果失败: $e');
      return [];
    }
  }
  
  // 根据比赛类型获取结果
  static Future<List<GameResult>> getGameResultsByType(String gameType) async {
    final allResults = await getAllGameResults();
    return allResults.where((result) => result.gameType == gameType).toList();
  }
  
  // 删除比赛结果
  static Future<bool> deleteGameResult(String resultId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final resultsJson = prefs.getStringList(_keyGameResults) ?? [];
      
      final results = resultsJson
          .map((json) => GameResult.fromMap(jsonDecode(json)))
          .where((result) => result.id != resultId)
          .toList();
      
      final newResultsJson = results
          .map((result) => jsonEncode(result.toMap()))
          .toList();
      
      await prefs.setStringList(_keyGameResults, newResultsJson);
      
      return true;
    } catch (e) {
      print('删除比赛结果失败: $e');
      return false;
    }
  }
  
  // 清空所有比赛结果
  static Future<bool> clearAllGameResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyGameResults);
      return true;
    } catch (e) {
      print('清空比赛结果失败: $e');
      return false;
    }
  }
  
  // 获取比赛统计信息
  static Future<Map<String, dynamic>> getGameStatistics() async {
    final allResults = await getAllGameResults();
    
    if (allResults.isEmpty) {
      return {
        'totalGames': 0,
        'totalWins': 0,
        'totalLosses': 0,
        'totalDraws': 0,
        'averageScore': 0,
        'gameTypes': {},
      };
    }
    
    int totalWins = 0;
    int totalLosses = 0;
    int totalDraws = 0;
    int totalScore = 0;
    Map<String, int> gameTypes = {};
    
    for (final result in allResults) {
      if (result.winner != null) {
        totalWins++;
      } else {
        totalDraws++;
      }
      
      totalScore += result.team1Score + result.team2Score;
      gameTypes[result.gameType] = (gameTypes[result.gameType] ?? 0) + 1;
    }
    
    return {
      'totalGames': allResults.length,
      'totalWins': totalWins,
      'totalLosses': totalLosses,
      'totalDraws': totalDraws,
      'averageScore': totalScore / allResults.length,
      'gameTypes': gameTypes,
    };
  }
  
  // 生成唯一ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
} 