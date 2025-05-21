import 'package:flutter/material.dart';
import 'package:heartcare/model/treatment_model.dart';
import 'package:heartcare/view/popup_screen/treatment_delete_popup.dart';

class TreatmentTaskCard extends StatelessWidget {
  final int timelineId;
  final TreatmentTask task;
  final void Function(int, int, {required bool markCompleted}) onToggleStatus;

  const TreatmentTaskCard({
    Key? key,
    required this.timelineId,
    required this.task,
    required this.onToggleStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return GestureDetector(
            onLongPress: () => showDeleteTreatmentPopup(context: context, task: task),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(task.icon, color: _getCategoryIconColor(task.icon)), // Use any color you like
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              if (task.dosage != null && task.unit != null && task.sessionCount != null && task.medicationType != null)
                Text('${task.dosage} ${task.unit}, ${task.sessionCount} ${task.medicationType}', style: const TextStyle(color: Colors.grey)),
              if (task.notes != null && task.notes != '')
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Notes: ${task.notes}', style: const TextStyle(fontSize: 13)),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded( // Add this
                    child: TextButton.icon(
                      icon: Icon(
                        task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: task.isCompleted ? Colors.green[800] : Colors.green[700],
                      ),
                      label: Text(
                        task.isCompleted ? 'Completed' : 'Complete',
                        style: TextStyle(color: Colors.green[800]),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green[700],
                        backgroundColor: Colors.green[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.green[100]!),
                        ),
                      ),
                      onPressed: () => onToggleStatus(timelineId, task.id, markCompleted: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded( // Add this
                    child: TextButton.icon(
                      icon: Icon(
                        task.isSkipped ? Icons.cancel : Icons.remove_circle_outline,
                        color: task.isSkipped ? Colors.red[800] : Colors.red[700],
                      ),
                      label: Text(
                        task.isSkipped ? 'Skipped' : 'Skip',
                        style: TextStyle(color: Colors.red[800]),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red[700],
                        backgroundColor: Colors.red[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.red[100]!),
                        ),
                      ),
                      onPressed: () => onToggleStatus(timelineId, task.id, markCompleted: false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  }
}

Color _getCategoryIconColor(IconData icon) {
  if (icon == Icons.medication) {       // Medication
    return Colors.red[600]!;  // Red for urgency/medical
  } else if (icon == Icons.local_pharmacy) { // Supplement
    return Colors.blue[600]!;  // Blue for pharmacy/chemical
  } else if (icon == Icons.restaurant) { // Diet
    return Colors.green[600]!;  // Green for healthy food
  } else if (icon == Icons.directions_run) { // Physical Activity
    return Colors.orange[600]!;  // Orange for energy/activity
  } else if (icon == Icons.help_outline) { // Default/Unknown
    return Colors.grey[600]!;
  } else {
    return Colors.purple; // Fallback color
  }
}

class NoTreatmentCard extends StatelessWidget {
  const NoTreatmentCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'No treatment for this timeline',
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black54),
        ),
      );
  }
}
