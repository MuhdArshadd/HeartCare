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
import 'diagnose_cvd_screen.dart'; // For DateFormat


class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  final UserController userController = UserController();
  bool popupShown = false;
  DateTime currentDate = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!popupShown) {
      final user = Provider.of<UserProvider>(context, listen: false).user;

      if (userController.hasMissingUserData(user!)) {
        popupShown = true; // Prevent multiple popups
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const ProfileCompletionPopup(),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDate(currentDate), style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            const Text("Home page", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Welcome @${user?.username}!", style: TextStyle(fontSize: 16)),

            const SizedBox(height: 16),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Heart Health Score", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(height: 4),
                  Text("HeartCare AI detects your risk of cardiovascular disease."),
                  SizedBox(height: 8),
                  Center(child: Icon(Icons.favorite, size: 64, color: Colors.red)),
                  SizedBox(height: 20),
                  Text("Risk Level: Unidentified", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                  Text("Last Diagnose: None"),
                ],
              ),
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
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  shape: const StadiumBorder(), // Fully rounded ends
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text("Start Diagnose"),
              )
            ),

            const SizedBox(height: 16),
            const Text("Upcoming Treatments:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildCard(
              child: const Text("You have not log any symptoms."),
            ),

            const SizedBox(height: 16),
            const Text("Update Your Health Readings:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _healthReadingCard("Blood Pressure", user!.userID),
                _healthReadingCard("Blood Sugar", user!.userID),
                _healthReadingCard("Cholesterol Level", user!.userID),
                _healthReadingCard("BMI", user!.userID),
              ],
            ),

            const SizedBox(height: 16),
            const Text("Things to do:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _todoTile("Log Your Symptoms", Icons.checklist_sharp),
            _todoTile("Log Your Treatments", Icons.checklist_sharp),

            const SizedBox(height: 16),
            Row(
              children: const [
                Icon(Icons.info, color: Colors.blue, size: 40,),
                SizedBox(width: 8),
                Text("Heart Health Tips:", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            _buildCard(
              child: const Text(
                "Did you know that walking just 30 minutes a day (about 2-3 km) can reduce your risk of heart disease by up to 30%?",
              style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontSize: 15)),
            ),
            const SizedBox(height: 20),
          ],
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

  Widget _healthReadingCard(String label, int userId) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          const Text("Unidentified"),
          const Text("Last Update: None"),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (label == "Blood Pressure"){
                  showDialog(
                    context: context,
                    builder: (context) => BloodPressurePopup(userId: userId),
                  );
                } else if (label == "Blood Sugar"){
                  showDialog(
                    context: context,
                    builder: (context) => BloodSugarPopup(userId: userId),
                  );
                } else if (label == "Cholesterol Level") {
                  showDialog(
                    context: context,
                    builder: (context) => CholesterolLevelPopup(userId: userId),
                  );
                } else if (label == "BMI"){
                  showDialog(
                    context: context,
                    builder: (context) => BmiCalculatorPopup(userId: userId),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,       // Red background
                foregroundColor: Colors.white,     // White text
              ),
              child: const Text("Update", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
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
          if (title == "Log Your Symptoms"){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationScreen(selectedIndex: 1,)),
            );
          }else if (title == "Log Your Treatments"){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationScreen(selectedIndex: 2,)),
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
