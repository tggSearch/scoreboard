class GameModel {
  final String id;
  final String gameType;
  final String team1Name;
  final String team2Name;
  final int team1Score;
  final int team2Score;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  GameModel({
    required this.id,
    required this.gameType,
    required this.team1Name,
    required this.team2Name,
    this.team1Score = 0,
    this.team2Score = 0,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] ?? '',
      gameType: json['gameType'] ?? '',
      team1Name: json['team1Name'] ?? '',
      team2Name: json['team2Name'] ?? '',
      team1Score: json['team1Score'] ?? 0,
      team2Score: json['team2Score'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameType': gameType,
      'team1Name': team1Name,
      'team2Name': team2Name,
      'team1Score': team1Score,
      'team2Score': team2Score,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  GameModel copyWith({
    String? id,
    String? gameType,
    String? team1Name,
    String? team2Name,
    int? team1Score,
    int? team2Score,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return GameModel(
      id: id ?? this.id,
      gameType: gameType ?? this.gameType,
      team1Name: team1Name ?? this.team1Name,
      team2Name: team2Name ?? this.team2Name,
      team1Score: team1Score ?? this.team1Score,
      team2Score: team2Score ?? this.team2Score,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Get score increment based on game type
  int getScoreIncrement() {
    switch (gameType.toLowerCase()) {
      case 'basketball':
        return 2;
      case 'football':
      case 'soccer':
        return 1;
      case 'tennis':
        return 15;
      case 'volleyball':
        return 1;
      case 'pingpong':
      case 'tabletennis':
        return 1;
      default:
        return 1;
    }
  }

  /// Get winner team name
  String? getWinner() {
    if (team1Score > team2Score) {
      return team1Name;
    } else if (team2Score > team1Score) {
      return team2Name;
    }
    return null; // Draw
  }

  /// Check if game is finished
  bool get isFinished => !isActive;

  /// Get total score
  int get totalScore => team1Score + team2Score;
} 