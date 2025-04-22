import 'package:flutter/material.dart';
import 'package:heartcare/controller/healthmetrics_controller.dart';

import '../app_bar/main_navigation.dart';
import 'loading_processing_popup.dart';

class BloodSugarPopup extends StatefulWidget {
  final int userId;
  const BloodSugarPopup({Key? key, required this.userId}) : super(key: key);

  @override
  _BloodSugarPopupState createState() => _BloodSugarPopupState();
}

class _BloodSugarPopupState extends State<BloodSugarPopup> {
  bool useQuestion = false;
  bool? ansQuestion;
  TextEditingController fastingBloodSugar = TextEditingController();

  final HealthMetricsController healthMetricsController = HealthMetricsController();

  @override
  void dispose() {
    fastingBloodSugar.dispose();
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
                    'Blood Sugar',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Choose input type:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Reading'),
                      selected: !useQuestion,
                      selectedColor: Colors.redAccent,
                      backgroundColor: Colors.grey,
                      labelStyle: const TextStyle(color: Colors.white),
                      onSelected: (selected) {
                        setState(() {
                          useQuestion = !selected;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Questionnaire'),
                      selected: useQuestion,
                      selectedColor: Colors.redAccent,
                      backgroundColor: Colors.grey,
                      labelStyle: const TextStyle(color: Colors.white),
                      onSelected: (selected) {
                        setState(() {
                          useQuestion = selected;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              useQuestion ? _buildQuestionnaireSection() : _buildReadingSection(),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  if (useQuestion && ansQuestion == null) {
                    AppPopup.showResult(
                      context,
                      isSuccess: false,
                      message: "Please answer the questionnaire.",
                    );
                    return;
                  }

                  double? fastingBloodsugar;

                  if (!useQuestion) {
                    try {
                      fastingBloodsugar = double.parse(fastingBloodSugar.text.trim());
                    } catch (e) {
                      AppPopup.showResult(
                        context,
                        isSuccess: false,
                        message: "Please enter valid numeric values.",
                      );
                      return;
                    }
                  }
                  AppPopup.showLoading(context, message: 'Processing...');
                  try {
                    String result = await healthMetricsController.updateHealthReading(widget.userId, 1, useQuestion,ansQuestion ?? false, fastingBloodsugar ?? 0.0, 0);

                    AppPopup.hide(context);

                    AppPopup.showResult(
                      context,
                      isSuccess: true,
                      message: "Successfully Submitted!",
                      onDismiss: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainNavigationScreen(selectedIndex: 0)),
                        );
                      },
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
                child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
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
          controller: fastingBloodSugar,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Fasting Blood Sugar (mg/dL)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "A blood sample is taken after you haven't eaten for at least eight hours or overnight (fast).",
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildQuestionnaireSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '"Do you currently use a medication for diabetes?"',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('No'),
                labelStyle: const TextStyle(color: Colors.white),
                selected: ansQuestion == false,
                selectedColor: Colors.redAccent,
                backgroundColor: Colors.grey,
                onSelected: (selected) {
                  setState(() {
                    ansQuestion = selected ? false : null;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Text('Yes'),
                labelStyle: const TextStyle(color: Colors.white),
                selected: ansQuestion == true,
                selectedColor: Colors.redAccent,
                backgroundColor: Colors.grey,
                onSelected: (selected) {
                  setState(() {
                    ansQuestion = selected ? true : null;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
