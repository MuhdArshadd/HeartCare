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

    // Get severity averages for each symptom
    for (var symptom in symptoms.keys) {
      final userSymptomId = symptoms[symptom]?['userSymptomId'];
      final severityData = await symptomController.getWeeklySeverityAverages(userSymptomId);

      updatedSeverityData[symptom] = severityData.values.toList();
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
                "Here you can track how your symptoms are progressing. Each graph shows how the severity of a symptom changed over time.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 24),
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
            Text("No $title symptoms found.", style: const TextStyle(color: Colors.grey)),
          ...symptoms.map((symptom) => Card(
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
                    builder: (context) => SymptomDetailPage(symptomName: symptom, id: id, userSymptomId: userSymptomId, activeSymptom: isActive),
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
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    Color getSeverityColor(double value) {
      if (value <= 1) return Colors.green;
      if (value <= 2) return Colors.orange;
      return Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 3.5,
            minY: 0,
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
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
                      return Text(
                        dayLabels[index],
                        style: const TextStyle(fontSize: 12),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  reservedSize: 32,
                ),
              ),
            ),
            barGroups: List.generate(
              data.length,
                  (index) => BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data[index],
                    width: 18,
                    borderRadius: BorderRadius.circular(6),
                    color: getSeverityColor(data[index]),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: 3,
                      color: Colors.grey.withOpacity(0.1),
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
}
