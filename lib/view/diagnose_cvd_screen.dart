import 'package:flutter/material.dart';
import 'package:heartcare/controller/user_controller.dart';
import 'package:heartcare/view/popup_screen/diagnose_result_popup.dart';
import 'package:provider/provider.dart';
import '../model/provider/user_provider.dart';

class DiagnosePage extends StatefulWidget {
  const DiagnosePage({Key? key}) : super(key: key);

  @override
  State<DiagnosePage> createState() => _DiagnosePageState();
}

class _DiagnosePageState extends State<DiagnosePage> {
  final UserController userController = UserController();

  String riskLevel = '';
  String lastDiagnosis = '';
  IconData riskIcon = Icons.favorite_border;

  Map<String, String> cvdDiagnoseResult = {};
  Map<String, Map<String, String>> cvdRisks = {};
  List<Map<String, String>> symptoms = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch user data after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) {
      // Handle null case if needed
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Simulate a network/database delay
    await Future.delayed(const Duration(milliseconds: 500));

    cvdDiagnoseResult = await userController.getDiagnoseResult(user.userID);
    riskLevel = cvdDiagnoseResult['riskLevel'] ?? 'Unidentified';
    lastDiagnosis = cvdDiagnoseResult['lastDiagnosis'] ?? 'None';
    riskIcon = _getIconForRiskLevel(riskLevel);

    cvdRisks = await userController.getCVDpresence(user.userID);

    symptoms = []; // Simulate no symptoms logged

    setState(() {
      isLoading = false;
    });
  }

  IconData _getIconForRiskLevel(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return Icons.heart_broken;
      case 'low':
        return Icons.favorite;
      default:
        return Icons.favorite_border;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Diagnose Page'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(riskIcon, size: 200, color: Colors.redAccent,),
            const SizedBox(height: 10),
            Text("Risk Level: $riskLevel", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text("Last Diagnose: $lastDiagnosis"),
            const SizedBox(height: 10),
            const Text(
              "HeartCare utilizes an AI model trained on medical datasets to assess and detect an individual's risk level for cardiovascular disease (CVD).",
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("CVD Risks Checklist", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 8),
            _buildCvdRiskTable(),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Symptoms of CVD (Logged by user)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 8),
            symptoms.isEmpty ? _buildEmptySymptomsBox() : _buildSymptomsTable(),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const AlertDialog(
                    backgroundColor: Colors.white,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: CircularProgressIndicator(),
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Analyzing your health data...\nPlease wait while our AI reviews your profile and symptoms to assess your cardiovascular risk.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );

                await Future.delayed(const Duration(seconds: 5));

                // Close loading dialog
                Navigator.of(context).pop();

                // Show result popup
                showDialog(
                  context: context,
                  builder: (context) {
                    const String riskLevel = "High"; // Replace with backend result
                    return DiagnoseResultDialog(
                      riskLevel: riskLevel,
                      onAccept: () {
                        Navigator.of(context).pop();
                        // Handle "Yes" logic
                      },
                      onDecline: () {
                        Navigator.of(context).pop();
                        //_initializeData(); // Refresh the Diagnose Page state
                      },
                    );
                  },
                );
              },

              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.redAccent
              ),
              child: const Text("Start Diagnose", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
            ),
            const SizedBox(height: 16),
            const Text(
              "This AI-generated result is based on medical research but may not be 100% accurate. For a confirmed diagnosis, please consult a healthcare professional.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCvdRiskTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
      },
      children: cvdRisks.entries.map((entry) {
        final label = entry.key;
        final description = entry.value['description']!;
        final status = entry.value['status']!;
        final date = entry.value['date']!;
        return TableRow(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Last Update: $date", style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ]);
      }).toList(),
    );
  }

  Widget _buildEmptySymptomsBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text("User does not logged any symptom."),
    );
  }

  Widget _buildSymptomsTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
      },
      children: symptoms.map((symptom) {
        return TableRow(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(symptom['name']!),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Logged", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Last Update: ${symptom['date']!}", style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ]);
      }).toList(),
    );
  }
}
