import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:common_ui/common_ui.dart';
import '../core/base/base_view.dart';
import '../core/base/base_controller.dart';
import '../business/history_viewer/view/history_viewer_page.dart';
import '../business/user_profile/view/user_profile_page.dart';
import '../core/data/score_types.dart';
import '../core/data/game_icons.dart';
import '../core/widgets/game_icon.dart';
import '../core/utils/most_used_manager.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_shadows.dart';

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
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(Icons.dashboard, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
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
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.xl),
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
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      body: KeyboardDismissScrollView(
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
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.primaryGlow(AppColors.primary),
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
                  gameId,
                  MostUsedManager.getGameDisplayName(gameId),
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

  Widget _buildStatCard(String gameId, String title, Color color, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: _GlassStatTile(
          title: title,
          icon: _gameIcon(gameId, size: 24, color: Colors.white),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _gameIcon(String gameId, {double size = 20, Color? color}) {
    return GameIcon(
      assetPath: GameIcons.assetOrDefault(gameId),
      size: size,
      color: color ?? Color(MostUsedManager.getGameColor(gameId)),
    );
  }

  Widget _buildQuickStartSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          icon: Icons.flash_on,
          title: 'quick_start'.tr,
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 100,
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
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.lg),
                child: AppGameTile(
                  icon: _gameIcon(gameId, size: 28),
                  label: MostUsedManager.getGameDisplayName(gameId),
                  accentColor: Color(MostUsedManager.getGameColor(gameId)),
                  onTap: () => _onGameClick(gameId),
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
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 4),
            child: Icon(
              Icons.search_rounded,
              color: AppColors.textMuted,
              size: 22,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'search_game_types'.tr,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color: AppColors.textMuted,
                splashRadius: 20,
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                  KeyboardDismiss.dismiss();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (_searchResults.isEmpty) {
      return AppEmptyState(
        icon: Icons.search_off,
        message: 'no_search_results'.tr,
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
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: 20,
          runSpacing: 16,
          children: _searchResults.map((type) {
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 80) / 3,
              child: _buildScoreItem(context, type),
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
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.star,
                color: AppColors.primary,
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
                    child: _buildScoreItem(context, ScoreTypesData.commonTypes[0]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildScoreItem(context, ScoreTypesData.commonTypes[1]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildScoreItem(context, ScoreTypesData.commonTypes[2]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildScoreItem(context, ScoreTypesData.commonTypes[3]),
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
        AppSectionHeader(
          icon: Icons.trending_up,
          title: 'popular_scoring'.tr,
          iconColor: AppColors.warning,
          iconBackgroundColor: AppColors.warning.withValues(alpha: 0.1),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppSurfaceCard(
          child: Column(
            children: [
              Row(
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(
                      child: _buildScoreItem(context, ScoreTypesData.popularTypes[i]),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (int i = 3; i < 6; i++) ...[
                    if (i > 3) const SizedBox(width: 12),
                    Expanded(
                      child: _buildScoreItem(context, ScoreTypesData.popularTypes[i]),
                    ),
                  ],
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
        AppSectionHeader(
          icon: Icons.category,
          title: 'all_categories'.tr,
          iconColor: const Color(0xFF9C27B0),
          iconBackgroundColor: const Color(0xFF9C27B0).withValues(alpha: 0.1),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...ScoreTypesData.groupedTypes.entries.map((entry) {
          return Column(
            children: [
              _buildCategoryGroup(context, entry.key, entry.value),
              if (entry.key != ScoreTypesData.groupedTypes.keys.last)
                const SizedBox(height: AppSpacing.xl),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildCategoryGroup(BuildContext context, String categoryName, List<ScoreType> items) {
    return AppSurfaceCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.folder,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                categoryName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Column(
            children: [
              for (int i = 0; i < items.length; i += 3)
                if (i < items.length) ...[
                  Row(
                    children: [
                      for (int j = 0; j < 3 && i + j < items.length; j++) ...[
                        Expanded(
                          child: _buildScoreItem(context, items[i + j]),
                        ),
                        if (j < 2 && i + j + 1 < items.length)
                          const SizedBox(width: 12),
                      ],
                    ],
                  ),
                  if (i + 3 < items.length) const SizedBox(height: 12),
                ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(BuildContext context, ScoreType type) {
    final accentColor = Color(MostUsedManager.getGameColor(type.id));
    return AppScoreChip(
      icon: _gameIcon(type.id, size: 18, color: accentColor),
      label: type.displayName,
      accentColor: accentColor,
      onTap: () => _onGameClick(type.id),
    );
  }
}

class _GlassStatTile extends StatefulWidget {
  final String title;
  final Widget icon;
  final VoidCallback onTap;

  const _GlassStatTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_GlassStatTile> createState() => _GlassStatTileState();
}

class _GlassStatTileState extends State<_GlassStatTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: SizedBox(width: 24, height: 24, child: widget.icon),
              ),
              const SizedBox(height: 6),
              Text(
                widget.title,
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