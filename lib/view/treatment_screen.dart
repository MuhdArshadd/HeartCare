import 'package:flutter/material.dart';
import 'package:heartcare/controller/treatment_controller.dart';
import 'package:heartcare/view/app_bar/appbar.dart';
import 'package:provider/provider.dart';
import '../model/provider/user_provider.dart';
import '../model/treatment_model.dart';

class TreatmentPage extends StatefulWidget {
  const TreatmentPage({Key? key}) : super(key: key);

  @override
  State<TreatmentPage> createState() => _TreatmentPageState();
}

class _TreatmentPageState extends State<TreatmentPage> {
  final TreatmentController treatmentController = TreatmentController();

  DateTime _selectedDate = DateTime.now();
  double _dailyProgress = 0.0;
  bool _isLoading = true;
  bool _hasError = false;

  late List<TreatmentTimeline> _displayTimelines = [];

  @override
  void initState() {
    super.initState();
    _loadTreatmentData();
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

  Future<void> _loadTreatmentData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;

      await Future.delayed(const Duration(milliseconds: 500));
      final fetched = await treatmentController.getTreatment(user!.userID, _selectedDate);

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
    final completed = _displayTimelines.fold(
      0,
          (sum, t) => sum + t.treatments.where((task) => task.isCompleted).length,
    );
    setState(() {
      _dailyProgress = total > 0 ? completed / total : 0.0;
    });
  }

  void _onToggleStatus(int timelineId, int taskId, bool isComplete) {
    setState(() {
      final timeline = _displayTimelines.firstWhere((t) => t.id == timelineId);
      final task = timeline.treatments.firstWhere((t) => t.id == taskId);
      task.isCompleted = isComplete;
      task.isSkipped = !isComplete;
      task.lastActionTime = DateTime.now();
      _updateProgress();
    });
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
        onRefresh: _loadTreatmentData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              'Treatment Plan',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
            ...(_displayTimelines.isEmpty ? [ _buildNoTimelineMessage() ] : _displayTimelines.map((timeline) => _buildTimelineSection(timeline)).toList()),
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

  Widget _buildNoTimelineMessage() {
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

  Widget _buildTimelineSection(TreatmentTimeline timeline) {
    final hasTreatments = timeline.treatments.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(timeline.icon, size: 32),
            title: Text(
              timeline.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(timeline.timeRange),
          ),
          const SizedBox(height: 8),
          if (hasTreatments)
            ...timeline.treatments.map((task) => _buildTreatmentCard(timeline.id, task)).toList()
          else
            _buildNoTreatmentCard(),
        ],
      ),
    );
  }

  Widget _buildTreatmentCard(int timelineId, TreatmentTask task) {
    return Container(
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
              Icon(task.icon, color: Colors.blueGrey), // Use any color you like
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
              TextButton.icon(
                icon: Icon(task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked),
                label: Text(task.isCompleted ? 'Completed' : 'Mark Complete'),
                onPressed: () => _onToggleStatus(timelineId, task.id, true),
              ),
              TextButton.icon(
                icon: Icon(task.isSkipped ? Icons.cancel : Icons.remove_circle_outline),
                label: Text(task.isSkipped ? 'Skipped' : 'Skip'),
                onPressed: () => _onToggleStatus(timelineId, task.id, false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoTreatmentCard() {
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
