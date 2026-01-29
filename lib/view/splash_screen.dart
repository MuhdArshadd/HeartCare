import 'package:flutter/material.dart';
import 'package:heartcare/view/app_bar/main_navigation.dart';
import 'package:provider/provider.dart';
import '../database_service.dart';
import '../model/provider/user_provider.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool fromNotification;
  final int? notificationId;

  const SplashScreen({
    Key? key,
    this.fromNotification = false,
    this.notificationId,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DatabaseConnection _db = DatabaseConnection();

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    bool connected = await _db.connect();
    await Future.delayed(const Duration(seconds: 3)); // Optional delay

    if (!mounted) return;

    if (!connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to connect to database')),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.isLoggedIn) {
      // Handle notification-based redirection
      if (widget.fromNotification) {
        switch (widget.notificationId) {
          case 1: // Morning Treatment
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainNavigationScreen(selectedIndex: 1)),// Treatment page
            );
            break;
          case 2: // Afternoon Treatment
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainNavigationScreen(selectedIndex: 1)),// Treatment page
            );
            break;
          case 3: // Evening Treatment
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainNavigationScreen(selectedIndex: 1)), // Treatment page
            );
          case 4: // Night Treatment
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainNavigationScreen(selectedIndex: 1)), // Treatment page
            );
            break;
          case 5: // 9AM general reminder
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainNavigationScreen(selectedIndex: 0)), // Home page
            );
            break;
          case 6: // 9PM symptom logging reminder
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainNavigationScreen(selectedIndex: 2)), // Symptom page
            );
            break;
          default:
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainNavigationScreen(selectedIndex: 0)),
            );
        }
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen(selectedIndex: 0)),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/HeartCare_logo.png'),
              height: 300,
            ),
            SizedBox(height: 20),
            Text(
              'HeartCare',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your Smart Cardiovascular Companion',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Getting everything ready for you...'),
          ],
        ),
      ),
    );
  }
}
