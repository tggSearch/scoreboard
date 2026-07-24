import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:common_ui/common_ui.dart';
import '../../../core/base/base_view.dart';
import '../controller/history_viewer_controller.dart';

class HistoryViewerPage extends BaseView<HistoryViewerController> {
  const HistoryViewerPage({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppAppBar(titleText: 'history'.tr);
  }

  @override
  Widget buildContent(BuildContext context) {
    return AppEmptyState(
      icon: Icons.history,
      title: 'history'.tr,
      message: 'feature_not_available'.tr,
    );
  }
}
