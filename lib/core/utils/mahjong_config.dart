import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MahjongConfig {
  static const String _configKeySelfDraw = 'mahjong_custom_fans_selfdraw';
  static const String _configKeyPointPao = 'mahjong_custom_fans_pointpao';
  static const String _configKeyGang = 'mahjong_custom_fans_gang';
  
  // 默认番数配置
  static const Map<String, int> defaultFans = {
    '平胡': 1,
    '碰碰胡': 2,
    '清一色': 6,
    '混一色': 4,
    '七对': 4,
    '豪华七对': 8,
    '小三元': 6,
    '大三元': 88,
    '小四喜': 64,
    '大四喜': 88,
    '字一色': 88,
    '清龙': 2,
    '三暗刻': 2,
    '混碰': 3,
    '门清自摸': 2,
    '杠上开花': 1,
    '抢杠': 1,
    '海底捞月': 1,
    '天胡': 88,
    '地胡': 88,
  };
  
  // 默认杠的番数配置
  static const Map<String, int> defaultGangFans = {
    'ming_gang': 1,
    'an_gang': 2,
    'dian_gang': 1,
  };
  
  // 获取用户自定义番数（自摸）
  static Future<Map<String, int>> getCustomFansSelfDraw() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? configJson = prefs.getString(_configKeySelfDraw);
      if (configJson != null) {
        final Map<String, dynamic> config = json.decode(configJson);
        return Map<String, int>.from(config);
      }
    } catch (e) {
      print('读取自摸番数配置失败: $e');
    }
    return {};
  }
  
  // 获取用户自定义番数（点炮）
  static Future<Map<String, int>> getCustomFansPointPao() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? configJson = prefs.getString(_configKeyPointPao);
      if (configJson != null) {
        final Map<String, dynamic> config = json.decode(configJson);
        return Map<String, int>.from(config);
      }
    } catch (e) {
      print('读取点炮番数配置失败: $e');
    }
    return {};
  }
  
  // 保存用户自定义番数（自摸）
  static Future<void> saveCustomFansSelfDraw(Map<String, int> customFans) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = json.encode(customFans);
      await prefs.setString(_configKeySelfDraw, configJson);
    } catch (e) {
      print('保存自摸番数配置失败: $e');
    }
  }
  
  // 保存用户自定义番数（点炮）
  static Future<void> saveCustomFansPointPao(Map<String, int> customFans) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = json.encode(customFans);
      await prefs.setString(_configKeyPointPao, configJson);
    } catch (e) {
      print('保存点炮番数配置失败: $e');
    }
  }
  
  // 兼容旧方法
  static Future<Map<String, int>> getCustomFans() async {
    return await getCustomFansSelfDraw();
  }
  
  // 兼容旧方法
  static Future<void> saveCustomFans(Map<String, int> customFans) async {
    await saveCustomFansSelfDraw(customFans);
  }
  
  // 获取指定胡牌类型的番数（优先使用用户自定义，否则使用默认）
  static Future<int> getFansForWinType(String winType) async {
    final customFans = await getCustomFans();
    return customFans[winType] ?? defaultFans[winType] ?? 1;
  }
  
  // 更新指定胡牌类型的番数
  static Future<void> updateFansForWinType(String winType, int fans) async {
    final customFans = await getCustomFans();
    customFans[winType] = fans;
    await saveCustomFans(customFans);
  }
  
  // 获取用户自定义杠的番数
  static Future<Map<String, int>> getCustomGangFans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? configJson = prefs.getString(_configKeyGang);
      if (configJson != null) {
        final Map<String, dynamic> config = json.decode(configJson);
        return Map<String, int>.from(config);
      }
    } catch (e) {
      print('读取杠的番数配置失败: $e');
    }
    return {};
  }
  
  // 保存用户自定义杠的番数
  static Future<void> saveCustomGangFans(Map<String, int> customGangFans) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = json.encode(customGangFans);
      await prefs.setString(_configKeyGang, configJson);
    } catch (e) {
      print('保存杠的番数配置失败: $e');
    }
  }
  
  // 获取指定杠类型的番数（优先使用用户自定义，否则使用默认）
  static Future<int> getFansForGangType(String gangType) async {
    final customGangFans = await getCustomGangFans();
    return customGangFans[gangType] ?? defaultGangFans[gangType] ?? 1;
  }
  
  // 更新指定杠类型的番数
  static Future<void> updateFansForGangType(String gangType, int fans) async {
    final customGangFans = await getCustomGangFans();
    customGangFans[gangType] = fans;
    await saveCustomGangFans(customGangFans);
  }
  
  // 重置所有配置为默认值
  static Future<void> resetAllConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 清除所有自定义配置
      await prefs.remove(_configKeySelfDraw);
      await prefs.remove(_configKeyPointPao);
      await prefs.remove(_configKeyGang);
      await prefs.remove('mahjong_zhuama_used');
      await prefs.remove('mahjong_zhuama_expanded');
    } catch (e) {
      print('重置配置失败: $e');
    }
  }
  
  // 检查是否使用过抓码
  static Future<bool> hasUsedZhuama() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('mahjong_zhuama_used') ?? false;
    } catch (e) {
      return false;
    }
  }
  
  // 标记已使用抓码
  static Future<void> markZhuamaUsed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('mahjong_zhuama_used', true);
    } catch (e) {
      print('保存抓码使用状态失败: $e');
    }
  }
  
  // 获取抓码展开状态
  // 返回 null 表示从未保存过状态
  static Future<bool?> getZhuamaExpanded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('mahjong_zhuama_expanded')) {
        return prefs.getBool('mahjong_zhuama_expanded');
      }
      return null; // 从未保存过
    } catch (e) {
      return null;
    }
  }
  
  // 保存抓码展开状态
  static Future<void> setZhuamaExpanded(bool expanded) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('mahjong_zhuama_expanded', expanded);
    } catch (e) {
      print('保存抓码展开状态失败: $e');
    }
  }
} 