import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/base/base_view.dart';
import '../controller/bridge_controller.dart';

class BridgeHistoryPage extends BaseView<BridgeController> {
  const BridgeHistoryPage({super.key});

  @override
  BridgeController get controller => Get.find<BridgeController>();

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('bridge_history'.tr),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Obx(() {
      if (controller.records.isEmpty) {
              return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('no_records'.tr, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.records.length,
        itemBuilder: (context, index) {
          final record = controller.records[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              title: Row(
                children: [
                  Text(
                    'round_number'.tr.replaceAll('{number}', '${controller.records.length - index}'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              subtitle: Text(
                '${record.declarer == 'NS' ? 'north_south'.tr : 'east_west'.tr} ${record.contract} ${record.doubleStatus}',
                style: const TextStyle(fontSize: 12),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRecordItem('contract'.tr, record.contract),
                      _buildRecordItem('double_status'.tr, record.doubleStatus),
                      _buildRecordItem('declarer'.tr, record.declarer == 'NS' ? 'north_south'.tr : 'east_west'.tr),
                      _buildRecordItem('tricks'.tr, record.tricks.toString()),
                      _buildRecordItem('vulnerable'.tr, record.vulnerable ? 'yes'.tr : 'no'.tr),
                      const Divider(),
                      _buildRecordItem('north_south_score'.tr, record.nsScore.toString(), 
                          color: record.nsScore > 0 ? Colors.green : Colors.red),
                      _buildRecordItem('east_west_score'.tr, record.ewScore.toString(),
                          color: record.ewScore > 0 ? Colors.green : Colors.red),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildRecordItem(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 