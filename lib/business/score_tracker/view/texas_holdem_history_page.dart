import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/base/base_view.dart';
import '../controller/texas_holdem_controller.dart';

class TexasHoldemHistoryPage extends BaseView<TexasHoldemController> {
  const TexasHoldemHistoryPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        title: const Text(
          '德州扑克历史',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 历史盈亏统计
              _buildHistoryWinLossStats(),
              const SizedBox(height: 16),
              
              // 详细历史记录
              Expanded(child: _buildDetailedHistory()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryWinLossStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Obx(() {
        // 计算所有玩家的历史总盈亏
        final Map<String, int> totalWinLoss = {};
        
        for (final record in controller.records) {
          for (final player in record.players) {
            final winLoss = record.winLoss[player] ?? 0;
            totalWinLoss[player] = (totalWinLoss[player] ?? 0) + winLoss;
          }
        }
        
        // 按总盈亏排序
        final sortedPlayers = totalWinLoss.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        
        return StatefulBuilder(
          builder: (context, setState) {
            bool isExpanded = false;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '历史盈亏统计',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (sortedPlayers.length > 4) ...[
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: Text(
                          isExpanded ? '收起' : '展开',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                if (sortedPlayers.isNotEmpty) ...[
                  ...(isExpanded ? sortedPlayers : sortedPlayers.take(4)).map((entry) {
                    final player = entry.key;
                    final totalWinLoss = entry.value;
                    final isPositive = totalWinLoss >= 0;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              player,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${isPositive ? '+' : ''}$totalWinLoss',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isPositive ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (!isExpanded && sortedPlayers.length > 4) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '还有 ${sortedPlayers.length - 4} 个玩家...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  const Text(
                    '暂无历史记录',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildDetailedHistory() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '详细记录',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() => Text(
                  '共${controller.records.length}条记录',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                )),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.records.length,
              itemBuilder: (context, index) {
                final record = controller.records[controller.records.length - 1 - index];
                return _buildDetailedHistoryItem(record, controller.records.length - index);
              },
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedHistoryItem(TexasHoldemRecord record, int displayNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$displayNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '游戏记录',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '初始${record.initialChips}分',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...record.players.map((player) {
            final finalScore = record.finalScores[player] ?? 0;
            final finalChips = record.finalChips[player] ?? 0;
            final winLoss = record.winLoss[player] ?? 0;
            final initialChips = finalScore * record.initialChips;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      player,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '($initialChips)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      finalChips > 0 ? '$finalChips' : '未录入',
                      style: TextStyle(
                        fontSize: 11,
                        color: finalChips > 0 ? Colors.blue[600] : Colors.grey[400],
                        fontWeight: finalChips > 0 ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      finalChips > 0 ? '${winLoss >= 0 ? '+' : ''}$winLoss' : '-',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: finalChips > 0 
                            ? (winLoss >= 0 ? Colors.green : Colors.red)
                            : Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          Text(
            '时间: ${_formatDateTime(record.timestamp)}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 