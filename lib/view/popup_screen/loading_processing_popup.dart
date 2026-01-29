import 'package:flutter/material.dart';
enum PopupType { loading, success, error }

class AppPopup {
  // 1. Show Loading
  static void showLoading(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(message ?? 'Please wait...', style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Hide any dialog
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // 3. Show Result (Success or Error)
  static void showResult(
      BuildContext context, {
        required bool isSuccess,
        required String message,
        Duration duration = const Duration(seconds: 2),
        VoidCallback? onDismiss,
      }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: isSuccess ? Colors.green : Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
          ],
        ),
      ),
    );

    Future.delayed(duration, () {
      // Ensure context is still valid (mounted) before popping
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close the dialog
        if (onDismiss != null) onDismiss(); // Trigger the refresh or callback
      }
    });
  }

}
