import 'package:flutter/material.dart';
import 'package:heartcare/view/app_bar/main_navigation.dart';
import 'package:heartcare/view/popup_screen/loading_processing_popup.dart';
import '../../controller/healthmetrics_controller.dart';

class BmiCalculatorPopup extends StatefulWidget {
  final int userId;
  const BmiCalculatorPopup({Key? key, required this.userId}) : super(key: key);

  @override
  State<BmiCalculatorPopup> createState() => _BmiCalculatorPopupState();
}

class _BmiCalculatorPopupState extends State<BmiCalculatorPopup> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  final HealthMetricsController _controller = HealthMetricsController();

  void _submitBMI() async {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (weight == null || height == null || height <= 0) {
      AppPopup.showResult(
        context,
        isSuccess: false,
        message: 'Please enter valid values for weight and height.',
      );
      return;
    }

    AppPopup.showLoading(context, message: 'Processing...');
    await Future.delayed(const Duration(seconds: 2));

    AppPopup.hide(context);

    // BMI is category 5, not using questions
    final result = await _controller.updateHealthReading(widget.userId, 5, weight, height);

    final isSuccess = result == "Update successful";

    AppPopup.showResult(
      context,
      isSuccess: isSuccess,
      message: isSuccess ? "Successfully submitted!" : result,
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
                    'BMI Calculator',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Body Weight (kilogram, kg)',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'e.g. 70',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Height (meter, m)',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'e.g. 1.75',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _submitBMI,
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
}
