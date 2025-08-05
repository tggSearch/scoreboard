import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScoreType {
  final String id;
  final String nameKey;
  final String categoryKey;
  final IconData icon;

  const ScoreType({
    required this.id,
    required this.nameKey,
    required this.categoryKey,
    required this.icon,
  });

  String get displayName => nameKey.tr;
  String get displayCategory => categoryKey.tr;

  // 搜索匹配
  bool matches(String query) {
    final lowerQuery = query.toLowerCase();
    return displayName.toLowerCase().contains(lowerQuery) ||
           displayCategory.toLowerCase().contains(lowerQuery);
  }
}

class ScoreTypesData {
  static const List<ScoreType> allTypes = [
    // 体育类
    ScoreType(
      id: 'basketball',
      nameKey: 'basketball',
      categoryKey: 'sports',
      icon: Icons.sports_basketball,
    ),
    ScoreType(
      id: 'football',
      nameKey: 'football',
      categoryKey: 'sports',
      icon: Icons.sports_soccer,
    ),
    ScoreType(
      id: 'badminton',
      nameKey: 'badminton',
      categoryKey: 'sports',
      icon: Icons.sports_tennis,
    ),
    ScoreType(
      id: 'pingpong',
      nameKey: 'pingpong',
      categoryKey: 'sports',
      icon: Icons.sports_tennis,
    ),
    ScoreType(
      id: 'tennis',
      nameKey: 'tennis',
      categoryKey: 'sports',
      icon: Icons.sports_tennis,
    ),
    ScoreType(
      id: 'volleyball',
      nameKey: 'volleyball',
      categoryKey: 'sports',
      icon: Icons.sports_volleyball,
    ),

    // 棋牌类
    ScoreType(
      id: 'mahjong',
      nameKey: 'mahjong',
      categoryKey: 'card_games',
      icon: Icons.casino,
    ),
    ScoreType(
      id: 'texas_holdem',
      nameKey: 'texas_holdem',
      categoryKey: 'card_games',
      icon: Icons.style,
    ),
    ScoreType(
      id: 'doudizhu',
      nameKey: 'doudizhu',
      categoryKey: 'card_games',
      icon: Icons.style,
    ),
    ScoreType(
      id: 'bridge',
      nameKey: 'bridge',
      categoryKey: 'card_games',
      icon: Icons.style,
    ),
    ScoreType(
      id: 'uno',
      nameKey: 'uno',
      categoryKey: 'card_games',
      icon: Icons.style,
    ),

    // 其他类
    ScoreType(
      id: 'custom_score',
      nameKey: 'custom_score',
      categoryKey: 'others',
      icon: Icons.edit,
    ),
  ];

  // 获取常用计分类型
  static List<ScoreType> get commonTypes => [
    allTypes.firstWhere((type) => type.id == 'basketball'),
    allTypes.firstWhere((type) => type.id == 'football'),
    allTypes.firstWhere((type) => type.id == 'badminton'),
    allTypes.firstWhere((type) => type.id == 'mahjong'),
  ];

  // 获取热门计分类型
  static List<ScoreType> get popularTypes => [
    allTypes.firstWhere((type) => type.id == 'pingpong'),
    allTypes.firstWhere((type) => type.id == 'tennis'),
    allTypes.firstWhere((type) => type.id == 'volleyball'),
    allTypes.firstWhere((type) => type.id == 'doudizhu'),
    allTypes.firstWhere((type) => type.id == 'texas_holdem'),
    allTypes.firstWhere((type) => type.id == 'custom_score'),
  ];

  // 按分类获取计分类型
  static Map<String, List<ScoreType>> get groupedTypes {
    final grouped = <String, List<ScoreType>>{};
    for (final type in allTypes) {
      grouped.putIfAbsent(type.displayCategory, () => []).add(type);
    }
    return grouped;
  }

  // 搜索计分类型
  static List<ScoreType> search(String query) {
    if (query.isEmpty) return [];
    return allTypes.where((type) => type.matches(query)).toList();
  }
} 