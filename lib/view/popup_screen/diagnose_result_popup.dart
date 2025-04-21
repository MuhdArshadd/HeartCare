import 'package:flutter/material.dart';

class DiagnoseResultDialog extends StatelessWidget {
  final String riskLevel;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const DiagnoseResultDialog({
    super.key,
    required this.riskLevel,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 100, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Diagnose Complete',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'CVD Risk Level: $riskLevel',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Would you like HeartCare AI to provide a personalized treatment recommendation based on your results?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: onDecline,
                child: const Text('No Thanks', style: TextStyle(color: Colors.black54)),
              ),
              ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), // Change to your preferred color
                child: const Text('Yes', style: TextStyle(color: Colors.white),),
              ),
            ],
          )
        ],
      ),
    );
  }
}
