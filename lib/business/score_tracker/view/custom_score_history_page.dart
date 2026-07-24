import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:common_ui/common_ui.dart';
import '../../../core/base/base_view.dart';
import '../controller/custom_score_controller.dart';

class CustomScoreHistoryPage extends BaseView<CustomScoreController> {
  const CustomScoreHistoryPage({super.key});

  @override
  CustomScoreController get controller => Get.find<CustomScoreController>();

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppAppBar(titleText: 'custom_score_history'.tr);
  }

  @override
  Widget buildContent(BuildContext context) {
    return AppEmptyState(
      icon: Icons.info_outline,
      title: 'custom_score_function'.tr,
      message: '${'custom_score_description'.tr}\n\n${'no_history_records'.tr}',
    );
  }
} 