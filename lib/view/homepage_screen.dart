import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:heartcare/controller/notification_service.dart';
import 'package:heartcare/controller/user_controller.dart';
import 'package:heartcare/view/app_bar/appbar.dart';
import 'package:heartcare/view/popup_screen/bloodpressure_reading_popup.dart';
import 'package:heartcare/view/popup_screen/bloodsugar_reading_popup.dart';
import 'package:heartcare/view/popup_screen/bmi_reading_popup.dart';
import 'package:heartcare/view/popup_screen/cholesterol_reading_popup.dart';
import 'package:heartcare/view/popup_screen/complete_profile_popup.dart';
import 'package:heartcare/view/treatment_timeline_section.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controller/firebase_messaging_service.dart';
import '../controller/location_helper.dart';
import '../controller/treatment_controller.dart';
import '../main.dart';
import '../model/provider/user_provider.dart';
import '../model/treatment_model.dart';
import 'app_bar/main_navigation.dart';
import 'chatbot_screen.dart';
import 'diagnose_cvd_screen.dart';
import 'healthinfosheet_screen.dart';
import 'package:heartcare/view/family_mode_view.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen>{
  final TreatmentController treatmentController = TreatmentController();
  final UserController userController = UserController();
  final NotificationService notificationService = NotificationService();
  bool popupShown = false;
  DateTime currentDate = DateTime.now();
  bool _isLoading = false;

  bool _isButtonDisabled = false;
  List<TreatmentTimeline> _todaysTreatments = [];

  int _selectedMode = 0; // 0 = Personal, 1 = Family

  @override
  void initState() {
    super.initState();
    _fetchTreatmentData();
    _initNotification();
    _updateUserLocation();
    _updateFcmToken();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Show profile completion popup if necessary
    if (!popupShown) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (userController.hasMissingUserData(user!)) {
        popupShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const ProfileCompletionPopup(reason: 'diagnose'),
          );
        });
      }
    }
  }

  Future<void> _refreshContent() async {
    setState(() {
      _isLoading = true;
    });

    await Future.wait([
      _fetchRiskData(),
      _fetchHealthReadings(),
      _fetchTreatmentData(),
      _initNotification(),
      _updateUserLocation()
    ]);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateFcmToken() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    // CHECK THE GLOBAL TOKEN
    if (globalFcmToken != null) {
      // 3. SAVE TO DB
      await userController.saveUserToken(user!.userID, globalFcmToken!);
      print("Token linked to User ID: ${user.userID}");
    } else {
      // Fallback: Try to fetch it again if global was null
      String? retryToken = await FirebaseMessagingService.instance().getToken();
      if (retryToken != null) {
        await userController.saveUserToken(user!.userID, retryToken);
      }
    }
  }

  Future<void> _updateUserLocation () async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) throw Exception('User not found');
    try {
      if (globalTempLocation != null) {
        final result = await userController.updateLocation(user.userID, globalTempLocation!.latitude, globalTempLocation!.longitude);
        if (result) {
          print("Location updated successfully.");
        } else {
          print("Failed to update location.");
        }
      } else {
        // Edge case: Maybe GPS was off at startup? Try fetching it one last time now.
        Position? latePosition = await LocationHelper.determinePosition();
        if (latePosition != null) {
          final result = await userController.updateLocation(user.userID, globalTempLocation!.latitude, globalTempLocation!.longitude);
          if (result) {
            print("Location updated successfully.");
          }
        }
      }
    } catch (e) {
      print("Still cannot get location.");
    }
  }

  Future<void> _initNotification () async {
    // Schedule a daily notification to the user for general purpose
    await NotificationService().scheduleNotification(
      id: 5, // for general remainder in the morning
      title: "Don't Forget Your Health!",
      body: "Track your symptoms, record treatments, and keep your heart health in check.",
      hour: 9, // in 24 hour format (9.00AM)
      minute: 0,
      payload: "general_morning_remainder",
    );

    // Schedule a daily notification to the user for general purpose
    await NotificationService().scheduleNotification(
      id: 6, // general remainder in the night
      title: "It's Time To Update Your Health!",
      body: "Track your symptoms, record treatments, and keep your heart health in check.",
      hour: 21, // in 24 hour format (9.00PM)
      minute: 0,
      payload: "general_night_remainder",
    );

  }

  Future<void> _fetchTreatmentData() async {
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user == null) throw Exception('User not found');
      final treatments = await treatmentController.getTreatment("Homepage", user.userID, currentDate);

      if (mounted) {
        setState(() {
          _todaysTreatments = treatments;
        });
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        setState(() {
          _todaysTreatments = [];
        });
      }
    }
  }

  Future<Map<String, String>> _fetchRiskData() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) throw Exception('User not found');
    return await userController.fetchRiskLevelAndLastDiagnose(user.userID);
  }

  Future<List<Map<String, dynamic>>> _fetchHealthReadings() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) throw Exception('User not found');
    return await userController.fetchHealthReadings(user.userID);
  }

  void _onToggleStatus(int timelineId, int taskId, {required bool markCompleted}) async {
    if (_isButtonDisabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hold on! Please wait a moment before pressing again."),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isButtonDisabled = true);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isButtonDisabled = false);
    });

    final timeline = _todaysTreatments.firstWhere((t) => t.id == timelineId);
    final task = timeline.treatments.firstWhere((t) => t.id == taskId);

    if (markCompleted) {
      if (task.isCompleted) {
        task.isCompleted = false;
      } else {
        task.isCompleted = true;
        task.isSkipped = false;
      }
      await _handleAction(task.id, task.isCompleted ? 'Completed' : 'Pending', currentDate);
    } else {
      if (task.isSkipped) {
        task.isSkipped = false;
      } else {
        task.isSkipped = true;
        task.isCompleted = false;
      }
      await _handleAction(task.id, task.isSkipped ? 'Skipped' : 'Pending', currentDate);
    }
    task.lastActionTime = DateTime.now();
  }

  Future<void> _handleAction(int treatmentId, String status, DateTime date) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    bool success = await treatmentController.logTreatment(user!.userID, treatmentId, date, status);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Treatment marked as $status."),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update treatment. Try again later."),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      // CONDITIONAL BODY: No more Stack
      body: _selectedMode == 0
          ? _buildPersonalDashboard(user)
          : FamilyModeView(
        onSwitchToPersonal: () {
          setState(() {
            _selectedMode = 0;
          });
        },
      ),
    );
  }

  Widget _buildPersonalDashboard(dynamic user) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _refreshContent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. HEADER & TOGGLE (Now part of the scrollable list) ---
            Text(_formatDate(currentDate), style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            const Text("Home page", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Welcome @${user?.username}!", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),

            // Toggle Switch
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  // Personal Button (Active)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red, // Active Color
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text("Personal", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                  // Family Mode Button (Inactive)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMode = 1;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: Colors.transparent,
                        child: const Center(
                          child: Text("Family Mode", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Risk data
            FutureBuilder<Map<String, String>>(
              future: _fetchRiskData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final riskLevel = snapshot.data?['riskLevel'] ?? 'Unidentified';
                  final dateDiagnose = snapshot.data?['lastDiagnose'] ?? 'None';
                  return _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Heart Health Score", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        const SizedBox(height: 4),
                        const Text("HeartCare AI detects your risk of cardiovascular disease."),
                        const SizedBox(height: 8),
                        Center(child: Icon(_getIconForRiskLevel(riskLevel), size: 64, color: Colors.red)),
                        const SizedBox(height: 20),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            children: [
                              const TextSpan(text: "Risk Level: "),
                              TextSpan(
                                text: riskLevel,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: riskLevel.toLowerCase() == "low risk" ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "Last Diagnose: $dateDiagnose",
                          style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                      ],
                    ),
                  );
                }
                return const Text('No data available');
              },
            ),

            const SizedBox(height: 8),

            // Start Diagnose Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (userController.hasMissingUserData(user!)) {
                    showDialog(
                      context: context,
                      builder: (_) => const ProfileCompletionPopup(reason: 'diagnose'),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DiagnosePage()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text("Start Diagnose"),
              ),
            ),

            const SizedBox(height: 16),
            const Text("Upcoming Treatments:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),

            TreatmentTimelineSection(
              timelines: _todaysTreatments,
              onToggleStatus: _onToggleStatus,
            ),

            Container(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainNavigationScreen(selectedIndex: 1)),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text("See All Treatments", style: TextStyle(fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),

            const SizedBox(height: 8),
            const Text("Update Your Health Readings:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),

            // Health Readings Grid
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchHealthReadings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final readings = snapshot.data!;
                  final Map<String, Map<String, dynamic>> readingMap = {
                    for (var reading in readings) reading['readingType']: reading
                  };
                  final List<String> readingTypes = ["Blood Pressure", "Blood Sugar", "Cholesterol Level", "BMI"];
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: readingTypes.map((type) {
                      final data = readingMap[type];
                      final healthStatus = data?['category'] ?? "Not Available";
                      final lastUpdate = data?['lastUpdate'] ?? "Never";
                      return Stack(
                        children: [
                          _healthReadingCard(type, user!.userID, healthStatus, lastUpdate),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (context) => HealthInfoSheet(readingType: type),
                                );
                              },
                              child: const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                }
                return const Text('No health readings available');
              },
            ),

            const SizedBox(height: 16),
            const Text("Things to do:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            _todoTile("Log Your Treatments", Icons.checklist_sharp),
            _todoTile("Log Your Symptoms", Icons.checklist_sharp),

            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 40),
                SizedBox(width: 8),
                Text("Heart Health Tips:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            _buildCard(
              child: const Text(
                "Did you know that walking just 30 minutes a day (about 2–3 km) can reduce your risk of heart disease by up to 30%?",
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
              ),
            ),
            const SizedBox(height: 20),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Chat with HeartCare Chatbot", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Have questions about your heart health? Our AI assistant is here to help.", style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text("Start Chat", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotPage()));
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  IconData _getIconForRiskLevel(String level) {
    switch (level.toLowerCase()) {
      case 'high risk':
        return Icons.heart_broken;
      case 'low risk':
        return Icons.favorite;
      default:
        return Icons.favorite_border;
    }
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  Widget _healthReadingCard(String label, int userId, String healthStatus, String date) {
    return SizedBox(
      height: 157, // Fixed height for all cards
      child: _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title section
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Health status section with fixed height
            SizedBox(
              height: 50, // Adjusted height to prevent overflow
              child: Text(
                healthStatus,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: _getHealthStatusColor(healthStatus),
                ),
                maxLines: 2, // Limit to 3 lines
                overflow: TextOverflow.ellipsis, // Show ellipsis if text is too long
              ),
            ),

            // Last update section
            Text("Last Update: $date", style: TextStyle(fontSize: 11)),
            const SizedBox(height: 12),

            // Update button
            SizedBox(
              height: 26,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        if (label == "Blood Pressure") {
                          return BloodPressurePopup(userId: userId);
                        } else if (label == "Blood Sugar") {
                          return BloodSugarPopup(userId: userId);
                        } else if (label == "Cholesterol Level") {
                          return CholesterolLevelPopup(userId: userId);
                        } else if (label == "BMI") {
                          return BmiCalculatorPopup(userId: userId);
                        } else {
                          return const SizedBox();
                        }
                      },
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Update", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _todoTile(String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (title == "Log Your Treatments") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationScreen(selectedIndex: 1)),
            );
          } else if (title == "Log Your Symptoms") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationScreen(selectedIndex: 2)),
            );
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${DateFormat('EEEE').format(currentDate)}, ${date.day}/${date.month}/${date.year}";
  }

  Color _getHealthStatusColor(String status) {
    // Muted color palette
    const Color mutedGreen = Color(0xFF4CAF50);
    const Color mutedYellow = Color(0xFFFBC02D);
    const Color mutedOrange = Color(0xFFF57C00);
    const Color mutedRed = Color(0xFFD32F2F);
    const Color mutedBlue = Color(0xFF1976D2);
    const Color mutedLightBlue = Color(0xFF03A9F4);
    const Color mutedGrey = Color(0xFF757575);

    switch (status) {
    // Blood Pressure
      case "Normal BP":
        return mutedGreen;
      case "Elevated BP":
        return const Color(0xFFCDDC39); // Muted lime
      case "Stage 1 Hypertension":
        return mutedOrange;
      case "Stage 2 Hypertension":
        return mutedRed;
      case "Unclassified BP":
        return mutedGrey;

    // Blood Sugar
      case "Normal":
        return mutedGreen;
      case "Prediabetes":
        return mutedYellow;
      case "Diabetes":
        return mutedRed;
      case "Unclassified":
        return mutedGrey;

    // Cholesterol
      case "Optimal":
        return mutedGreen;
      case "Borderline High":
        return mutedYellow;
      case "High":
        return mutedRed;
      case "Hypocholesterolemia":
        return mutedBlue;

    // BMI
      case "Underweight":
        return mutedLightBlue;
      case "Normal weight":
        return mutedGreen;
      case "Pre-obesity":
        return mutedYellow;
      case "Obesity Class I":
        return mutedOrange;
      case "Obesity Class II":
        return const Color(0xFFE64A19); // Muted deep orange
      case "Obesity Class III":
        return mutedRed;
      case "Invalid input":
        return mutedGrey;

    // Default
      default:
        return mutedGrey;
    }
  }

}
