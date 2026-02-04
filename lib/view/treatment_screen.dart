import 'package:flutter/material.dart';
import 'package:heartcare/controller/treatment_controller.dart';
import 'package:heartcare/view/app_bar/appbar.dart';
import 'package:heartcare/view/treatment_info_screen.dart';
import 'package:heartcare/view/treatment_timeline_section.dart';
import 'package:provider/provider.dart';
import '../controller/notification_service.dart';
import '../model/provider/user_provider.dart';
import '../model/treatment_model.dart';

class TreatmentPage extends StatefulWidget {
  const TreatmentPage({Key? key}) : super(key: key);

  @override
  State<TreatmentPage> createState() => _TreatmentPageState();
}

class _TreatmentPageState extends State<TreatmentPage> {
  final TreatmentController treatmentController = TreatmentController();
  final NotificationService notificationService = NotificationService();

  DateTime _selectedDate = DateTime.now();
  double _dailyProgress = 0.0;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isButtonDisabled = false;

  late List<TreatmentTimeline> _displayTimelines = [];

  @override
  void initState() {
    super.initState();
    _loadTreatmentData();
    _initNotification();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _loadTreatmentData();
      });
    }
  }

  Future<void> _initNotification() async {
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      await Future.delayed(const Duration(milliseconds: 500));
      final fetched = await treatmentController.getTreatmentTimelineID(user!.userID);

      final List<int> allTimelines = [1, 2, 3, 4];

      if (fetched.isEmpty) {
        for (final id in allTimelines) {
          await NotificationService().cancelTreatmentNotification(id);
        }
      } else {
        for (final id in allTimelines) {
          if (fetched.contains(id)) {
            if (id == 1){
              await NotificationService().scheduleNotification(
                id: id,
                title: "It's Time For Your Treatment!",
                body: "Start your day right — take your morning treatment.",
                hour: 6,
                minute: 0,
                payload: "morning_treatment",
              );
            } else if (id == 2){
              await NotificationService().scheduleNotification(
                id: id,
                title: "It's Time For Your Treatment!",
                body: "Time for your midday treatment.",
                hour: 12,
                minute: 0,
                payload: "afternoon_treatment",
              );
            } else if (id == 3){
              await NotificationService().scheduleNotification(
                id: id,
                title: "It's Time For Your Treatment!",
                body: "Stay on track with your evening treatment.",
                hour: 18,
                minute: 0,
                payload: "evening_treatment",
              );
            } else if (id == 4){
              await NotificationService().scheduleNotification(
                id: id,
                title: "It's Time For Your Treatment!",
                body: "End the day well — take your night treatment.",
                hour: 21,
                minute: 0,
                payload: "night_treatment",
              );
            }
          } else {
            await NotificationService().cancelTreatmentNotification(id);
          }
        }
      }
    } catch (error) {
      print("Notification initialization error: $error");
    }
  }

  Future<void> _loadTreatmentData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      await Future.delayed(const Duration(milliseconds: 500));
      final fetched = await treatmentController.getTreatment("Treatment", user!.userID, _selectedDate);
      setState(() {
        _displayTimelines = fetched;
        _isLoading = false;
        _updateProgress();
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _updateProgress() {
    final total = _displayTimelines.fold(0, (sum, t) => sum + t.treatments.length);
    final completed = _displayTimelines.fold(0, (sum, t) => sum + t.treatments.where((task) => task.isCompleted).length,);
    setState(() {
      _dailyProgress = total > 0 ? completed / total : 0.0;
    });
  }

  void _onToggleStatus(int timelineId, int taskId, {required bool markCompleted}) async {
    if (_isButtonDisabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hold on! Please wait a moment before pressing again."),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isButtonDisabled = true);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isButtonDisabled = false);
    });

    final timeline = _displayTimelines.firstWhere((t) => t.id == timelineId);
    final task = timeline.treatments.firstWhere((t) => t.id == taskId);

    if (markCompleted) {
      if (task.isCompleted) {
        task.isCompleted = false;
      } else {
        task.isCompleted = true;
        task.isSkipped = false;
      }
      await _handleAction(task.id, task.isCompleted ? 'Completed' : 'Pending', _selectedDate);
    } else {
      if (task.isSkipped) {
        task.isSkipped = false;
      } else {
        task.isSkipped = true;
        task.isCompleted = false;
      }
      await _handleAction(task.id, task.isSkipped ? 'Skipped' : 'Pending', _selectedDate);
    }
    task.lastActionTime = DateTime.now();
    setState(() {});
    _updateProgress();
  }

  Future<void> _handleAction(int treatmentId, String status, DateTime date) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    bool success = await treatmentController.logTreatment(user!.userID, treatmentId, date, status);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Treatment marked as $status."),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update treatment. Try again later."),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? const Center(child: Text('Failed to load data.'))
          : RefreshIndicator(
        onRefresh: () async {
          await _loadTreatmentData();
          await _initNotification();
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Treatment Plan',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TreatmentInfoPage()),
                    );
                  },
                  child: const Icon(
                    Icons.warning,
                    color: Colors.redAccent,
                    size: 35,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: TextButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildProgressIndicator(),
            const SizedBox(height: 24),
            TreatmentTimelineSection(
              timelines: _displayTimelines,
              onToggleStatus: _onToggleStatus,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: CircularProgressIndicator(
                value: _dailyProgress,
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            Text(
              '${(_dailyProgress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Daily Progress', style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
  //
  // Widget _buildNoTimelineMessage() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     margin: const EdgeInsets.only(top: 20),
  //     decoration: BoxDecoration(
  //       color: Colors.grey.shade100,
  //       border: Border.all(color: Colors.grey.shade300),
  //       borderRadius: BorderRadius.circular(10),
  //     ),
  //     child: const Text(
  //       'No treatment timelines or any treatment task available for the selected date.',
  //       style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black54),
  //     ),
  //   );
  // }
  //
  // Widget _buildTimelineSection(TreatmentTimeline timeline) {
  //   final hasTreatments = timeline.treatments.isNotEmpty;
  //
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 20),
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.grey.shade300),
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         ListTile(
  //           contentPadding: EdgeInsets.zero,
  //           leading: Icon(timeline.icon, size: 32),
  //           title: Text(
  //             timeline.name,
  //             style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //           ),
  //           subtitle: Text(timeline.timeRange),
  //         ),
  //         const SizedBox(height: 8),
  //         if (hasTreatments)
  //           ...timeline.treatments.map((task) => _buildTreatmentCard(timeline.id, task)).toList()
  //         else
  //           _buildNoTreatmentCard(),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _buildTreatmentCard(int timelineId, TreatmentTask task) {
  //   return GestureDetector(
  //         onLongPress: () => showDeleteTreatmentPopup(context: context, task: task),
  //         child: Container(
  //           margin: const EdgeInsets.symmetric(vertical: 6),
  //           padding: const EdgeInsets.all(12),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           border: Border.all(color: Colors.grey.shade300),
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(task.icon, color: Colors.blueGrey), // Use any color you like
  //               const SizedBox(width: 8),
  //               Expanded(
  //                 child: Text(
  //                   task.name,
  //                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           if (task.dosage != null && task.unit != null && task.sessionCount != null && task.medicationType != null)
  //             Text('${task.dosage} ${task.unit}, ${task.sessionCount} ${task.medicationType}', style: const TextStyle(color: Colors.grey)),
  //           if (task.notes != null && task.notes != '')
  //             Padding(
  //               padding: const EdgeInsets.only(top: 4),
  //               child: Text('Notes: ${task.notes}', style: const TextStyle(fontSize: 13)),
  //             ),
  //           const SizedBox(height: 8),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.end,
  //             children: [
  //               TextButton.icon(
  //                 icon: Icon(task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked),
  //                 label: Text(task.isCompleted ? 'Completed' : 'Mark Complete'),
  //                 onPressed: () => _onToggleStatus(timelineId, task.id, markCompleted: true),
  //               ),
  //               TextButton.icon(
  //                 icon: Icon(task.isSkipped ? Icons.cancel : Icons.remove_circle_outline),
  //                 label: Text(task.isSkipped ? 'Skipped' : 'Skip'),
  //                 onPressed: () => _onToggleStatus(timelineId, task.id,  markCompleted: false),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildNoTreatmentCard() {
  //   return Container(
  //     width: double.infinity,
  //     margin: const EdgeInsets.symmetric(vertical: 6),
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: Colors.grey.shade100,
  //       border: Border.all(color: Colors.grey.shade300),
  //       borderRadius: BorderRadius.circular(10),
  //     ),
  //     child: const Text(
  //       'No treatment for this timeline',
  //       style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black54),
  //     ),
  //   );
  // }
// }
