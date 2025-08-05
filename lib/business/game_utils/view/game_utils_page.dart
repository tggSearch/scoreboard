import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/base/base_view.dart';
import '../controller/game_utils_controller.dart';

class GameUtilsPage extends BaseView<GameUtilsController> {
  const GameUtilsPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('分类浏览'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategorySection(context, '球类比赛', [
              {'emoji': '🏀', 'name': '篮球', 'color': Colors.orange},
              {'emoji': '⚽', 'name': '足球', 'color': Colors.green},
              {'emoji': '🏸', 'name': '羽毛球', 'color': Colors.blue},
              {'emoji': '🏓', 'name': '乒乓球', 'color': Colors.red},
              {'emoji': '🎾', 'name': '网球', 'color': Colors.yellow},
              {'emoji': '🏐', 'name': '排球', 'color': Colors.purple},
            ]),
            const SizedBox(height: 24),
            _buildCategorySection(context, '牌类比赛', [
              {'emoji': '🀄', 'name': '麻将', 'color': Colors.purple},
              {'emoji': '🃏', 'name': '斗地主', 'color': Colors.red},
              {'emoji': '♠️', 'name': '德州扑克', 'color': Colors.black},
              {'emoji': '🃏', 'name': '桥牌', 'color': Colors.blue},
              {'emoji': '🎴', 'name': 'UNO', 'color': Colors.green},
            ]),
            const SizedBox(height: 24),
            _buildCategorySection(context, '其他', [
              {'emoji': '✏️', 'name': '自定义', 'color': Colors.grey},
              {'emoji': '⏱️', 'name': '计时比赛', 'color': Colors.orange},
              {'emoji': '🎲', 'name': '掷骰子', 'color': Colors.purple},
              {'emoji': '✌️', 'name': '猜拳', 'color': Colors.pink},
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildCategoryCard(context, item);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed('/score-tracker', arguments: {'gameType': item['name']});
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item['color'].withOpacity(0.1),
                item['color'].withOpacity(0.2),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item['emoji'],
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 12),
              Text(
                item['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 