import 'package:flutter/material.dart';
import 'package:heartcare/controller/openai_controller.dart';
import 'package:heartcare/controller/user_controller.dart';
import 'package:heartcare/view/popup_screen/diagnose_result_popup.dart';
import 'package:provider/provider.dart';
import '../controller/cvd_predictor.dart';
import '../model/provider/user_provider.dart';
import 'ai_treatment_recommendation_screen.dart';

class DiagnosePage extends StatefulWidget {
  const DiagnosePage({Key? key}) : super(key: key);

  @override
  State<DiagnosePage> createState() => _DiagnosePageState();
}

class _DiagnosePageState extends State<DiagnosePage> {
  final UserController userController = UserController();
  final OpenAIService openAIService = OpenAIService();

  String riskLevel = '';
  String lastDiagnosis = '';
  IconData riskIcon = Icons.favorite_border;

  Map<String, String> cvdDiagnoseResult = {};
  Map<String, Map<String, String>> cvdRisks = {};
  late Future<Map<String, String>> futureSymptoms;

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

    futureSymptoms = userController.getUserActiveSymptoms(user.userID);

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
            Text("Risk Level: $riskLevel", style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20)),
            Text("Last Diagnose: $lastDiagnosis"),
            const SizedBox(height: 10),
            const Text(
              "HeartCare utilizes an AI model trained on medical datasets to assess and detect an individual's risk level for cardiovascular disease (CVD).",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("CVD Risks Checklist",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 8),
            _buildCvdRiskTable(),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Active Symptoms of CVD (Logged by user)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 8),
            FutureBuilder<Map<String, String>>(
              future: futureSymptoms,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Text("Failed to load symptoms.");
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return _buildSymptomsTable(snapshot.data!);
                } else {
                  return _buildEmptySymptomsBox();
                }
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                  const AlertDialog(
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

                try {
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  final user = userProvider.user;

                  if (user == null) throw Exception("User data is unavailable.");

                  final symptoms = await userController.getUserActiveSymptoms(user.userID);
                  final cvdRisks = await userController.getCVDpresence(user.userID);

                  final predictor = CvdPredictor();
                  await predictor.loadModel();

                  final riskPrediction = await predictor.predictRisk(
                    symptoms: symptoms,
                    cvdRisks: cvdRisks,
                    userAge: user.age!,
                    userGender: user.sex!,
                  );

                  //Update CVD result
                  if (riskPrediction == "Low Risk") {
                    userController.updateCVDResult(user.userID, false);
                  } else if (riskPrediction == "High Risk") {
                    userController.updateCVDResult(user.userID, true);
                  }

                  predictor.dispose();

                  // Close loading dialog
                  if (mounted) Navigator.of(context).pop();

                  showDialog(
                    context: context,
                    builder: (context) {
                      return DiagnoseResultDialog(
                        riskLevel: riskPrediction,
                        onAccept: () async {
                          // Show loading dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            // prevent dismiss while loading
                            builder: (context) =>
                            const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          try {
                            String recommendation = await openAIService.getAITreatment(user.userID, cvdRisks, symptoms, riskPrediction);
                            print("raw ai treatment data: $recommendation");

                            // Remove loading dialog
                            Navigator.of(context).pop();

                            // Navigate to recommendation screen
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AITreatmentRecommendationScreen(userID: user.userID, treatments: recommendation),
                              ),
                                  (Route<dynamic> route) => false,
                            );
                          } catch (e) {
                            Navigator.of(context)
                                .pop(); // remove loading dialog on error too
                            // Optionally show error message here
                            print("Error fetching AI treatment: $e");
                          }
                          // AI TREATMENT IMPLEMENTATION
                          // Steps:
                          // 1. Send user's active symptoms, cvd risk presences and calculated value of risk level detection on the scale of 0-1 (0 lowest, 1 highest)
                          // In the function, it will call the treatment controller to fetch the user current treatment
                          // 2. Prompt to AI to get the treatment based on types of treatment (Medication, Supplements, Diet, Physical Activity)
                          // 3. Give the AI a schema answer for the treatment.
                          // 4. Upon receive the answer from AI, transform into a data that can be display and seen to user.
                          // 5. Depend on the user's acceptance towards AI treatment.
                          // 6. If user reject: Do nothing and back to homepage
                          // 7. If user accept:
                          // Possible Cases to considered:
                          // 1. User's existence treatment, what can we do about it?
                          // Answer: Just give the existing treatment to AI , prompt AI to analyse any additional treatment needed.
                          // If the existing treatment is empty, then AI will fully give the new treatment for user.
                          // If the existing treatment is not empty, AI will analyse for any necessary new treatment.
                        },
                        onDecline: () {
                          Navigator.of(context).pop();
                          _initializeData();
                        },
                      );
                    },
                  );
                } catch (e) {
                  if (mounted) Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (_) =>
                        AlertDialog(
                          title: const Text("Diagnosis Failed"),
                          content: Text(
                              "An error occurred during prediction: $e"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("OK"),
                            )
                          ],
                        ),
                  );
                }
              },

              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.redAccent
              ),
              child: const Text("Start Diagnose", style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),),
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
                Text(
                    label, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status, style: TextStyle(fontWeight: FontWeight.bold,
                    color: _getStatusColor(status))),
                Text(
                    "Last Update: $date", style: const TextStyle(fontSize: 10)),
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

  Widget _buildSymptomsTable(Map<String, String> symptoms) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
      },
      children: symptoms.entries.map((entry) {
        final name = entry.key;
        final date = entry.value;
        return TableRow(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(name),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "Active", style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor("Active"))),
                Text(
                    "Last Update: $date", style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ]);
      }).toList(),
    );
  }

  Color _getStatusColor(String status) {
    if (status == "Present" || status == "Active") {
      return Colors.red[600]!; // Red for urgency/medical
    } else if (status == "Not Present") {
      return Colors.green[600]!; // Green for healthy food
    } else {
      return Colors.grey;
    }
  }
}
