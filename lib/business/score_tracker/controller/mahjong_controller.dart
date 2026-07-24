import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/data/game_result.dart';
import '../../../core/utils/game_result_manager.dart';
import '../../../core/utils/mahjong_config.dart';
import 'package:common_ui/common_ui.dart';
import '../../../core/theme/app_colors.dart';

class MahjongController extends BaseController {
  // 游戏类型
  final String gameType;
  
  MahjongController({this.gameType = 'mahjong'});
  
  // 玩家信息
  final RxList<String> playerNames = <String>['player_1', 'player_2', 'player_3', 'player_4'].obs;
  final RxList<int> playerScores = <int>[0, 0, 0, 0].obs;
  
  // 胡牌记录
  final RxList<MahjongRecord> records = <MahjongRecord>[].obs;
  
  // 当前选中的玩家
  final RxInt selectedPlayer = 0.obs;
  
  // 基础分值
  final RxInt baseScore = 1.obs;
  
  // 斗地主相关
  final RxInt currentMultiplier = 1.obs;
  final RxInt landlordPlayer = 0.obs;
  
  // 语音播报
  final VoiceAnnouncer voiceAnnouncer = VoiceAnnouncer();
  
  // 当前选择的胡牌类型和番数
  final RxString selectedWinType = 'ping_hu'.obs;
  final RxInt selectedFans = 1.obs;
  final RxInt selectedZhuama = 0.obs;
  
  // 番数选项
  final List<int> fanOptions = [1, 2, 3, 4, 5, 6, 8, 10, 12, 16, 24, 32, 48, 64, 88];
  
  // 默认番数配置 - 自摸
  final Map<String, int> defaultFansSelfDraw = {
    'ping_hu': 1,
    'peng_peng_hu': 2,
    'qing_yi_se': 6,
    'hun_yi_se': 4,
    'qi_dui': 4,
    'haohua_qi_dui': 8,
    'xiao_san_yuan': 6,
    'da_san_yuan': 88,
    'xiao_si_xi': 64,
    'da_si_xi': 88,
    'zi_yi_se': 88,
    'qing_long': 2,
    'san_an_ke': 2,
    'hun_peng': 3,
    'men_qing_zi_mo': 2,
    'gang_shang_hua': 1,
    'qiang_gang': 1,
    'hai_di_lao_yue': 1,
    'tian_hu': 88,
    'di_hu': 88,
  };
  
  // 默认番数配置 - 点炮
  final Map<String, int> defaultFansPointPao = {
    'ping_hu': 1,
    'peng_peng_hu': 2,
    'qing_yi_se': 6,
    'hun_yi_se': 4,
    'qi_dui': 4,
    'haohua_qi_dui': 8,
    'xiao_san_yuan': 6,
    'da_san_yuan': 88,
    'xiao_si_xi': 64,
    'da_si_xi': 88,
    'zi_yi_se': 88,
    'qing_long': 2,
    'san_an_ke': 2,
    'hun_peng': 3,
    'men_qing_zi_mo': 2,
    'gang_shang_hua': 1,
    'qiang_gang': 1,
    'hai_di_lao_yue': 1,
    'tian_hu': 88,
    'di_hu': 88,
  };
  
  // 默认杠的番数配置
  final Map<String, int> defaultGangFans = {
    'ming_gang': 1,
    'an_gang': 2,
    'dian_gang': 1,
  };
  
  // 获取指定胡牌类型的番数（自摸）
  Future<int> getFansForWinTypeSelfDraw(String winType) async {
    return defaultFansSelfDraw[winType] ?? 1;
  }
  
  // 获取指定胡牌类型的番数（点炮）
  Future<int> getFansForWinTypePointPao(String winType) async {
    return defaultFansPointPao[winType] ?? 1;
  }
  
  // 更新指定胡牌类型的番数（自摸）
  Future<void> updateFansForWinTypeSelfDraw(String winType, int fans) async {
    defaultFansSelfDraw[winType] = fans;
    // 立即保存到本地
    await MahjongConfig.saveCustomFansSelfDraw(defaultFansSelfDraw);
  }
  
