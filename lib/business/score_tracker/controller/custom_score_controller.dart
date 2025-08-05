import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/base/base_controller.dart';
import 'package:common_ui/common_ui.dart';

class CustomPlayer {
  String name;
  int score;

  CustomPlayer({
    required this.name,
    this.score = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'score': score,
    };
  }

  factory CustomPlayer.fromJson(Map<String, dynamic> json) {
    return CustomPlayer(
      name: json['name'] ?? '',
      score: json['score'] ?? 0,
    );
  }
}

class CustomScoreController extends BaseController {
  // 玩家列表
  final RxList<CustomPlayer> players = <CustomPlayer>[].obs;
  
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
    if (players.isEmpty) {
      players.addAll([
        CustomPlayer(name: 'player_1'),
        CustomPlayer(name: 'player_2'),
        CustomPlayer(name: 'player_3'),
        CustomPlayer(name: 'player_4'),
      ]);
    }
  }

  // 添加玩家
  void addPlayer(String name) {
    if (name.trim().isNotEmpty) {
      players.add(CustomPlayer(name: name.trim()));
      _saveGameData();
    }
  }

  // 删除玩家
  void removePlayer(int index) {
    if (index >= 0 && index < players.length && players.length > 1) {
      players.removeAt(index);
      _saveGameData();
    }
  }

  // 设置玩家名称
  void setPlayerName(int index, String name) {
    if (index >= 0 && index < players.length && name.trim().isNotEmpty) {
      players[index].name = name.trim();
      _saveGameData();
    }
  }

  // 设置玩家分数
  void setPlayerScore(int index, int score) {
    if (index >= 0 && index < players.length) {
      players[index].score = score;
      _saveGameData();
    }
  }

  // 重置所有分数
  void resetAllScores() {
    for (var player in players) {
      player.score = 0;
    }
    _saveGameData();
    voiceAnnouncer.announce('all_scores_reset'.tr);
  }

  // 获取总分
  int get totalScore {
    return players.fold(0, (sum, player) => sum + player.score);
  }

  // 生成复制文本
  String generateCopyText() {
    if (players.isEmpty) return '';
    
    final List<String> lines = [];
    lines.add('custom_score_result'.tr);
    lines.add('total_score_label'.tr.replaceAll('{score}', totalScore.toString()));
    lines.add('');
    
    for (int i = 0; i < players.length; i++) {
      final player = players[i];
      lines.add('player_score_line'.tr.replaceAll('{rank}', (i + 1).toString()).replaceAll('{player}', player.name).replaceAll('{score}', player.score.toString()));
    }
    
    return lines.join('\n');
  }

  // 保存游戏数据
  Future<void> _saveGameData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 保存玩家数据
      final playersData = players.map((p) => p.toJson()).toList();
      await prefs.setString('custom_score_players', jsonEncode(playersData));
    } catch (e) {
      print('save_custom_score_data_failed'.tr + ': $e');
    }
  }

  // 加载游戏数据
  Future<void> _loadGameData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 加载玩家数据
      final playersString = prefs.getString('custom_score_players');
      if (playersString != null && playersString.isNotEmpty) {
        try {
          final playersData = jsonDecode(playersString) as List;
          players.clear();
          for (var data in playersData) {
            players.add(CustomPlayer.fromJson(data));
          }
        } catch (e) {
          print('parse_player_data_failed'.tr + ': $e');
          _initializePlayers();
        }
      }
    } catch (e) {
      print('load_custom_score_data_failed'.tr + ': $e');
      _initializePlayers();
    }
  }
} 