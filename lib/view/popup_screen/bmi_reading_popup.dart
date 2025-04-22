import 'package:flutter/material.dart';
import 'package:heartcare/view/app_bar/main_navigation.dart';
import 'package:heartcare/view/popup_screen/loading_processing_popup.dart';

class BmiCalculatorPopup extends StatelessWidget {
  final int userId;
  const BmiCalculatorPopup({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'BMI Calculator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: '10',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Height (meter, m)',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: '10',
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
              onPressed: () async {
                // Leave empty for backend logic
                print('Calculating BMI for user: $userId');
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
    );
  }
}