  // 更新指定胡牌类型的番数（点炮）
  Future<void> updateFansForWinTypePointPao(String winType, int fans) async {
    defaultFansPointPao[winType] = fans;
    // 立即保存到本地
    await MahjongConfig.saveCustomFansPointPao(defaultFansPointPao);
  }
  
  // 更新指定杠类型的番数
  Future<void> updateFansForGangType(String gangType, int fans) async {
    defaultGangFans[gangType] = fans;
    // 立即保存到本地
    await MahjongConfig.saveCustomGangFans(defaultGangFans);
  }
  
  // 获取指定杠类型的番数
  int getFansForGangType(String gangType) {
    return defaultGangFans[gangType] ?? 1;
  }
  
  // 更新选择的胡牌类型
  Future<void> updateSelectedWinType(String winType) async {
    selectedWinType.value = winType;
    // 自动更新对应的番数（默认使用自摸番数）
    final fans = await getFansForWinTypeSelfDraw(selectedWinType.value);
    selectedFans.value = fans;
  }

  // 兼容旧方法名
  Future<int> getFansForWinType(String winType) async {
    return await getFansForWinTypeSelfDraw(winType);
  }

  // 兼容旧方法名
  Future<void> updateFansForWinType(String winType, int fans) async {
    await updateFansForWinTypeSelfDraw(winType, fans);
  }
  
  // 更新选择的番数
  void updateSelectedFans(int fans) {
    selectedFans.value = fans;
  }
  
  // 更新选择的抓码番数
  void updateSelectedZhuama(int zhuama) {
    selectedZhuama.value = zhuama;
  }
  
  // 胡牌类型
  final List<String> winTypes = [
    'ping_hu',
    'peng_peng_hu',
    'qing_yi_se',
    'hun_yi_se',
    'qi_dui',
    'haohua_qi_dui',
    'xiao_san_yuan',
    'da_san_yuan',
    'xiao_si_xi',
    'da_si_xi',
    'zi_yi_se',
    'qing_long',
    'san_an_ke',
    'hun_peng',
    'men_qing_zi_mo',
    'gang_shang_hua',
    'qiang_gang',
    'hai_di_lao_yue',
    'tian_hu',
    'di_hu',
  ];
  
  // 杠的类型
  final List<String> gangTypes = [
    'ming_gang',
    'an_gang',
    'dian_gang',
  ];

  @override
  void onInit() {
    super.onInit();
    // 初始化玩家名称
    _loadPlayerNames();
    // 初始化胡牌类型和番数
    _loadWinTypeAndFans();
    // 加载番数配置
    _loadFansConfig();
    // 加载基础分
    _loadBaseScore();
    // 监听基础分变化，自动保存
    ever(baseScore, (int value) {
      _saveBaseScore(value);
    });
  }
  
  @override
  void onReady() {
    super.onReady();
    // 确保在页面准备好后加载玩家名称
    _loadPlayerNames();
  }

