import 'package:flutter/material.dart';
import '../../controller/treatment_controller.dart';
import '../../model/treatment_model.dart';
import 'loading_processing_popup.dart';

final TreatmentController _treatmentController = TreatmentController();

void showDeleteTreatmentPopup({
  required BuildContext context,
  required TreatmentTask task,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(task.icon, size: 40, color: Colors.redAccent),
            const SizedBox(height: 10),
            Text(
              'Remove "${task.name}"?',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: const Text(
          'Do you want to remove this treatment task?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog first
              await _softDeleteTreatment(context, task.id);
            },
            child: const Text('Remove'),
          ),
        ],
      );
    },
  );
}

Future<void> _softDeleteTreatment(BuildContext context, int treatmentId) async {
  bool success = await _treatmentController.updateStatusTreatment(treatmentId);
  if (success == true) {
    AppPopup.showResult(
      context,
      isSuccess: true,
      message: "Successfully Remove!",
      onDismiss: () {},
    );
  } else {
    AppPopup.showResult(
      context,
      isSuccess: false,
      message: "Failed to remove treatment.",
      onDismiss: () {},
    );
  }
}

