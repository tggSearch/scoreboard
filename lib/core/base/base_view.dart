import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:common_ui/common_ui.dart';
import 'base_controller.dart';

abstract class BaseView<T extends BaseController> extends GetView<T> {
  const BaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      builder: (controller) {
        return Scaffold(
          appBar: buildAppBar(context),
          body: buildBody(context),
          bottomNavigationBar: buildBottomNavigationBar(context),
          floatingActionButton: buildFloatingActionButton(context),
        );
      },
    );
  }

  /// Build app bar
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return null;
  }

  /// Build body
  Widget buildBody(BuildContext context) {
    return GetBuilder<T>(
      builder: (controller) {
        // 检查控制器是否存在
        if (controller == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // 只有在明确设置加载状态时才显示加载指示器
        if (controller.isLoading && controller.hasError == false) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.hasError) {
          return EmptyViewBuilder.error(
            message: controller.errorMessage,
            onRetry: () => controller.refresh(),
          );
        }

        return buildContent(context);
      },
    );
  }

  /// Build content widget
  Widget buildContent(BuildContext context);

  /// Build bottom navigation bar
  Widget? buildBottomNavigationBar(BuildContext context) {
    return null;
  }

  /// Build floating action button
  Widget? buildFloatingActionButton(BuildContext context) {
    return null;
  }

  /// Build loading widget
  Widget buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Build error widget
  Widget buildErrorWidget(String message, VoidCallback? onRetry) {
    return EmptyViewBuilder.error(
      message: message,
      onRetry: onRetry,
    );
  }

  /// Build empty widget
  Widget buildEmptyWidget({String? message}) {
    return EmptyViewBuilder.noData(message: message);
  }

  /// Build network error widget
  Widget buildNetworkErrorWidget(VoidCallback? onRetry) {
    return EmptyViewBuilder.networkError(onRetry: onRetry);
  }

  /// Show loading
  void showLoading({String? message}) {
    controller?.showLoading(message: message ?? 'loading'.tr);
  }

  /// Hide loading
  void hideLoading() {
    controller?.hideLoading();
  }

  /// Show success message
  void showSuccess(String message) {
    controller?.showSuccess(message);
  }

  /// Show error message
  void showError(String message) {
    controller?.showError(message);
  }

  /// Show warning message
  void showWarning(String message) {
    controller?.showWarning(message);
  }

  /// Show info message
  void showInfo(String message) {
    controller?.showInfo(message);
  }

  /// Go back
  void goBack() {
    controller?.goBack();
  }

  /// Navigate to route
  void navigateTo(String route, {dynamic arguments}) {
    controller?.navigateTo(route, arguments: arguments);
  }

  /// Replace route
  void replaceTo(String route, {dynamic arguments}) {
    controller?.replaceTo(route, arguments: arguments);
  }

  /// Navigate and clear stack
  void navigateAndClear(String route, {dynamic arguments}) {
    controller?.navigateAndClear(route, arguments: arguments);
  }
} 