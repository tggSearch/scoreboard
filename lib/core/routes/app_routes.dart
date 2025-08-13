import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../pages/main_tab_page.dart';
import '../../business/score_tracker/controller/basketball_controller.dart';
import '../../business/history_viewer/view/history_viewer_page.dart';
import '../../business/history_viewer/controller/history_viewer_controller.dart';
import '../../business/game_utils/controller/game_utils_controller.dart';
import '../../business/user_profile/view/user_profile_page.dart';
import '../../business/user_profile/controller/user_profile_controller.dart';
import '../../business/score_tracker/view/basketball_page.dart';
import '../../business/score_tracker/view/basketball_history_page.dart';
import '../../business/game_utils/view/game_utils_page.dart';
import '../../business/score_tracker/view/football_page.dart';
import '../../business/score_tracker/controller/football_controller.dart';
import '../../business/score_tracker/view/football_history_page.dart';
import '../../business/score_tracker/view/mahjong_page.dart';
import '../../business/score_tracker/controller/mahjong_controller.dart';
import '../../business/score_tracker/view/mahjong_history_page.dart';
import '../../business/score_tracker/view/doudizhu_page.dart';
import '../../business/score_tracker/view/doudizhu_history_page.dart';
import '../../business/score_tracker/view/racket_sport_page.dart';
import '../../business/score_tracker/controller/racket_sport_controller.dart';
import '../../business/score_tracker/view/racket_sport_history_page.dart';
import '../../business/score_tracker/view/tennis_page.dart';
import '../../business/score_tracker/controller/tennis_controller.dart';
import '../../business/score_tracker/view/tennis_history_page.dart';
import '../../business/score_tracker/view/texas_holdem_page.dart';
import '../../business/score_tracker/controller/texas_holdem_controller.dart';
import '../../business/score_tracker/view/texas_holdem_history_page.dart';
import '../../business/score_tracker/view/uno_page.dart';
import '../../business/score_tracker/controller/uno_controller.dart';
import '../../business/score_tracker/view/uno_history_page.dart';
import '../../business/score_tracker/view/bridge_page.dart';
import '../../business/score_tracker/controller/bridge_controller.dart';
import '../../business/score_tracker/view/bridge_history_page.dart';
import '../../business/score_tracker/view/custom_score_page.dart';
import '../../business/score_tracker/controller/custom_score_controller.dart';
import '../../business/score_tracker/view/custom_score_history_page.dart';
import '../../pages/language_settings_page.dart';
import '../../pages/test_language_page.dart';
import '../../pages/translation_debug_page.dart';
import '../../pages/language_test_page.dart';
import '../../pages/splash_page.dart';

class AppRoutes {
  // Main routes
  static const String splash = '/splash';
  static const String mainTab = '/main-tab';
  static const String scoreTracker = '/score-tracker';
  static const String basketball = '/basketball';
  static const String basketballHistory = '/basketball-history';
  static const String historyViewer = '/history-viewer';
  static const String userProfile = '/user-profile';
  static const String home = '/home';
  static const String football = '/football';
  static const String footballHistory = '/football-history';
  static const String mahjong = '/mahjong';
  static const String mahjongHistory = '/mahjong-history';
  static const String doudizhu = '/doudizhu';
  static const String doudizhuHistory = '/doudizhu-history';
  static const String badminton = '/badminton';
  static const String badmintonHistory = '/badminton-history';
  static const String pingpong = '/pingpong';
  static const String pingpongHistory = '/pingpong-history';
  static const String volleyball = '/volleyball';
  static const String volleyballHistory = '/volleyball-history';
  static const String tennis = '/tennis';
  static const String tennisHistory = '/tennis-history';
  static const String texasHoldem = '/texas-holdem';
  static const String texasHoldemHistory = '/texas-holdem-history';
  static const String uno = '/uno';
  static const String unoHistory = '/uno-history';
  static const String bridge = '/bridge';
  static const String bridgeHistory = '/bridge-history';
  static const String customScore = '/custom-score';
  static const String customScoreHistory = '/custom-score-history';

  // Score tracker routes
  static const String newGame = '/new-game';
  static const String gameDetail = '/game-detail';

  // History viewer routes
  static const String historyDetail = '/history-detail';

  // User profile routes
  static const String settings = '/settings';
  static const String about = '/about';
  static const String languageSettings = '/language-settings';
  static const String testLanguage = '/test-language';
  static const String translationDebug = '/translation-debug';
  static const String languageTest = '/language-test';

