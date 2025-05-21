import 'package:flutter/material.dart';

import '../addsymptom_screen.dart';

class AddNewPopup extends StatelessWidget {
  const AddNewPopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add new',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildOptionButton(
              context: context,
              title: 'Treatment',
              icon: Icons.medical_services,
              color: Colors.green,
              onPressed: () {
                Navigator.pop(context, 'treatment');
              },
            ),
            const SizedBox(height: 16),
            _buildOptionButton(
              context: context,
              title: 'Symptom',
              icon: Icons.coronavirus_sharp,
              color: Colors.redAccent,
              onPressed: () {
                Navigator.pop(context, 'symptom');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Colors.white,),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,  // Title text color set to white
            ),
          ),
        ],
      ),
    );
  }
}