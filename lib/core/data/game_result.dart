class GameResult {
  final String id;
  final String gameType; // 比赛类型：basketball, football, etc.
  final String team1Name;
  final String team2Name;
  final int team1Score;
  final int team2Score;
  final DateTime startTime;
  final DateTime endTime;
  final int duration; // 比赛时长（秒）
  final Map<String, dynamic> additionalData; // 额外数据，如半场信息等

  GameResult({
    required this.id,
    required this.gameType,
    required this.team1Name,
    required this.team2Name,
    required this.team1Score,
    required this.team2Score,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.additionalData = const {},
  });

  // 转换为Map用于存储
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gameType': gameType,
      'team1Name': team1Name,
      'team2Name': team2Name,
      'team1Score': team1Score,
      'team2Score': team2Score,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'duration': duration,
      'additionalData': additionalData,
    };
  }

  // 从Map创建实例
  factory GameResult.fromMap(Map<String, dynamic> map) {
    return GameResult(
      id: map['id'],
      gameType: map['gameType'],
      team1Name: map['team1Name'],
      team2Name: map['team2Name'],
      team1Score: map['team1Score'],
      team2Score: map['team2Score'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
      duration: map['duration'],
      additionalData: Map<String, dynamic>.from(map['additionalData'] ?? {}),
    );
  }

  // 获取获胜队伍
  String? get winner {
    if (team1Score > team2Score) return team1Name;
    if (team2Score > team1Score) return team2Name;
    return null; // 平局
  }

  // 获取比分差
  int get scoreDifference => (team1Score - team2Score).abs();

  // 格式化比赛时长
  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;
    
    if (hours > 0) {
      return '${hours}小时${minutes}分${seconds}秒';
    } else if (minutes > 0) {
      return '${minutes}分${seconds}秒';
    } else {
      return '${seconds}秒';
    }
  }

  // 格式化开始时间
  String get formattedStartTime {
    return '${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')} '
           '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  // 格式化结束时间
  String get formattedEndTime {
    return '${endTime.year}-${endTime.month.toString().padLeft(2, '0')}-${endTime.day.toString().padLeft(2, '0')} '
           '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }
} 