  /// Get all routes
  static List<GetPage> get routes => [
        // Splash page
        GetPage(
          name: splash,
          page: () => const SplashPage(),
        ),

        // Main tab page
        GetPage(
          name: mainTab,
          page: () => const MainTabPage(),
          binding: MainTabBinding(),
        ),

        // Home page
        GetPage(
          name: home,
          page: () => const MainTabPage(),
          binding: MainTabBinding(),
        ),

        // Score tracker routes
        GetPage(
          name: newGame,
          page: () => const NewGamePage(),
          binding: NewGameBinding(),
        ),
        GetPage(
          name: gameDetail,
          page: () => const GameDetailPage(),
          binding: GameDetailBinding(),
        ),
        GetPage(
          name: basketball,
          page: () => const BasketballPage(),
          binding: BasketballBinding(),
        ),
        GetPage(
          name: basketballHistory,
          page: () => const BasketballHistoryPage(),
          binding: BasketballBinding(),
        ),
        GetPage(
          name: football,
          page: () => FootballPage(),
          binding: FootballBinding(),
        ),
        GetPage(
          name: footballHistory,
          page: () => const FootballHistoryPage(),
          binding: FootballBinding(),
        ),
        GetPage(
          name: mahjong,
          page: () => const MahjongPage(),
          binding: MahjongBinding(),
        ),
        GetPage(
          name: mahjongHistory,
          page: () => const MahjongHistoryPage(),
          binding: MahjongBinding(),
        ),
        GetPage(
          name: doudizhu,
          page: () => const DoudizhuPage(),
          binding: DoudizhuBinding(),
        ),
        GetPage(
          name: doudizhuHistory,
          page: () => const DoudizhuHistoryPage(),
          binding: DoudizhuBinding(),
        ),
        GetPage(
          name: badminton,
          page: () => const RacketSportPage(),
          binding: BadmintonBinding(),
        ),
        GetPage(
          name: badmintonHistory,
          page: () => const RacketSportHistoryPage(),
          binding: BadmintonBinding(),
        ),
        GetPage(
          name: pingpong,
          page: () => const RacketSportPage(),
          binding: PingpongBinding(),
        ),
        GetPage(
          name: pingpongHistory,
          page: () => const RacketSportHistoryPage(),
          binding: PingpongBinding(),
        ),
        GetPage(
          name: volleyball,
          page: () => const RacketSportPage(),
          binding: VolleyballBinding(),
        ),
        GetPage(
          name: volleyballHistory,
          page: () => const RacketSportHistoryPage(),
          binding: VolleyballBinding(),
        ),
        GetPage(
          name: tennis,
          page: () => const TennisPage(),
          binding: TennisBinding(),
        ),
        GetPage(
          name: tennisHistory,
          page: () => const TennisHistoryPage(),
          binding: TennisBinding(),
        ),
        GetPage(
          name: texasHoldem,
          page: () => const TexasHoldemPage(),
          binding: TexasHoldemBinding(),
        ),
        GetPage(
          name: texasHoldemHistory,
          page: () => const TexasHoldemHistoryPage(),
          binding: TexasHoldemBinding(),
        ),
        GetPage(
          name: uno,
          page: () => const UnoPage(),
          binding: UnoBinding(),
        ),
            GetPage(
      name: unoHistory,
      page: () => const UnoHistoryPage(),
      binding: UnoBinding(),
    ),
    GetPage(
      name: bridge,
      page: () => const BridgePage(),
      binding: BridgeBinding(),
    ),
    GetPage(
      name: bridgeHistory,
      page: () => const BridgeHistoryPage(),
      binding: BridgeBinding(),
    ),
    GetPage(
      name: customScore,
      page: () => const CustomScorePage(),
      binding: CustomScoreBinding(),
    ),
    GetPage(
      name: customScoreHistory,
      page: () => const CustomScoreHistoryPage(),
      binding: CustomScoreBinding(),
    ),

        // History viewer routes
        GetPage(
          name: historyViewer,
          page: () => const HistoryViewerPage(),
          binding: HistoryViewerBinding(),
        ),
        GetPage(
          name: historyDetail,
          page: () => const HistoryDetailPage(),
          binding: HistoryDetailBinding(),
        ),

        // User profile routes
        GetPage(
          name: userProfile,
          page: () => const UserProfilePage(),
          binding: UserProfileBinding(),
        ),
        GetPage(
          name: settings,
          page: () => const SettingsPage(),
          binding: SettingsBinding(),
        ),
        GetPage(
          name: about,
          page: () => const AboutPage(),
          binding: AboutBinding(),
        ),
        
        // Language settings route
        GetPage(
          name: languageSettings,
          page: () => const LanguageSettingsPage(),
        ),
        
        // Test language route
        GetPage(
          name: testLanguage,
          page: () => const TestLanguagePage(),
        ),
        
        // Translation debug route
        GetPage(
          name: translationDebug,
          page: () => const TranslationDebugPage(),
        ),
        
        // Language test route
        GetPage(
          name: languageTest,
          page: () => const LanguageTestPage(),
        ),
      ];
}

// Bindings
class MainTabBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainTabController());
    Get.put(HistoryViewerController());
    Get.put(GameUtilsController());
    Get.put(UserProfileController());
  }
}

class NewGameBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: Implement
  }
}

class GameDetailBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: Implement
  }
}

class BasketballBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BasketballController());
  }
}

class FootballBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FootballController());
  }
}

class MahjongBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MahjongController(gameType: 'mahjong'));
  }
}

class DoudizhuBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MahjongController(gameType: 'doudizhu'));
  }
}

class BadmintonBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RacketSportController('badminton'));
  }
}

class PingpongBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RacketSportController('pingpong'));
  }
}

class VolleyballBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RacketSportController('volleyball'));
  }
}

class TennisBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TennisController());
  }
}

class TexasHoldemBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TexasHoldemController());
  }
}

class UnoBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(UnoController());
  }
}

class BridgeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BridgeController());
  }
}

class CustomScoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CustomScoreController());
  }
}

class HistoryViewerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HistoryViewerController());
  }
}

class HistoryDetailBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: Implement
  }
}

class UserProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(UserProfileController());
  }
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: Implement
  }
}

class AboutBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: Implement
  }
}

// Placeholder pages
class NewGamePage extends StatelessWidget {
  const NewGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('New Game Page')),
    );
  }
}

class GameDetailPage extends StatelessWidget {
  const GameDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Game Detail Page')),
    );
  }
}

class HistoryDetailPage extends StatelessWidget {
  const HistoryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('History Detail Page')),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Settings Page')),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('About Page')),
    );
  }
} 