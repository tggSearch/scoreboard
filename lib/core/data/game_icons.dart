/// In-app game/score type icon assets (does not include app launcher icon).
abstract final class GameIcons {
  static const String _base = 'assets/icons/games';

  static String assetFor(String gameId) {
    return '$_base/$gameId.svg';
  }

  static String assetOrDefault(String gameId) {
    const supported = {
      'basketball',
      'football',
      'badminton',
      'pingpong',
      'tennis',
      'volleyball',
      'mahjong',
      'texas_holdem',
      'doudizhu',
      'bridge',
      'uno',
      'custom_score',
    };
    if (supported.contains(gameId)) {
      return assetFor(gameId);
    }
    return '$_base/default.svg';
  }
}
