import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heartcare/view/popup_screen/loading_processing_popup.dart';
import 'package:intl/intl.dart';
import '../controller/symptom_controller.dart';

class SymptomDetailPage extends StatefulWidget {
  final String symptomName;
  final int id;
  final int userSymptomId;
  final bool activeSymptom;

  const SymptomDetailPage({Key? key, required this.symptomName, required this.id, required this.userSymptomId, required this.activeSymptom,}) : super(key: key);

  @override
  _SymptomDetailPageState createState() => _SymptomDetailPageState();
}

class _SymptomDetailPageState extends State<SymptomDetailPage> {
  final SymptomController symptomController = SymptomController();

  //Symptom Status Card
  bool _isActive = true; // Temporary default

  //Fetch symptom's log from database:
  late Future<List<Map<String, dynamic>>> _symptomLogsFuture;

  //Cards
  String _notes = '';
  String _severity = 'Low';
  bool _isSubmitting = false;

  //Picker data
  TimeOfDay? _symptomTime;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _isActive = widget.activeSymptom; // Set to current activation status
    _loadSymptomLogs(); // Fetch logs initially
  }

  void _loadSymptomLogs() {
    setState(() {
      _symptomLogsFuture = symptomController.fetchSymptomLogs(widget.userSymptomId, selectedDate);
    });
  }

  Future<void> _submitLog() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call

    try {
      bool result = await symptomController.addSymptomLog(
        widget.userSymptomId,
        selectedDate,
        _symptomTime!,
        _severity,
        _notes,
      );

      if (result) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            actionsPadding: const EdgeInsets.only(right: 16, bottom: 10),
            title: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                ),
                const SizedBox(width: 10),
                Text(
                  "Success",
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Text(
              "Successfully Added!",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _loadSymptomLogs(); // Reload symptom logs after successful addition
                  });
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            actionsPadding: const EdgeInsets.only(right: 16, bottom: 10),
            title: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                ),
                const SizedBox(width: 10),
                Text(
                  "Error",
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Text(
              "Failed to log symptoms.",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("Error: ${e.toString()}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
        _loadSymptomLogs(); // reload
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.symptomName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Date Picker
            Text("Log Date", style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            )),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                // Haptic feedback for better interaction
                await HapticFeedback.lightImpact();

                // To get the picked date
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: colorScheme.primary, // header background color
                          onPrimary: Colors.white, // header text color
                          onSurface: Colors.black87, // body text color
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.primary, // button text color
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null && picked != selectedDate) {
                  setState(() {
                    selectedDate = picked; // set the selected date
                    _loadSymptomLogs(); // and reload the symptom logs based on chosen date
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_month,
                            size: 20,
                            color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('MMMM d, y').format(selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Symptom Status Card
            _buildStatusCard(colorScheme, widget.userSymptomId, widget.id),
            const SizedBox(height: 24),
            // Symptom Log Section
            _buildLogSection(),
            const SizedBox(height: 24),
            // Log Symptom Section
            _buildLogForm(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(colorScheme, int userId, int symptomId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blueAccent, size: 25),
            const SizedBox(width: 8),
            _buildSectionTitle('Symptom Status'),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.grey[100],
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Is this symptom still active?',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusButton(
                        text: 'No',
                        isSelected: !_isActive,
                        onTap: () => _confirmSymptomStatusChange(false, userId, symptomId),
                        colorScheme: colorScheme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatusButton(
                        text: 'Yes',
                        isSelected: _isActive,
                        onTap: () => _confirmSymptomStatusChange(true, userId, symptomId),
                        colorScheme: colorScheme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _isActive ? 'You\'re currently experiencing this symptom' : 'This symptom is no longer active',
                  style: TextStyle(
                    fontSize: 13,
                    color: _isActive ? colorScheme.primary : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmSymptomStatusChange(bool newStatus, int userId, int symptomId) async {
    //Get the confirmed value (true or false)
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        title: const Text(
          'Confirm Status Change',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.help_outline,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to mark this symptom as ${newStatus ? 'active' : 'inactive'}?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );

    // Update the active status of the symptom
    if (confirmed == true) {
      try {
        // Call the updateSymptomStatus function to update the database
        bool updateResult = await symptomController.updateSymptomStatus(userId, symptomId, newStatus);

        if (updateResult) {
          setState(() {
            _isActive = newStatus; // Update the active status in the UI
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thanks for letting us know!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          // Handle failure in updating the status (optional)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update symptom status.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        print("Error updating symptom status: $e");

        // Show an error message in case of any exception
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

  }

  Widget _buildStatusButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? colorScheme.primary : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: Colors.brown, size: 25),
            const SizedBox(width: 8),
            _buildSectionTitle('Your Symptom History'),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.grey[100],
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _symptomLogsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Failed to load logs',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  );
                }
                final logs = snapshot.data!;
                if (logs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No symptoms logged yet. Track your first entry below!',
                      style: TextStyle(color: Colors.black38),
                    ),
                  );
                }
                return Column(
                  children: logs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final log = entry.value;
                    return Column(
                      children: [
                        if (index != 0)
                          Divider(height: 1, color: Colors.grey[200]),
                        _buildLogItem(log),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log) {
    Color severityColor;
    switch (log['severity']) {
      case 'High':
        severityColor = Colors.redAccent;
        break;
      case 'Medium':
        severityColor = Colors.orange;
        break;
      default:
        severityColor = Colors.green;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: severityColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            _getSeverityIcon(log['severity']),
            color: severityColor,
            size: 20,
          ),
        ),
      ),
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${log['severity']} severity',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: severityColor,
              ),
            ),
            const TextSpan(text: ' • '),
            TextSpan(
              text: log['date'],
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              log['notes'] ?? 'No notes',
              style: const TextStyle(fontSize: 14),
            ),
            if (log['time'] != null)
              Text(
                'Recorded at: ${log['time']}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'High':
        return Icons.warning_amber_rounded;
      case 'Medium':
        return Icons.error_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Widget _buildLogForm(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.add_circle_outline, color: Colors.green, size: 25),
            const SizedBox(width: 8),
            _buildSectionTitle('Track Your Symptom'),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.grey[100],
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimePicker(colorScheme),
                const SizedBox(height: 16),
                const Text(
                  'How severe is it today?',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
                const SizedBox(height: 12),
                _buildSeveritySelector(colorScheme),
                const SizedBox(height: 20),
                const Text(
                  'Add notes (optional)',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
                const SizedBox(height: 8),
                _buildNotesField(),
                const SizedBox(height: 20),
                _buildSubmitButton(colorScheme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeveritySelector(ColorScheme colorScheme) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: ['Low', 'Medium', 'High'].map((level) {
        final isSelected = _severity == level;
        Color chipColor;
        switch (level) {
          case 'High':
            chipColor = Colors.redAccent;
            break;
          case 'Medium':
            chipColor = Colors.orange;
            break;
          default:
            chipColor = Colors.green;
        }

        return ChoiceChip(
          label: Text(level),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() => _severity = level);
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          showCheckmark: false,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : chipColor,
            fontWeight: FontWeight.w500,
          ),
          backgroundColor: chipColor.withOpacity(0.1),
          selectedColor: chipColor,
          side: BorderSide.none,
        );
      }).toList(),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Describe your experience today...',
        hintStyle: const TextStyle(color: Colors.black26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      style: const TextStyle(fontSize: 14),
      onChanged: (value) => setState(() => _notes = value),
    );
  }

  Widget _buildSubmitButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: _isSubmitting ? null : _submitLog,
        child: _isSubmitting
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Text(
          'Add Today\'s Log',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'When did it happen?',
          style: TextStyle(fontSize: 15, color: Colors.black),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.access_time),
          label: Text(
            _symptomTime != null
                ? _symptomTime!.format(context)
                : 'Select time',
          ),
          onPressed: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null) {
              setState(() => _symptomTime = picked);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}