import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/base/base_view.dart';
import '../core/base/base_controller.dart';
import '../business/history_viewer/view/history_viewer_page.dart';
import '../business/user_profile/view/user_profile_page.dart';
import '../core/data/score_types.dart';
import '../core/utils/most_used_manager.dart';

class MainTabController extends BaseController {
  final _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;
  set currentIndex(int value) => _currentIndex.value = value;

  final List<Widget> pages = [
    const HomePage(),
    const HistoryViewerPage(),
    const UserProfilePage(),
  ];

  @override
  void onInit() {
    super.onInit();
    isLoading = false;
    errorMessage = '';
  }

  void onTabChanged(int index) {
    currentIndex = index;
    update();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<ScoreType> _searchResults = [];
  bool _isSearching = false;
  List<String> _mostUsedGames = ['basketball', 'mahjong', 'texas_holdem'];

  @override
  void initState() {
    super.initState();
    _loadMostUsedGames();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load most used games
  Future<void> _loadMostUsedGames() async {
    final games = await MostUsedManager.getMostUsedGames();
    setState(() {
      _mostUsedGames = games;
    });
  }

  // Handle game click
  Future<void> _onGameClick(String gameId) async {
    // Record click
    await MostUsedManager.recordGameClick(gameId);
    
    // Reload most used games
    await _loadMostUsedGames();
    
    // Navigate to corresponding page
    final route = MostUsedManager.getGameRoute(gameId);
    print('Navigate to route: $route, gameId: $gameId');
    
    // Add debug info
    if (gameId == 'texas_holdem') {
      print('Texas Holdem route: $route');
    }
    if (gameId == 'mahjong') {
      print('Mahjong route: $route');
    }
    
    if (route.isNotEmpty) {
      try {
        Get.toNamed(route);
      } catch (e) {
        print('Navigation failed: $e');
        Get.snackbar('error'.tr, '${'navigation_error'.tr}: $e');
      }
    } else {
      // Optional: show tip
      Get.snackbar('tip'.tr, 'feature_not_available'.tr);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      _searchResults = ScoreTypesData.search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.dashboard, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'app_name'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'professional_score_system'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: () {
                  Get.toNamed('/user-profile');
                },
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            _buildWelcomeCard(),
            const SizedBox(height: 24),
            
            // Search section
            _buildSearchSection(context),
            const SizedBox(height: 24),
            
            // Search results or normal content
            if (_isSearching) ...[
              _buildSearchResults(context),
            ] else ...[
              // Quick start
              _buildQuickStartSection(context),
              const SizedBox(height: 24),
              
              // Popular scoring
              _buildPopularSection(context),
              const SizedBox(height: 24),
              
              // All categories
              _buildAllCategoriesSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sports_score,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'welcome_use'.tr,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'choose_sport_start_scoring'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: Row(
              children: _mostUsedGames.asMap().entries.map((entry) {
                final index = entry.key;
                final gameId = entry.value;
                return _buildStatCard(
                  MostUsedManager.getGameDisplayName(gameId),
                  MostUsedManager.getGameEmoji(gameId),
                  Color(MostUsedManager.getGameColor(gameId)),
                  () => _onGameClick(gameId),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String emoji, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
                  child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStartSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.flash_on,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'quick_start'.tr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100, // Reduced height
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              'basketball',
              'football', 
              'badminton',
              'mahjong',
              'texas_holdem',
              'pingpong',
            ].map((gameId) {
              return Container(
                width: 100, // Changed to 100, equal to height
                height: 100, // Keep 100, equal to width
                margin: const EdgeInsets.only(right: 16),
                child: InkWell(
                  onTap: () => _onGameClick(gameId),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(MostUsedManager.getGameColor(gameId)).withOpacity(0.1),
                          Color(MostUsedManager.getGameColor(gameId)).withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color(MostUsedManager.getGameColor(gameId)).withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8), // Restore original padding
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            MostUsedManager.getGameEmoji(gameId),
                            style: const TextStyle(fontSize: 20), // Restore original font size
                          ),
                        ),
                        const SizedBox(height: 6), // Restore original spacing
                        Text(
                          MostUsedManager.getGameDisplayName(gameId),
                          style: const TextStyle(
                            fontSize: 12, // Restore original font size
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.search,
              color: const Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'search_game_types'.tr,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (_isSearching)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'no_search_results'.tr,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${'search_results'.tr} (${_searchResults.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 20,
          runSpacing: 16,
          children: _searchResults.map((type) {
            return _buildScoreItem(
              context,
              type.icon,
              type.displayName,
              const Color(0xFF4CAF50),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommonSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.star,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'common_scoring'.tr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildScoreItem(
                      context,
                      ScoreTypesData.commonTypes[0].icon,
                      ScoreTypesData.commonTypes[0].displayName,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildScoreItem(
                      context,
                      ScoreTypesData.commonTypes[1].icon,
                      ScoreTypesData.commonTypes[1].displayName,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildScoreItem(
                      context,
                      ScoreTypesData.commonTypes[2].icon,
                      ScoreTypesData.commonTypes[2].displayName,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildScoreItem(
                      context,
                      ScoreTypesData.commonTypes[3].icon,
                      ScoreTypesData.commonTypes[3].displayName,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPopularSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.trending_up,
                color: Colors.orange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'popular_scoring'.tr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildScoreItem(
                      context,
                      ScoreTypesData.popularTypes[0].icon,
                      ScoreTypesData.popularTypes[0].displayName,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildScoreItem(
                      context,
                      ScoreTypesData.popularTypes[1].icon,
                      ScoreTypesData.popularTypes[1].displayName,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildScoreItem(
                      context,
                      ScoreTypesData.popularTypes[2].icon,
                      ScoreTypesData.popularTypes[2].displayName,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildScoreItem(
                      context,
                      ScoreTypesData.popularTypes[3].icon,
                      ScoreTypesData.popularTypes[3].displayName,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildScoreItem(
                      context,
                      ScoreTypesData.popularTypes[4].icon,
                      ScoreTypesData.popularTypes[4].displayName,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildScoreItem(
                      context,
                      ScoreTypesData.popularTypes[5].icon,
                      ScoreTypesData.popularTypes[5].displayName,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllCategoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.category,
                color: Colors.purple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'all_categories'.tr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        ...ScoreTypesData.groupedTypes.entries.map((entry) {
          return Column(
            children: [
              _buildCategoryGroup(context, entry.key, entry.value),
              if (entry.key != ScoreTypesData.groupedTypes.keys.last)
                const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCategoryGroup(BuildContext context, String categoryName, List<ScoreType> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.folder,
                  color: Color(0xFF4CAF50),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                categoryName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              for (int i = 0; i < items.length; i += 3)
                if (i < items.length) ...[
                  Row(
                    children: [
                      for (int j = 0; j < 3 && i + j < items.length; j++) ...[
                        Expanded(
                          child: _buildScoreItem(
                            context,
                            items[i + j].icon,
                            items[i + j].displayName,
                            const Color(0xFF4CAF50),
                          ),
                        ),
                        if (j < 2 && i + j + 1 < items.length)
                          const SizedBox(width: 12),
                      ],
                    ],
                  ),
                  if (i + 3 < items.length)
                    const SizedBox(height: 12),
                ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(BuildContext context, IconData icon, String name, Color color) {
    return InkWell(
      onTap: () async {
        // Navigate to different pages based on score type
        String gameId = '';
        
        // Find corresponding id by displayName
        for (var type in ScoreTypesData.allTypes) {
          if (type.displayName == name) {
            gameId = type.id;
            break;
          }
        }
        
        if (gameId.isNotEmpty) {
          await _onGameClick(gameId);
        } else {
          // Other game types not available yet
          Get.snackbar('tip'.tr, 'feature_not_available'.tr);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainTabPage extends BaseView<MainTabController> {
  const MainTabPage({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return null; // Remove app bar to avoid duplicate title
  }

  @override
  Widget buildContent(BuildContext context) {
    return IndexedStack(
      index: controller.currentIndex,
      children: controller.pages,
    );
  }

  @override
  Widget? buildBottomNavigationBar(BuildContext context) {
    return null; // Remove bottom navigation bar
  }
} 