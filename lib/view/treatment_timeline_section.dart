import 'package:flutter/material.dart';
import 'package:heartcare/model/treatment_model.dart';
import 'package:heartcare/view/treatment_task_card.dart';

class TreatmentTimelineSection extends StatelessWidget {
  final List<TreatmentTimeline> timelines;
  final void Function(int, int, {required bool markCompleted}) onToggleStatus;

  const TreatmentTimelineSection({
    Key? key,
    required this.timelines,
    required this.onToggleStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (timelines.isEmpty) return const _NoTimelineMessage();
    return Column(
      children: timelines.map((timeline) {
        final hasTreatments = timeline.treatments.isNotEmpty;
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(timeline.icon, size: 32, color: _getTimeIconColor(timeline.icon)),
                title: Text(
                  timeline.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(timeline.timeRange),
              ),
              const SizedBox(height: 8),
              if (hasTreatments)
                ...timeline.treatments.map((task) => TreatmentTaskCard(
                  timelineId: timeline.id,
                  task: task,
                  onToggleStatus: onToggleStatus,
                ))
              else
                const NoTreatmentCard(),
            ],
          ),
        );
      }).toList(),
    );
  }
}

Color _getTimeIconColor(IconData icon) {
  if (icon == Icons.wb_sunny) {       // Morning
    return Colors.orange; // Sunrise color
  } else if (icon == Icons.light_mode) { // Afternoon
    return Colors.yellow[700]!; // Bright daylight
  } else if (icon == Icons.nights_stay) { // Evening
    return Colors.deepPurple; // Twilight
  } else if (icon == Icons.bedtime) {    // Night
    return Colors.indigo; // Night time
  } else {
    return Colors.grey; // Default
  }
}

class _NoTimelineMessage extends StatelessWidget {
  const _NoTimelineMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'No treatment timelines or any treatment task available for the selected date.',
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black54),
        ),
      );
  }
}
