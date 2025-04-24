import 'package:flutter/material.dart';
import 'package:heartcare/controller/user_controller.dart';
import 'package:heartcare/view/app_bar/appbar.dart';
import 'package:heartcare/view/popup_screen/bloodpressure_reading_popup.dart';
import 'package:heartcare/view/popup_screen/bloodsugar_reading_popup.dart';
import 'package:heartcare/view/popup_screen/bmi_reading_popup.dart';
import 'package:heartcare/view/popup_screen/cholesterol_reading_popup.dart';
import 'package:heartcare/view/popup_screen/complete_profile_popup.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/provider/user_provider.dart';
import 'app_bar/main_navigation.dart';
import 'diagnose_cvd_screen.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen>{
  final UserController userController = UserController();
  bool popupShown = false;
  DateTime currentDate = DateTime.now();
  bool _isLoading = false;


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
            builder: (_) => const ProfileCompletionPopup(),
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
    ]);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refreshContent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_formatDate(currentDate), style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              const Text("Home page", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Welcome @${user?.username}!", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),

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
                          Text("Heart Health Score", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          SizedBox(height: 4),
                          Text("HeartCare AI detects your risk of cardiovascular disease."),
                          SizedBox(height: 8),
                          Center(child: Icon(Icons.favorite, size: 64, color: Colors.red)),
                          SizedBox(height: 20),
                          Text("Risk Level: $riskLevel", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                          Text("Last Diagnose: $dateDiagnose"),
                        ],
                      ),
                    );
                  }
                  return const Text('No data available');
                },
              ),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (userController.hasMissingUserData(user!)) {
                      showDialog(
                        context: context,
                        builder: (_) => const ProfileCompletionPopup(),
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
              const Text("Upcoming Treatments:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildCard(child: const Text("You have not log any symptoms.")),

              const SizedBox(height: 16),
              const Text("Update Your Health Readings:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
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
                        return _healthReadingCard(type, user!.userID, healthStatus, lastUpdate);
                      }).toList(),
                    );
                  }
                  return const Text('No health readings available');
                },
              ),

              const SizedBox(height: 16),
              const Text("Things to do:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _todoTile("Log Your Treatments", Icons.checklist_sharp),
              _todoTile("Log Your Symptoms", Icons.checklist_sharp),

              const SizedBox(height: 16),
              Row(
                children: const [
                  Icon(Icons.info, color: Colors.blue, size: 40),
                  SizedBox(width: 8),
                  Text("Heart Health Tips:", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              _buildCard(
                child: const Text(
                  "Did you know that walking just 30 minutes a day (about 2–3 km) can reduce your risk of heart disease by up to 30%?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontSize: 15),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
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
    return SizedBox( // Constrain the height
      height: 180, // Fixed height that works for your layout
      child: _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 4),
            Expanded( // Use Expanded instead of Flexible
              child: SingleChildScrollView( // Allow scrolling if content is too long
                physics: const ClampingScrollPhysics(), // Disable overscroll effect
                child: Text(
                  healthStatus,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ),

            Text("Last Update: $date"),
            const SizedBox(height: 8), // Replace Spacer with fixed gap
            SizedBox(
              height: 35,
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationScreen(selectedIndex: 1)),
            );
          } else if (title == "Log Your Symptoms") {
            Navigator.push(
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
}
