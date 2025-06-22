import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database_service.dart';

class SymptomController {
  final db = DatabaseConnection();

  Future<bool> addSymptom(int userId, List<int> selectedIds, bool symptomActive) async {
    if (db.isConnected) {
      try {
        for (int symptomId in selectedIds) {
          // Insert new symptom record
          await db.connection!.query(
            """
          INSERT INTO user_symptom (user_id, symptom_id, bool_symptom_active, last_update)
          VALUES (@userId, @symptomId, @symptomActive, NOW())
          """,
            substitutionValues: {
              'userId': userId,
              'symptomId': symptomId,
              'symptomActive': symptomActive,
            },
          );
        }
        return true;
      } catch (e) {
        print("Error adding symptom: $e");
        return false;
      }
    } else {
      print("Database not connected.");
      return false;
    }
  }

  Future<List<int>> getSymptomsActiveID(int userId) async {
    List<int> userSymptoms = [];

    if (db.isConnected) {
      try {
        final results = await db.connection!.query(
          """
          SELECT symptom_id
          FROM USER_SYMPTOM
          WHERE user_id = @userId
          """,
          substitutionValues: {
            'userId': userId,
          },
        );
        for (final row in results) {
          userSymptoms.add(row[0] as int);
        }
        return userSymptoms;
      } catch (e) {
        print("Error fetching symptoms: $e");
        return [];
      }
    } else {
      print("Database not connected.");
      return [];
    }
  }

