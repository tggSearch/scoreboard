import 'package:flutter/material.dart';
import '../../../core/base/base_view.dart';
import '../controller/history_viewer_controller.dart';

class HistoryViewerPage extends BaseView<HistoryViewerController> {
  const HistoryViewerPage({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('历史记录'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => controller.loadHistory(),
        ),
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return const Center(
      child: Text('历史记录页面 - 待实现'),
    );
  }
} 