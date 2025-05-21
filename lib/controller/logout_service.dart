import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/provider/user_provider.dart';
import '../view/login_screen.dart';

class LogoutService {
  static void showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to log out?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog first
                        _performLogout(context);
                      },
                      child: const Text('Log Out'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _performLogout(BuildContext context) async {
    // Get navigator and provider references BEFORE any async operations
    final navigator = Navigator.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Show loading overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            ),
          );
        },
      );

      // Simulate processing
      await Future.delayed(const Duration(seconds: 1));

      // Clear provider state
      userProvider.clearUser();

      // Navigate to login screen
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    } catch (e) {
      navigator.pop(); // Dismiss loading overlay
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }
}