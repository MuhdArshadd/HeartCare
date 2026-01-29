import 'package:flutter/material.dart';
import 'package:heartcare/controller/healthmetrics_controller.dart';
import '../app_bar/main_navigation.dart';
import 'loading_processing_popup.dart';

class CholesterolLevelPopup extends StatefulWidget {
  final int userId;
  const CholesterolLevelPopup({Key? key, required this.userId}) : super(key: key);

  @override
  _CholesterolLevelPopupState createState() => _CholesterolLevelPopupState();
}

class _CholesterolLevelPopupState extends State<CholesterolLevelPopup> {
  TextEditingController cholesterolSerum = TextEditingController();

  final HealthMetricsController healthMetricsController = HealthMetricsController();

  @override
  void dispose() {
    cholesterolSerum.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cholesterol Level',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildReadingSection(),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  double? totalCholesterol;

                  try {
                    totalCholesterol = double.parse(cholesterolSerum.text.trim());
                  } catch (e) {
                    AppPopup.showResult(
                      context,
                      isSuccess: false,
                      message: "Please enter valid numeric values.",
                    );
                    return;
                  }

                  AppPopup.showLoading(context, message: 'Processing...');
                  try {
                    final result = await healthMetricsController.updateHealthReading(
                      widget.userId,
                      3,
                      totalCholesterol,
                      0,
                    );
                    final isSuccess = result == "Update successful";

                    AppPopup.hide(context);

                    AppPopup.showResult(
                      context,
                      isSuccess: isSuccess,
                      message: isSuccess ? "Successfully Submitted!" : result,
                      onDismiss: isSuccess
                          ? () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainNavigationScreen(selectedIndex: 0),
                          ),
                        );
                      }
                          : null,
                    );
                  } catch (e) {
                    AppPopup.hide(context);
                    AppPopup.showResult(
                      context,
                      isSuccess: false,
                      message: "Error: ${e.toString()}",
                    );
                  }
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter your readings:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        TextField(
          controller: cholesterolSerum,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Total Cholesterol (mg/dL)',
            labelStyle: TextStyle(fontSize: 14),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