  // 加载玩家名称和分数
  Future<void> _loadPlayerNames() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (int i = 0; i < playerNames.length; i++) {
        // 加载玩家名称
        final savedName = prefs.getString('mahjong_player_name_$i');
        if (savedName != null && savedName.isNotEmpty) {
          playerNames[i] = savedName;
        }
        
        // 加载玩家分数
        final savedScore = prefs.getInt('mahjong_player_score_$i');
        if (savedScore != null) {
          playerScores[i] = savedScore;
        }
      }
    } catch (e) {
      print('加载玩家数据失败: $e');
    }
  }

  // 加载胡牌类型和番数
  Future<void> _loadWinTypeAndFans() async {
    try {
      // 设置默认胡牌类型
      selectedWinType.value = winTypes[0];
      // 加载对应的番数
      final fans = await getFansForWinType(selectedWinType.value);
      selectedFans.value = fans;
    } catch (e) {
      print('加载胡牌类型和番数失败: $e');
    }
  }

  // 加载番数配置
  Future<void> _loadFansConfig() async {
    try {
      // 加载自摸番数配置
      final selfDrawFans = await MahjongConfig.getCustomFansSelfDraw();
      if (selfDrawFans.isNotEmpty) {
        defaultFansSelfDraw.addAll(selfDrawFans);
      }
      
      // 加载点炮番数配置
      final pointPaoFans = await MahjongConfig.getCustomFansPointPao();
      if (pointPaoFans.isNotEmpty) {
        defaultFansPointPao.addAll(pointPaoFans);
      }
      
      // 加载杠的番数配置
      final gangFans = await MahjongConfig.getCustomGangFans();
      if (gangFans.isNotEmpty) {
        defaultGangFans.addAll(gangFans);
      }
    } catch (e) {
      print('加载番数配置失败: $e');
    }
  }

  // 设置玩家名称
  Future<void> setPlayerName(int playerIndex, String name) async {
    if (playerIndex >= 0 && playerIndex < playerNames.length) {
      playerNames[playerIndex] = name;
      
      // 保存到本地存储
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('mahjong_player_name_$playerIndex', name);
      } catch (e) {
        print('保存玩家名称失败: $e');
      }
    }
  }
  
  // 保存所有玩家分数
  Future<void> _saveAllScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (int i = 0; i < playerScores.length; i++) {
        await prefs.setInt('mahjong_player_score_$i', playerScores[i]);
      }
    } catch (e) {
      print('保存玩家分数失败: $e');
    }
  }

  // 选择玩家
  void selectPlayer(int playerIndex) {
    selectedPlayer.value = playerIndex;
  }

  // 设置基础分值
  void setBaseScore(String scoreText) {
    final score = int.tryParse(scoreText);
    if (score != null && score > 0) {
      baseScore.value = score;
      // 保存到本地（ever 监听器会自动保存，但这里也可以显式保存）
      _saveBaseScore(score);
    }
  }
  
  // 加载基础分
  Future<void> _loadBaseScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBaseScore = prefs.getInt('mahjong_base_score');
      if (savedBaseScore != null && savedBaseScore > 0) {
        baseScore.value = savedBaseScore;
      }
    } catch (e) {
      print('加载基础分失败: $e');
    }
  }
  
  // 保存基础分
  Future<void> _saveBaseScore(int score) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('mahjong_base_score', score);
    } catch (e) {
      print('保存基础分失败: $e');
    }
  }
  
  // 设置倍数
  void setMultiplier(int multiplier) {
    currentMultiplier.value = multiplier;
  }
  
  // 选择地主
  void selectLandlord(int playerIndex) {
    landlordPlayer.value = playerIndex;
  }
  
  // 记录游戏结果
  void recordGameResult(bool landlordWins) {
    final baseScoreValue = baseScore.value;
    final multiplierValue = currentMultiplier.value;
    final landlordScore = baseScoreValue * multiplierValue * 2; // 地主分数 = 基础分 × 倍数 × 2
    final farmerScore = baseScoreValue * multiplierValue; // 农民分数 = 基础分 × 倍数 × 1
    final landlordIndex = landlordPlayer.value;
    final landlordName = playerNames[landlordIndex];
    
    if (landlordWins) {
      // 地主赢，地主获得分数，农民失去分数
      playerScores[landlordIndex] += landlordScore;
      _addRecord(landlordIndex, landlordScore, '地主获胜: ${landlordScore}分');
      
      for (int i = 0; i < 3; i++) {
        if (i != landlordIndex) {
          playerScores[i] -= farmerScore;
          _addRecord(i, -farmerScore, '农民失败: -${farmerScore}分');
        }
      }
    } else {
      // 农民赢，地主失去分数，农民获得分数
      playerScores[landlordIndex] -= landlordScore;
      _addRecord(landlordIndex, -landlordScore, '地主失败: -${landlordScore}分');
      
      for (int i = 0; i < 3; i++) {
        if (i != landlordIndex) {
          playerScores[i] += farmerScore;
          _addRecord(i, farmerScore, '农民获胜: ${farmerScore}分');
        }
      }
    }
    
    // 保存分数
    _saveAllScores();
    
    // 延迟播报所有玩家的最终分数，确保弹窗已完全关闭
    Future.delayed(const Duration(milliseconds: 300), () {
      final Map<String, int> finalScores = {};
      for (int i = 0; i < playerNames.length; i++) {
        finalScores[playerNames[i]] = playerScores[i];
      }
      
      // 构建播报文本：xxx 地主获胜/农民获胜，最终分数 xxx 是：-64分 xxa是 -32分，xxb是 32分 xxc是 64分
      String announcement = '';
      if (landlordWins) {
        announcement = '$landlordName${'landlord_wins'.tr}';
      } else {
        announcement = '${'farmers_win'.tr}';
      }
      announcement += '${'comma_separator'.tr}${'final_scores'.tr}';
      final List<String> scoreParts = [];
      finalScores.forEach((playerName, score) {
        final scoreText = score >= 0 ? '$score' : '${'negative_prefix'.tr}${score.abs()}';
        scoreParts.add('$playerName${'is'.tr}$scoreText${'points_unit'.tr}');
      });
      announcement += scoreParts.join('comma_separator'.tr);
      voiceAnnouncer.announce(announcement);
    });
  }

  // 胡牌 - 自摸
  Future<void> winGameSelfDraw(int winnerIndex, int fans, int zhuama, String winType) async {
    if (winnerIndex >= 0 && winnerIndex < playerScores.length) {
      final totalFans = fans + zhuama;
      final loseScore = baseScore.value * totalFans; // 每个人扣分
      final winScore = loseScore * 3; // 胡牌者得分 = 扣分 × 3人
      
      // 胡牌者加分
      playerScores[winnerIndex] += winScore;
      
      // 其他玩家减分
      for (int i = 0; i < playerScores.length; i++) {
        if (i != winnerIndex) {
          playerScores[i] -= loseScore;
        }
      }
      
      String description = 'self_draw_description'.tr.replaceAll('{win_type}', winType).replaceAll('{fans}', fans.toString()).replaceAll('{zhuama_text}', zhuama > 0 ? ' + 抓码${zhuama}番' : '');
      _addRecord(winnerIndex, winScore, description);
      
      // 为其他玩家添加扣分记录
      for (int i = 0; i < playerScores.length; i++) {
        if (i != winnerIndex) {
          _addRecord(i, -loseScore, 'be_self_draw_description'.tr.replaceAll('{win_type}', winType).replaceAll('{total_fans}', totalFans.toString()));
        }
      }
      
      // 保存分数
      await _saveAllScores();
      
      // 语音播报 - 构建文本并播报
      String announcement = '${playerNames[winnerIndex]} ${winType.tr}';
      if (totalFans > 1) {
        announcement += ' $totalFans${'fans'.tr}';
      }
      announcement += ' ${'self_draw'.tr}';
      voiceAnnouncer.announce(announcement);
      
      // 计分完成播报
      _announceScoreSummary();
    }
  }

  // 胡牌 - 点炮
  Future<void> winGamePointPao(int winnerIndex, int loserIndex, int fans, int zhuama, String winType) async {
    if (winnerIndex >= 0 && winnerIndex < playerScores.length && 
        loserIndex >= 0 && loserIndex < playerScores.length && 
        winnerIndex != loserIndex) {
      final totalFans = fans + zhuama;
      final score = baseScore.value * totalFans;
      
      // 胡牌者加分
      playerScores[winnerIndex] += score;
      
      // 被点炮者减分
      playerScores[loserIndex] -= score;
      
      String description = 'point_pao_description'.tr.replaceAll('{win_type}', winType).replaceAll('{fans}', fans.toString()).replaceAll('{zhuama_text}', zhuama > 0 ? ' + 抓码${zhuama}番' : '');
      _addRecord(winnerIndex, score, description);
      _addRecord(loserIndex, -score, 'be_point_pao_description'.tr.replaceAll('{win_type}', winType).replaceAll('{total_fans}', totalFans.toString()));
      
      // 保存分数
      await _saveAllScores();
      
      // 语音播报 - 构建文本并播报
      String announcement = '${playerNames[winnerIndex]} ${winType.tr}';
      if (totalFans > 1) {
        announcement += ' $totalFans${'fans'.tr}';
      }
      voiceAnnouncer.announce(announcement);
      
      // 计分完成播报
      _announceScoreSummary();
    }
  }

  // 杠 - 普通杠（明杠、暗杠）
  Future<void> gang(int playerIndex, String gangType, int fans) async {
    if (playerIndex >= 0 && playerIndex < playerScores.length) {
      int baseScoreValue = baseScore.value;
      int loseScore = baseScoreValue * fans; // 每个人扣分
      int winScore = loseScore * 3; // 杠牌者得分 = 扣分 × 3人
      
      String description = '';
      
      switch (gangType) {
        case 'ming_gang':
          description = 'gang_description'.tr.replaceAll('{gang_type}', gangType).replaceAll('{score}', (fans * baseScoreValue).toString());
          break;
        case 'an_gang':
          loseScore = baseScoreValue * fans * 2; // 暗杠翻倍
          winScore = loseScore * 3;
          description = 'gang_description'.tr.replaceAll('{gang_type}', gangType).replaceAll('{score}', (fans * baseScoreValue * 2).toString());
          break;
      }
      
      // 杠牌者加分
      playerScores[playerIndex] += winScore;
      _addRecord(playerIndex, winScore, description);
      
      // 其他玩家减分
      for (int i = 0; i < playerScores.length; i++) {
        if (i != playerIndex) {
          playerScores[i] -= loseScore;
          _addRecord(i, -loseScore, 'be_gang_description'.tr.replaceAll('{gang_type}', gangType).replaceAll('{score}', loseScore.toString()));
        }
      }
      
      // 保存分数
      await _saveAllScores();
      
      // 语音播报 - 构建文本并播报
      String announcement = '${playerNames[playerIndex]} ${gangType.tr}';
      if (fans > 0) {
        announcement += ' $fans${'fans'.tr}';
      }
      voiceAnnouncer.announce(announcement);
      
      // 计分完成播报
      _announceScoreSummary();
    }
  }
  
  // 点杠 - 需要选择被点杠的人
  Future<void> gangPoint(int playerIndex, int targetIndex, int fans) async {
    if (playerIndex >= 0 && playerIndex < playerScores.length && 
        targetIndex >= 0 && targetIndex < playerScores.length && 
        playerIndex != targetIndex) {
      final loseScore = baseScore.value * fans; // 被点杠者扣分
      final winScore = loseScore; // 杠牌者得分 = 被点杠者扣分
      
      // 杠牌者加分
      playerScores[playerIndex] += winScore;
      
      // 被点杠者减分
      playerScores[targetIndex] -= loseScore;
      
      String description = 'gang_point_description'.tr.replaceAll('{score}', winScore.toString());
      _addRecord(playerIndex, winScore, description);
      _addRecord(targetIndex, -loseScore, 'be_gang_point_description'.tr.replaceAll('{score}', loseScore.toString()));
      
      // 保存分数
      await _saveAllScores();
      
      // 语音播报 - 构建文本并播报
      String announcement = '${playerNames[playerIndex]} ${'dian_gang'.tr}';
      if (fans > 0) {
        announcement += ' $fans${'fans'.tr}';
      }
      voiceAnnouncer.announce(announcement);
      
      // 计分完成播报
      _announceScoreSummary();
    }
  }

  // 添加记录
  void _addRecord(int playerIndex, int score, String description, {Map<String, int>? scoreChanges}) {
    final record = MahjongRecord(
      playerIndex: playerIndex,
      playerName: playerNames[playerIndex],
      score: score,
      description: description,
      timestamp: DateTime.now(),
      scoresAtTime: List.from(playerScores), // 记录当前所有人的分数
      scoreChanges: scoreChanges ?? {}, // 使用传入的分数变化或空Map
    );
    records.add(record);
    
    // 限制记录数量，保留最近200条
    if (records.length > 200) {
      records.removeAt(0);
    }
  }

  // 获取统计信息
  Map<String, dynamic> getStatistics() {
    final stats = <String, dynamic>{};
    
    // 每个玩家的统计
    for (int i = 0; i < playerNames.length; i++) {
      final playerRecords = records.where((r) => r.playerIndex == i).toList();
      final totalScore = playerRecords.fold(0, (sum, r) => sum + r.score);
      final winCount = playerRecords.where((r) => r.description.contains('win'.tr) || r.description.contains('self_draw'.tr) || r.description.contains('point_pao'.tr)).length;
      final gangCount = playerRecords.where((r) => r.description.contains('gang'.tr)).length;
      
      stats[playerNames[i]] = {
        'totalScore': totalScore,
        'winCount': winCount,
        'gangCount': gangCount,
        'recordCount': playerRecords.length,
      };
    }
    
    return stats;
  }

  // 获取游戏总结
  String getGameSummary() {
    final stats = getStatistics();
    final totalRecords = records.length;
    final totalWins = records.where((r) => r.description.contains('win'.tr) || r.description.contains('self_draw'.tr) || r.description.contains('point_pao'.tr)).length;
    final totalGangs = records.where((r) => r.description.contains('gang'.tr)).length;
    
    return '${'history_records'.tr}: $totalRecords${'record_number'.tr.replaceAll('{number}', '')} | ${'win_game'.tr}: $totalWins${'times'.tr} | ${'gang'.tr}: $totalGangs${'times'.tr}';
  }

  // 获取玩家排名
  List<int> getPlayerRanking() {
    final List<MapEntry<int, int>> playerScoreList = [];
    for (int i = 0; i < playerScores.length; i++) {
      playerScoreList.add(MapEntry(i, playerScores[i]));
    }
    
    playerScoreList.sort((a, b) => b.value.compareTo(a.value));
    return playerScoreList.map((e) => e.key).toList();
  }

  // 获取玩家排名文本
  String getPlayerRankingText(int playerIndex) {
    final ranking = getPlayerRanking();
    final rank = ranking.indexOf(playerIndex) + 1;
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      case 4:
        return '4️⃣';
      default:
        return '$rank';
    }
  }

  // 手动修改分数
  Future<void> setPlayerScore(int playerIndex, int newScore) async {
    if (playerIndex >= 0 && playerIndex < playerScores.length) {
      final oldScore = playerScores[playerIndex];
      final scoreChange = newScore - oldScore;
      
      // 更新分数
      playerScores[playerIndex] = newScore;
      
      // 添加历史记录
      String description = 'manual_modify_description'.tr.replaceAll('{old_score}', oldScore.toString()).replaceAll('{new_score}', newScore.toString());
      if (scoreChange > 0) {
        description = 'manual_add_score_description'.tr.replaceAll('{change}', scoreChange.toString());
      } else if (scoreChange < 0) {
        description = 'manual_subtract_score_description'.tr.replaceAll('{change}', scoreChange.toString());
      }
      
      _addRecord(playerIndex, scoreChange, description);
      
      // 保存分数
      await _saveAllScores();
      
      // 语音播报
      if (scoreChange > 0) {
        voiceAnnouncer.announce('manual_score_announce'.tr.replaceAll('{player}', playerNames[playerIndex]).replaceAll('{operation}', 'manual_score_add'.tr).replaceAll('{score}', scoreChange.toString()));
      } else if (scoreChange < 0) {
        voiceAnnouncer.announce('manual_score_announce'.tr.replaceAll('{player}', playerNames[playerIndex]).replaceAll('{operation}', 'manual_score_subtract'.tr).replaceAll('{score}', (-scoreChange).toString()));
      }
      
      // 计分完成播报
      _announceScoreSummary();
    }
  }

  // 重置所有分数（保留玩家名字和记录）
  Future<void> resetAllScores({bool resetConfig = false}) async {
    for (int i = 0; i < playerScores.length; i++) {
      playerScores[i] = 0;
    }
    // 不清空记录，保留历史
    // records.clear();
    
    // 如果重置配置，恢复所有配置为默认值（包括基础分和番数）
    if (resetConfig) {
      // 重置基础分为默认值 1
      baseScore.value = 1;
      await _saveBaseScore(1);
      
      // 重置配置为默认值（番数配置）
      await MahjongConfig.resetAllConfig();
      // 重新加载配置
      await _loadFansConfig();
    }
    // 如果不重置配置，则保留基础分和番数配置不变
    
    // 保存重置后的分数
    await _saveAllScores();
    
    // 语音播报
    voiceAnnouncer.announce('game_reset_announce'.tr);
  }
  
  // 计分完成播报
  void _announceScoreSummary() {
    // 延迟一秒播报，让前面的播报先完成
    Future.delayed(const Duration(seconds: 1), () {
      final rankings = getPlayerRanking();
      String summary = 'current_ranking'.tr;
      
      for (int i = 0; i < rankings.length; i++) {
        final playerIndex = rankings[i];
        final playerName = playerNames[playerIndex];
        final score = playerScores[playerIndex];
        summary += 'ranking_summary'.tr.replaceAll('{rank}', (i + 1).toString()).replaceAll('{player}', playerName).replaceAll('{score_text}', '${score >= 0 ? '+' : ''}$score${'points_unit'.tr}');
        if (i < rankings.length - 1) {
          summary += 'comma_separator'.tr;
        }
      }
      
      voiceAnnouncer.announce(summary);
    });
  }

  // 保存游戏结果
  Future<void> saveGameResult() async {
    final gameResult = GameResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gameType: 'mahjong',
      team1Name: playerNames[0],
      team2Name: playerNames[1],
      team1Score: playerScores[0],
      team2Score: playerScores[1],
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      duration: 0, // 麻将游戏通常不计时
      additionalData: {
        'player3Name': playerNames[2],
        'player4Name': playerNames[3],
        'player3Score': playerScores[2],
        'player4Score': playerScores[3],
        'records': records.map((record) => {
          'playerIndex': record.playerIndex,
          'playerName': record.playerName,
          'score': record.score,
          'description': record.description,
          'timestamp': record.timestamp.millisecondsSinceEpoch,
        }).toList(),
      },
    );

    await GameResultManager.saveGameResult(gameResult);
    
    Get.snackbar(
      'fans_config_save_success'.tr,
      '游戏结果已保存',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // 获取总分
  int get totalScore {
    return playerScores.fold(0, (sum, score) => sum + score);
  }

  // 获取最高分玩家
  String get leadingPlayer {
    final ranking = getPlayerRanking();
    if (ranking.isNotEmpty) {
      return playerNames[ranking.first];
    }
    return '无';
  }

  // 获取最高分
  int get highestScore {
    if (playerScores.isEmpty) return 0;
    return playerScores.reduce((a, b) => a > b ? a : b);
  }
  
  // 校验总分是否为0
  bool get isTotalScoreZero {
    return totalScore == 0;
  }
  
  // 获取总分校验信息
  String get totalScoreValidation {
    final total = totalScore;
    if (total == 0) {
      return '✅ 总分正确: $total';
    } else {
      return '❌ 总分错误: $total (应为0)';
    }
  }

  // 保存玩家名称
  void savePlayerNames() {
    _saveAllScores();
  }

  // 保存玩家分数
  void savePlayerScores() {
    _saveAllScores();
  }
  
  // 切换玩家位置（顺时针）
  void switchPlayerPositions() {
    final oldNames = List<String>.from(playerNames);
    final oldScores = List<int>.from(playerScores);
    
    // 切换位置：东→南→西→北→东
    final tempName = playerNames[0];
    final tempScore = playerScores[0];
    
    playerNames[0] = playerNames[1]; // 东家变为南家
    playerNames[1] = playerNames[2]; // 南家变为西家
    playerNames[2] = playerNames[3]; // 西家变为北家
    playerNames[3] = tempName;       // 北家变为东家
    
    playerScores[0] = playerScores[1];
    playerScores[1] = playerScores[2];
    playerScores[2] = playerScores[3];
    playerScores[3] = tempScore;
    
    // 添加位置切换记录
    final record = MahjongRecord(
      playerIndex: -1, // 表示全体操作
      playerName: '系统',
      score: 0,
      description: 'position_switch_all'.tr.replaceAll('{changes}', '东→南→西→北→东'),
      timestamp: DateTime.now(),
      scoresAtTime: oldScores,
      scoreChanges: {
        for (int i = 0; i < playerNames.length; i++)
          playerNames[i]: 0, // 分数不变，只是位置变化
      },
    );
    records.add(record);
    
    // 保存新的位置
    _saveAllScores();
  }

  // 灵活切换玩家位置
  void switchPlayerPositionsFlexible(Map<int, int> positionMapping) {
    final oldNames = List<String>.from(playerNames);
    final oldScores = List<int>.from(playerScores);
    
    // 创建临时数组来存储新的位置
    final newNames = List<String>.filled(4, '');
    final newScores = List<int>.filled(4, 0);
    
    // 根据映射关系重新排列玩家
    positionMapping.forEach((oldPosition, newPosition) {
      newNames[newPosition] = oldNames[oldPosition];
      newScores[newPosition] = oldScores[oldPosition];
    });
    
    // 更新玩家数组
    for (int i = 0; i < 4; i++) {
      playerNames[i] = newNames[i];
      playerScores[i] = newScores[i];
    }
    
    // 构建位置变化描述
    final List<String> changes = [];
    positionMapping.forEach((oldPos, newPos) {
      if (oldPos != newPos) {
        final directions = ['east'.tr, 'south'.tr, 'west'.tr, 'north'.tr];
        changes.add('${oldNames[oldPos]}(${directions[oldPos]})→${directions[newPos]}');
      }
    });
    
    // 添加位置切换记录
    final record = MahjongRecord(
      playerIndex: -1, // 表示全体操作
      playerName: '系统',
      score: 0,
      description: 'position_switch_all'.tr.replaceAll('{changes}', changes.join(', ')),
      timestamp: DateTime.now(),
      scoresAtTime: oldScores,
      scoreChanges: {
        for (int i = 0; i < playerNames.length; i++)
          playerNames[i]: 0, // 分数不变，只是位置变化
      },
    );
    records.add(record);
    
    // 保存新的位置
    _saveAllScores();
  }
  
  // 获取指定类型的番数
  int getFansForType(String type, String category) {
    switch (category) {
      case 'win_selfdraw':
        return defaultFansSelfDraw[type] ?? 1;
      case 'win_pointpao':
        return defaultFansPointPao[type] ?? 1;
      case 'zhuama':
        return 1; // 抓码默认1番
      case 'gang':
        return defaultGangFans[type] ?? 1;
      default:
        return 1;
    }
  }
  
  // 设置指定类型的番数
  Future<void> setFansForType(String type, String category, int fans) async {
    switch (category) {
      case 'win_selfdraw':
        defaultFansSelfDraw[type] = fans;
        // 立即保存到本地
        await MahjongConfig.saveCustomFansSelfDraw(defaultFansSelfDraw);
        break;
      case 'win_pointpao':
        defaultFansPointPao[type] = fans;
        // 立即保存到本地
        await MahjongConfig.saveCustomFansPointPao(defaultFansPointPao);
        break;
      case 'zhuama':
        // 抓码番数可以单独配置
        break;
      case 'gang':
        defaultGangFans[type] = fans;
        // 立即保存到本地
        await MahjongConfig.saveCustomGangFans(defaultGangFans);
        break;
    }
  }
  
  // 保存所有番数配置
  Future<void> saveAllFansConfig() async {
    // 保存自摸番数配置
    await MahjongConfig.saveCustomFansSelfDraw(defaultFansSelfDraw);
    // 保存点炮番数配置
    await MahjongConfig.saveCustomFansPointPao(defaultFansPointPao);
    // 保存杠的番数配置
    await MahjongConfig.saveCustomGangFans(defaultGangFans);
  }
}

// 麻将记录模型
class MahjongRecord {
  final int playerIndex;
  final String playerName;
  final int score;
  final String description;
  final DateTime timestamp;
  final List<int> scoresAtTime; // 记录计分时每个人的分数
  final Map<String, int> scoreChanges; // 记录每次的分数变化

  MahjongRecord({
    required this.playerIndex,
    required this.playerName,
    required this.score,
    required this.description,
    required this.timestamp,
    required this.scoresAtTime,
    required this.scoreChanges,
  });
} 