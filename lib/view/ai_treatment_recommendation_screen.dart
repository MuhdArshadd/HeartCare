import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heartcare/controller/treatment_controller.dart';
import 'package:heartcare/view/app_bar/main_navigation.dart';
import 'package:heartcare/view/popup_screen/loading_processing_popup.dart';

class AITreatmentRecommendationScreen extends StatefulWidget {
  final String treatments;
  final int userID;

  const AITreatmentRecommendationScreen({super.key, required this.treatments, required this.userID});

  @override
  State<AITreatmentRecommendationScreen> createState() => _AITreatmentRecommendationScreenState();
}

class _AITreatmentRecommendationScreenState extends State<AITreatmentRecommendationScreen> {
  final TreatmentController treatmentController = TreatmentController();
  List<Map<String, dynamic>> _treatmentList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTreatments();
  }

  Future<void> _loadTreatments() async {
    _treatmentList = await getJSONTreatment(widget.treatments);
    setState(() {
      _isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> getJSONTreatment(String rawData) async {
    try {
      // Remove code block markers (```json and ```) if present
      final cleanedData = rawData
          .replaceAll(RegExp(r'^```json'), '')
          .replaceAll(RegExp(r'```$'), '')
          .trim();

      final List<dynamic> decoded = jsonDecode(cleanedData);
      print("JSON DATA TO BE INSERTED:");
      print(decoded); // prints full decoded data
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error decoding treatment data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final Map<String, List<Map<String, dynamic>>> treatmentsByTime = {
      "Morning": [],
      "Afternoon": [],
      "Evening": [],
      "Night": [],
    };

    final Map<String, String> timeRanges = {
      "Morning": "6 AM - 12 PM",
      "Afternoon": "12 PM - 4 PM",
      "Evening": "4 PM - 8 PM",
      "Night": "8 PM - 6 AM",
    };

    for (var treatment in _treatmentList) {
      for (String time in treatment['timesOfDay']) {
        treatmentsByTime[time]?.add(treatment);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Treatment Recommendation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "DISCLAIMER: These AI-generated recommendations are for informational purposes only and should not replace professional medical advice.\n\nAlways consult with your healthcare provider before starting any new treatment regimen.",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...treatmentsByTime.entries.map((entry) {
              if (entry.value.isEmpty) return const SizedBox();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${entry.key} (${timeRanges[entry.key] ?? ''})",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...entry.value.map((treatment) => _buildTreatmentCard(context, treatment)).toList(),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainNavigationScreen(selectedIndex: 0)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Background color
                  foregroundColor: Colors.white, // Text color
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text("Reject"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  AppPopup.showLoading(context, message: "Saving treatments...");

                  bool allSuccess = true;

                  for (var treatment in _treatmentList) {
                    bool result = await treatmentController.addTreatment(widget.userID, treatment);
                    if (!result) {
                      allSuccess = false;
                      break;
                    }
                  }

                  AppPopup.hide(context);

                  if (allSuccess) {
                    AppPopup.showResult(
                      context,
                      isSuccess: true,
                      message: "Treatments saved successfully!",
                      onDismiss: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainNavigationScreen(selectedIndex: 0)),
                        );
                      },
                    );
                  } else {
                    AppPopup.showResult(
                      context,
                      isSuccess: false,
                      message: "Failed to save all treatments. Please try again.",
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Background color
                  foregroundColor: Colors.white, // Text color
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text("Accept"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentCard(BuildContext context, Map<String, dynamic> treatment) {
    IconData icon;
    Color color;

    switch (treatment['category']) {
      case 'Medication':
        icon = Icons.medication;
        color = Colors.purple;
        break;
      case 'Supplement':
        icon = Icons.local_pharmacy;
        color = Colors.orange;
        break;
      case 'Diet':
        icon = Icons.restaurant;
        color = Colors.green;
        break;
      case 'Physical Activity':
        icon = Icons.directions_walk;
        color = Colors.blue;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    treatment['name'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    treatment['description'],
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  if (treatment['category'] == "Medication" || treatment['category'] == "Supplement") ...[
                    Row(
                      children: [
                        Text("Dosage: ${treatment['dosage']} ${treatment['unit']}"),
                        const SizedBox(width: 12),
                        Text("Qty: ${treatment['quantity']}"),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("Type: ${treatment['type']}"),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}