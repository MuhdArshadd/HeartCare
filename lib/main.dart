import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'controller/notification_service.dart';
import 'model/provider/profile_setup_provider.dart';
import 'view/splash_screen.dart';
import 'database_service.dart';
import 'model/provider/user_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Load environment variables
  await NotificationService().initNotification();  // init notifications

  final userProvider = UserProvider();
  await userProvider.loadUserFromPrefs(); // Load from local storage

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ChangeNotifierProvider(create: (_) => ProfileSetupProvider()),
      ],
      child: const MyApp(), // This should be inside MultiProvider
    ),
  );
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final DatabaseConnection _db = DatabaseConnection();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      _db.close();  // Always closes regardless of current screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
      ),
      // Normal launch: no notification, so pass nulls
      home: const SplashScreen(
        fromNotification: false,
        notificationId: null,
      ),
    );
  }
}
