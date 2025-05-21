import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:heartcare/view/symptom_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:heartcare/controller/symptom_controller.dart';
import 'package:heartcare/view/app_bar/appbar.dart';
import '../model/provider/user_provider.dart';

class SymptomPage extends StatefulWidget {
  const SymptomPage({super.key});

  @override
  State<SymptomPage> createState() => _SymptomPageState();
}

class _SymptomPageState extends State<SymptomPage> {
  final SymptomController symptomController = SymptomController();
  Map<String, Map<String, dynamic>> userSymptoms = {};
  List<String> activeSymptoms = [];
  List<String> inactiveSymptoms = [];
  List<int> symptomId = [];
  List<int> userSymptomId = [];

  final Map<String, List<double>> symptomSeverityData = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final userId = user!.userID;

    final symptoms = await symptomController.getUserSymptoms(userId);
    final List<String> active = [];
    final List<String> inactive = [];

    final Map<String, List<double>> updatedSeverityData = {};

    // Define our fixed day order (Monday to Sunday)
    const dayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (var symptom in symptoms.keys) {
      final userSymptomId = symptoms[symptom]?['userSymptomId'];
      final severityData = await symptomController.getWeeklySeverityAverages(userSymptomId);

      // Create an ordered list of values
      final orderedValues = dayOrder.map((day) => severityData[day] ?? 0.0).toList();

      updatedSeverityData[symptom] = orderedValues;

      if (symptoms[symptom]?['isActive'] == true) {
        active.add(symptom);
      } else {
        inactive.add(symptom);
      }
    }

    setState(() {
      userSymptoms = symptoms;
      activeSymptoms = active;
      inactiveSymptoms = inactive;
      symptomSeverityData.clear();
      symptomSeverityData.addAll(updatedSeverityData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: RefreshIndicator(
        onRefresh: _initializeData,
        child: ListView(
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                "Symptom Page",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Here you can track how your symptoms are progressing. Each graph shows the average severity of a symptom changed over day.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            _buildSeverityLegend(), // Add legend here instead
            const SizedBox(height: 10),
            _buildSymptomSection("Active Symptoms", activeSymptoms),
            const SizedBox(height: 16),
            _buildSymptomSection("Inactive Symptoms", inactiveSymptoms),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomSection(String title, List<String> symptoms) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (symptoms.isEmpty)
            Card(
              elevation: 2,
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "No ${title.toLowerCase()} symptoms found.",
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...symptoms.map((symptom) => Card(
              elevation: 2,
              color: Colors.grey[100],
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      symptom,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Last Update: ${userSymptoms[symptom]?['lastUpdate'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
                subtitle: SizedBox(height: 80, child: _buildSeverityGraph(symptom)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  final id = userSymptoms[symptom]?['symptomId'];
                  final userSymptomId = userSymptoms[symptom]?['userSymptomId'];
                  final isActive = userSymptoms[symptom]?['isActive'];

                  print("Selected Symptom: $symptom, ID: $id, User log id: $userSymptomId, Active Status: $isActive");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SymptomDetailPage(
                        symptomName: symptom,
                        id: id,
                        userSymptomId: userSymptomId,
                        activeSymptom: isActive,
                      ),
                    ),
                  );
                },
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildSeverityGraph(String symptom) {
    final data = symptomSeverityData[symptom] ?? List.filled(7, 0.0);
    print (data);
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    Color getSeverityColor(double value) {
      if (value == 0) return Colors.grey[400]!; // Null check added
      if (value > 0 && value <= 1) return Colors.green[600]!; // Darker green
      if (value <= 2) return Colors.orange[600]!; // Darker orange
      return Colors.red[700]!; // Deeper red
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SizedBox(
        height: 80,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 3,
            minY: 0,
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.transparent,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return null; // This completely disables tooltips
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < dayLabels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          dayLabels[index],
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  reservedSize: 24,
                ),
              ),
            ),
            barGroups: List.generate(
              data.length,
                  (index) => BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: 3,
                    width: 16,
                    borderRadius: BorderRadius.circular(8),
                    color: getSeverityColor(data[index]), // Light base
                    borderSide: BorderSide(
                      color: getSeverityColor(data[index]),
                      width: 2,
                    ),
                    rodStackItems: [
                      BarChartRodStackItem(
                        0,
                        3,
                        getSeverityColor(data[index]), // Colored fill
                      ),
                    ],
                    backDrawRodData: BackgroundBarChartRodData(
                      show: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Card(
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Severity Level Indicator',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12.0,
                runSpacing: 8.0,
                children: [
                  _legendItem(Colors.green[600]!, "Mild"),
                  _legendItem(Colors.orange[600]!, "Moderate"),
                  _legendItem(Colors.red[700]!, "Severe"),
                  _legendItem(Colors.grey[400]!, "None"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

}


