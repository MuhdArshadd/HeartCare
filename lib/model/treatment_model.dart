import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TreatmentTimeline {
  final int id;
  final String name;
  final String timeRange;
  final IconData icon;
  final List<TreatmentTask> treatments;

  TreatmentTimeline({
    required this.id,
    required this.name,
    required this.timeRange,
    required this.icon,
    required this.treatments,
  });
}

class TreatmentTask {
  final int id;
  final String treatmentCategory;
  final IconData icon;
  final String name;
  final int treatmentTimesId;
  final double? dosage;
  final String? unit;
  final int? sessionCount;
  final String? medicationType;
  final String? notes;
  bool isCompleted;
  bool isSkipped;
  DateTime? lastActionTime;

  TreatmentTask({
    required this.id,
    required this.treatmentCategory,
    required this.icon,
    required this.name,
    required this.treatmentTimesId,
    this.dosage,
    this.unit,
    this.sessionCount,
    this.medicationType,
    this.notes,
    this.isCompleted = false,
    this.isSkipped = false,
    this.lastActionTime,
  });
}
