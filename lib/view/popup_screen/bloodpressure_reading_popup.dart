import 'package:flutter/material.dart';

import '../app_bar/main_navigation.dart';
import 'loading_processing_popup.dart';

class BloodPressurePopup extends StatefulWidget {
  final int userId;
  const BloodPressurePopup({Key? key, required this.userId}) : super(key: key);

  @override
  _BloodPressurePopupState createState() => _BloodPressurePopupState();
}

class _BloodPressurePopupState extends State<BloodPressurePopup> {
  bool useQuestion = false;
  String? ansQuestion;
  TextEditingController systolicController = TextEditingController();
  TextEditingController diastolicController = TextEditingController();

  @override
  void dispose() {
    systolicController.dispose();
    diastolicController.dispose();
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
                    'Blood Pressure',
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
                  print('Submitted: useQuestion=$useQuestion');
                  if (useQuestion) {
                    print('Question answer: $ansQuestion');
                  } else {
                    print('Systolic: ${systolicController.text}');
                    print('Diastolic: ${diastolicController.text}');
                  }
                  AppPopup.showLoading(context, message: 'Processing...');
                  final delay = Future.delayed(const Duration(seconds: 2));

                  await delay; // Ensure popup is visible at least 2 seconds

                  // Hide loading dialog
                  AppPopup.hide(context);

                  final result = true; // from result of processing

                  if (result == true) {
                    AppPopup.showResult(
                      context,
                      isSuccess: true,
                      message: "Successfully Submit!",
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
                      message: "Error processing the data.",
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
          controller: systolicController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Systolic Pressure (mmHg)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: diastolicController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Diastolic Pressure (mmHg)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionnaireSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '"Do you currently use anti-hypertensive medication?"',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('No'),
                labelStyle: const TextStyle(color: Colors.white),
                selected: ansQuestion == 'No',
                selectedColor: Colors.redAccent,
                backgroundColor: Colors.grey,
                onSelected: (selected) {
                  setState(() {
                    ansQuestion = selected ? 'No' : null;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Text('Yes'),
                labelStyle: const TextStyle(color: Colors.white),
                selected: ansQuestion == 'Yes',
                selectedColor: Colors.redAccent,
                backgroundColor: Colors.grey,
                onSelected: (selected) {
                  setState(() {
                    ansQuestion = selected ? 'Yes' : null;
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
