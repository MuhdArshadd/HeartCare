import 'package:flutter/material.dart';

class HealthInfoSheet extends StatelessWidget {
  final String readingType;

  const HealthInfoSheet({required this.readingType, super.key});

  @override
  Widget build(BuildContext context) {
    // Mock category data for illustration
    final Map<String, List<Map<String, String>>> readingCategories = {
      "Blood Pressure": [
        {"category": "Normal", "range": "Below 120/80 mmHg"},
        {"category": "Elevated", "range": "120-129/Below 80 mmHg"},
        {"category": "Stage 1 Hypertension", "range": "130-139/80-89 mmHg"},
        {"category": "Stage 2 Hypertension", "range": "140+/90+ mmHg"},
      ],

      "Blood Sugar": [
        {"category": "Normal", "range": "Below 100 mg/dL"},
        {"category": "Prediabetes", "range": "100-125 mg/dL"},
        {"category": "Diabetes", "range": "126+ mg/dL"},
      ],

      "Cholesterol Level": [
        {"category": "Healthy", "range": "125-200 mg/dL"},
        {"category": "Borderline High", "range": "201-239 mg/dL"},
        {"category": "High", "range": "240+ mg/dL"},
        {"category": "Hypocholesterolemia", "range": "Below 125 mg/dL"},
      ],

      "BMI": [
        {"category": "Underweight", "range": "Below 18.5"},
        {"category": "Healthy", "range": "18.5-24.9"},
        {"category": "Pre-obesity", "range": "25-29.9"},
        {"category": "Obesity Class I", "range": "30-34.9"},
        {"category": "Obesity Class II", "range": "35-39.9"},
        {"category": "Obesity Class III", "range": "40+"},
      ],
    };

    final infoList = readingCategories[readingType] ?? [];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollController,
          children: [
            Center(
              child: Text(
                "$readingType Info",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ...infoList.map((info) => ListTile(
              leading: const Icon(Icons.info, color: Colors.teal),
              title: Text(info['category']!),
              subtitle: Text(info['range']!),
            )),
          ],
        ),
      ),
    );
  }
}