  Future<Map<String, Map<String, dynamic>>> getUserSymptoms(int userId) async {
    final Map<String, Map<String, dynamic>> userSymptoms = {};

    if (db.isConnected) {
      try {
        final results = await db.connection!.query(
          """
        SELECT s.symptom_name, us.bool_symptom_active, us.last_update, us.user_symptom_id, us.symptom_id
        FROM symptom s 
        JOIN user_symptom us ON s.symptom_id = us.symptom_id
        WHERE us.user_id = @userId
        """,
          substitutionValues: {
            'userId': userId,
          },
        );

        for (final row in results) {
          final symptomName = row[0] as String;
          final isActive = row[1] as bool;
          final lastUpdate = row[2] as DateTime;
          final userSymptomId = row[3] as int;
          final symptomId = row[4] as int;

          userSymptoms[symptomName] = {
            'isActive': isActive,
            'lastUpdate': '${lastUpdate.day}/${lastUpdate.month}/${lastUpdate.year}',
            'userSymptomId': userSymptomId,
            'symptomId': symptomId
          };
        }
        return userSymptoms;
      } catch (e) {
        print("Error fetching symptoms: $e");
        return {};
      }
    } else {
      print("Database not connected.");
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> fetchSymptomLogs(int userSymptomId, DateTime symptomDate) async {
    final List<Map<String, dynamic>> symptomLogs = [];

    if (db.isConnected) {
      try {
        final results = await db.connection!.query(
          """
        SELECT 
          usl.recorded_at_date, 
          to_char(usl.recorded_at_time, 'HH24:MI') AS recorded_time,
          usl.severity, 
          usl.notes
        FROM USER_SYMPTOM_LOG usl
        WHERE usl.user_symptom_id = @usersymptomid AND usl.recorded_at_date = @date
        """,
          substitutionValues: {
            'usersymptomid': userSymptomId,
            'date': DateFormat('yyyy-MM-dd').format(symptomDate)
          },
        );

        print("Results fetched: $results");

        for (final row in results) {
          try {
            final DateTime recordDate = row[0] as DateTime;
            final String recordTimeString = row[1] as String;

            // Parse time string like "14:25"
            final TimeOfDay recordTime = _parseTimeFromString(recordTimeString);

            final int severity = row[2];
            final String notes = row[3]?.toString() ?? '';

            symptomLogs.add({
              'date': '${recordDate.day}/${recordDate.month}/${recordDate.year}',
              'time': _formatTo12Hour(recordTime),
              'severity': _severityLevelText(severity),
              'notes': notes,
            });
          } catch (e) {
            print("Error parsing row: $e");
          }
        }

        return symptomLogs;
      } catch (e) {
        print("Error fetching symptom logs: $e");
        return [];
      }
    } else {
      print("Database not connected.");
      return [];
    }
  }

  Future<bool> updateSymptomStatus(int userLogId, int symptomId, bool activeStatus) async {
    if (db.isConnected) {
      try {
        await db.connection!.query(
          """
          UPDATE user_symptom
          SET bool_symptom_active = @activeStatus, last_update = NOW()
          WHERE user_symptom_id = @userLogId AND symptom_id = @symptomId
          """,
          substitutionValues: {
            'userLogId': userLogId,
            'symptomId': symptomId,
            'activeStatus': activeStatus,
          },
        );
        return true;
      } catch (e) {
        print("Error updating symptom active status: $e");
        return false;
      }
    } else {
      print("Database not connected.");
      return false;
    }
  }

  Future<bool> addSymptomLog(int userSymptomLogId, DateTime logDate, TimeOfDay logTime, String logSeverity, String logNotes) async {
    int _severityLevelIndex = 0;

    if (db.isConnected) {
      try {
        _severityLevelIndex = _severityLevel(logSeverity);

        await db.connection!.query(
          """
          INSERT INTO USER_SYMPTOM_LOG (user_symptom_id, recorded_at_date, recorded_at_time, severity, notes)
          VALUES (@user_symptom_id, @date, @time, @severity, @notes)
          """,
          substitutionValues: {
            'user_symptom_id': userSymptomLogId,
            'date': DateFormat('yyyy-MM-dd').format(logDate),
            'time': "${logTime.hour.toString().padLeft(2, '0')}:${logTime.minute.toString().padLeft(2, '0')}:00",
            'severity': _severityLevelIndex,
            'notes': logNotes,
          },
        );
        return true;
      } catch (e) {
        print("Error adding symptom log: $e");
        return false;
      }
    } else {
      print("Database not connected.");
      return false;
    }
  }

  Future<Map<String, double>> getWeeklySeverityAverages(int userSymptomId) async {
    final Map<String, double> dailyAverages = {};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final dayLabel = DateFormat('E').format(date); // "Mon", "Tue", etc.

      print("Checking severity for: $dayLabel, Date: ${DateFormat('yyyy-MM-dd').format(date)}");

      final averageSeverity = await getSymptomLogsByDate(userSymptomId, date);
      dailyAverages[dayLabel] = averageSeverity;
    }

    return dailyAverages;
  }

  Future<double> getSymptomLogsByDate(int userSymptomId, DateTime date) async {
    if (db.isConnected) {
      try {
        final result = await db.connection!.query(
          """
      SELECT AVG(severity) AS average_severity
      FROM USER_SYMPTOM_LOG
      WHERE user_symptom_id = @user_symptom_id AND recorded_at_date = @date
      """,
          substitutionValues: {
            'user_symptom_id': userSymptomId,
            'date': DateFormat('yyyy-MM-dd').format(date),
          },
        );

        print(result.first[0]);

        if (result.isNotEmpty && result.first[0] != null) {
          // First try parsing as double, then as int if that fails
          final value = result.first[0];
          if (value is num) {
            return value.toDouble();
          } else if (value is String) {
            return double.tryParse(value) ?? 0.0;
          } else {
            return 0.0;
          }
        } else {
          return 0.0; // not logged during that day
        }
      } catch (e) {
        print("Error retrieving average severity: $e");
        return 0.0;
      }
    } else {
      print("Database not connected.");
      return 0.0;
    }
  }

  String _severityLevelText (int severity) {
    if (severity == 1){
      return "Low";
    } else if (severity == 2){
      return "Medium";
    } else if (severity == 3) {
      return "High";
    }
    return "N/A";
  }

  int _severityLevel (String severity) {
    if (severity == "Low"){
      return 1;
    } else if (severity == "Medium"){
      return 2;
    } else if (severity == "High") {
      return 3;
    }
    return 0;
  }

  String _formatTo12Hour(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '${hour12}:${minute.toString().padLeft(2, '0')} $suffix';
  }

  TimeOfDay _parseTimeFromString(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

}