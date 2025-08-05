import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Loading {
  static OverlayEntry? _overlayEntry;

  static void show({
    String message = 'loading',
    bool barrierDismissible = false,
  }) {
    if (_overlayEntry != null) {
      hide();
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => _LoadingWidget(
        message: message,
        barrierDismissible: barrierDismissible,
      ),
    );

    Overlay.of(Get.overlayContext!).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _LoadingWidget extends StatelessWidget {
  final String message;
  final bool barrierDismissible;

  const _LoadingWidget({
    required this.message,
    required this.barrierDismissible,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: GestureDetector(
        onTap: barrierDismissible ? Loading.hide : null,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 