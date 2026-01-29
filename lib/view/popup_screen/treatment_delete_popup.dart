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
      return Dialog(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets + const EdgeInsets.all(20),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon and title
              Container(
                padding: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        task.icon,
                        size: 48,
                        color: Colors.red[400],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Remove "${task.name}"?',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'This treatment task will be removed from your records.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cancel button
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),

                  // Remove button
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _softDeleteTreatment(context, task.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Remove',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
      message: "Successfully Remove!\n\nThis treatment will no longer be continue.",
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

