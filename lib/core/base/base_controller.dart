import 'package:get/get.dart';
import 'package:common_ui/common_ui.dart';

abstract class BaseController extends GetxController {
  // Loading state
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;

  // Error state
  final _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;
  set errorMessage(String value) => _errorMessage.value = value;

  // Has error
  bool get hasError => errorMessage.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  @override
  void onReady() {
    super.onReady();
    onReadyCallback();
  }

  @override
  void onClose() {
    dispose();
    super.onClose();
  }

  /// Initialize controller
  void initialize() {
    // Override in subclasses
  }

  /// Called when controller is ready
  void onReadyCallback() {
    // Override in subclasses
  }

  /// Dispose resources
  @override
  void dispose() {
    super.dispose();
    // Override in subclasses
  }

  /// Show loading
  void showLoading({String message = '加载中...'}) {
    Loading.show(message: message);
  }

  /// Hide loading
  void hideLoading() {
    Loading.hide();
  }

  /// Show success toast
  void showSuccess(String message) {
    Toast.success(message);
  }

  /// Show error toast
  void showError(String message) {
    Toast.error(message);
  }

  /// Show warning toast
  void showWarning(String message) {
    Toast.warning(message);
  }

  /// Show info toast
  void showInfo(String message) {
    Toast.info(message);
  }

  /// Show success snackbar
  void showSuccessSnackbar(String title, String message) {
    CustomSnackbar.success(title, message);
  }

  /// Show error snackbar
  void showErrorSnackbar(String title, String message) {
    CustomSnackbar.error(title, message);
  }

  /// Handle API call with loading and error handling
  Future<T?> handleApiCall<T>(
    Future<T> Function() apiCall, {
    String? loadingMessage,
    bool showLoading = true,
    bool showError = true,
  }) async {
    try {
      if (showLoading) {
        this.showLoading(message: loadingMessage ?? '加载中...');
      }
      
      final result = await apiCall();
      
      if (showLoading) {
        this.hideLoading();
      }
      
      return result;
    } catch (e) {
      if (showLoading) {
        this.hideLoading();
      }
      
      final errorMsg = e.toString();
      errorMessage = errorMsg;
      
      if (showError) {
        this.showError(errorMsg);
      }
      
      return null;
    }
  }

  /// Refresh data
  @override
  Future<void> refresh() async {
    errorMessage = '';
    await onRefresh();
  }

  /// Override this method to implement refresh logic
  Future<void> onRefresh() async {
    // Override in subclasses
  }

  /// Go back
  void goBack() {
    Get.back();
  }

  /// Navigate to named route
  void navigateTo(String route, {dynamic arguments}) {
    Get.toNamed(route, arguments: arguments);
  }

  /// Replace current route
  void replaceTo(String route, {dynamic arguments}) {
    Get.offNamed(route, arguments: arguments);
  }

  /// Navigate and clear stack
  void navigateAndClear(String route, {dynamic arguments}) {
    Get.offAllNamed(route, arguments: arguments);
  }
} 