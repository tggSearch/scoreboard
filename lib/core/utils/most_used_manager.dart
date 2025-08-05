import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class MostUsedManager {
  static const String _key = 'most_used_games';
  
  // 默认最常用项目
  static const List<String> _defaultGames = ['basketball', 'mahjong', 'texas_holdem'];
  
  // 获取最常用项目（前3个）
  static Future<List<String>> getMostUsedGames() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_key);
      
      if (data == null) {
        // 首次使用，返回默认值
        return _defaultGames;
      }
      
      // 解析存储的数据
      final List<String> games = data.split(',');
      List<String> result = [];
      
      // 添加有记录的游戏中前3个
      for (String game in games) {
        if (game.contains(':')) {
          final parts = game.split(':');
          if (parts.length == 2) {
            final gameId = parts[0];
            if (!result.contains(gameId)) {
              result.add(gameId);
              if (result.length >= 3) break;
            }
          }
        }
      }
      
      // 如果不足3个，从默认列表中补充
      if (result.length < 3) {
        for (String defaultGame in _defaultGames) {
          if (!result.contains(defaultGame)) {
            result.add(defaultGame);
            if (result.length >= 3) break;
          }
        }
      }
      
      return result;
    } catch (e) {
      print('获取最常用项目失败: $e');
      return _defaultGames;
    }
  }
  
  // 记录游戏点击
  static Future<void> recordGameClick(String gameId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_key);
      
      Map<String, int> gameCounts = {};
      
      if (data != null) {
        // 解析现有数据
        final List<String> games = data.split(',');
        for (String game in games) {
          if (game.contains(':')) {
            final parts = game.split(':');
            if (parts.length == 2) {
              final gameId = parts[0];
              final count = int.tryParse(parts[1]) ?? 0;
              gameCounts[gameId] = count;
            }
          }
        }
      }
      
      // 增加当前游戏的点击次数
      gameCounts[gameId] = (gameCounts[gameId] ?? 0) + 1;
      
      // 按点击次数排序
      final sortedGames = gameCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      // 转换为字符串格式存储
      final String newData = sortedGames
          .map((entry) => '${entry.key}:${entry.value}')
          .join(',');
      
      await prefs.setString(_key, newData);
      
      print('记录游戏点击: $gameId, 当前数据: $newData');
    } catch (e) {
      print('记录游戏点击失败: $e');
    }
  }
  
  // 获取游戏显示名称
  static String getGameDisplayName(String gameId) {
    return gameId.tr;
  }
  
  // 获取游戏图标
  static String getGameEmoji(String gameId) {
    switch (gameId) {
      case 'basketball':
        return '🏀';
      case 'football':
        return '⚽';
      case 'badminton':
        return '🏸';
      case 'mahjong':
        return '🀄';
      case 'texas_holdem':
        return '🃏';
      case 'pingpong':
        return '🏓';
      case 'tennis':
        return '🎾';
      case 'volleyball':
        return '🏐';
      case 'doudizhu':
        return '🃏';
      case 'bridge':
        return '🃏';
      case 'uno':
        return '🃏';
      case 'custom_score':
        return '📊';
      default:
        return '🎮';
    }
  }
  
  // 获取游戏颜色
  static int getGameColor(String gameId) {
    switch (gameId) {
      case 'basketball':
        return 0xFFFF5722; // 橙色
      case 'football':
        return 0xFF2196F3; // 蓝色
      case 'badminton':
        return 0xFF4CAF50; // 绿色
      case 'mahjong':
        return 0xFF9C27B0; // 紫色
      case 'texas_holdem':
        return 0xFF795548; // 棕色
      case 'pingpong':
        return 0xFFFF9800; // 橙色
      case 'tennis':
        return 0xFF4CAF50; // 绿色
      case 'volleyball':
        return 0xFFE91E63; // 粉色
      case 'doudizhu':
        return 0xFF607D8B; // 蓝灰色
      case 'bridge':
        return 0xFF3F51B5; // 靛蓝色
      case 'uno':
        return 0xFF00BCD4; // 青色
      case 'custom_score':
        return 0xFF9C27B0; // 紫色
      default:
        return 0xFF9E9E9E; // 灰色
    }
  }
  
  // 获取游戏路由
  static String getGameRoute(String gameId) {
    switch (gameId) {
      case 'basketball':
        return '/basketball';
      case 'football':
        return '/football';
      case 'badminton':
        return '/badminton';
      case 'pingpong':
        return '/pingpong';
      case 'volleyball':
        return '/volleyball';
      case 'tennis':
        return '/tennis';
      case 'mahjong':
        return '/mahjong';
      case 'doudizhu':
        return '/doudizhu'; // 斗地主使用独立页面
      case 'texas_holdem':
        return '/texas-holdem';
      case 'uno':
        return '/uno';
      case 'bridge':
        return '/bridge';
      case 'custom_score':
        return '/custom-score';
      default:
        return '';
    }
  }
} 