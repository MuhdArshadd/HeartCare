import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database_service.dart';
import '../model/treatment_model.dart';

class TreatmentController {
  final db = DatabaseConnection();

  Future<bool> addTreatment(int userId, Map<String, dynamic> treatmentData) async {
    if (db.isConnected) {
      final conn = db.connection;
      try {
        await conn!.transaction((ctx) async {
          // Loop through each time of day
          for (String timeOfDay in treatmentData['timesOfDay']) {
            int timeSlotId = getTimeSlotId(timeOfDay);

            // Insert into TREATMENT table
            final result = await ctx.query(
              """
              INSERT INTO TREATMENT (user_id, category, treatment_name, notes, treatment_times_id, created_at)
              VALUES (@userId, @category, @name, @notes, @timeSlotId, NOW())
              RETURNING treatment_id
              """,
              substitutionValues: {
                'userId': userId,
                'category': treatmentData['category'],
                'name': treatmentData['name'],
                'notes': treatmentData['description'],
                'timeSlotId': timeSlotId,
              },
            );

            int treatmentId = result.first[0]; // Get the inserted treatment ID

            // If the category is Medication or Supplement, insert additional details
            if (treatmentData['category'] == 'Medication' || treatmentData['category'] == 'Supplement') {
              await ctx.query(
                """
                INSERT INTO TREATMENT_MEDICATION_SUPPLEMENT (treatment_id, dosage_per_intake, unit_of_dosage, quantity_per_session, medication_type)
                VALUES (@treatmentId, @dosage, @unit, @quantity, @type)
                """,
                substitutionValues: {
                  'treatmentId': treatmentId,
                  'dosage': treatmentData['dosage'] ?? '',
                  'unit': treatmentData['unit'] ?? '',
                  'quantity': treatmentData['quantity'] ?? '',
                  'type': treatmentData['type'] ?? '',
                },
              );
            }

            //Add the symptoms log according to current date (the symptom starts right after the user add)
            await ctx.query(
              """
              INSERT INTO TREATMENT_LOG (treatment_id, status, recorded_at)
              VALUES (@treatmentId, 'Pending', NOW())
              """,
              substitutionValues: {
                'treatmentId': treatmentId
              },
            );
          }
        });
        return true;
      } catch (e) {
        print('Error in addTreatment: $e');
        return false;
      }
    }
    return false;
  }

  Future<List<TreatmentTimeline>> getTreatment(String page, int userId, DateTime treatmentDate) async {
    if (db.isConnected) {
      try {
        final conn = db.connection!;
        List<List<dynamic>> result = [];
        int treatmentTimeID = getTimelineIdFromHour(treatmentDate.hour);
        print (treatmentTimeID);

        // Step 1: Get all active treatments for the user based on page
        if (page == "Treatment"){
          result = await conn.query(
            """
        SELECT t.treatment_id, t.category, t.treatment_name, t.notes, t.treatment_times_id, 
               tms.dosage_per_intake, tms.unit_of_dosage, tms.quantity_per_session, tms.medication_type
        FROM treatment t
        LEFT JOIN treatment_medication_supplement tms 
        ON t.treatment_id = tms.treatment_id
        WHERE t.user_id = @userId 
        AND t.created_at <= @date
        AND (t.last_treatment_at IS NULL OR @date < t.last_treatment_at)
        ORDER BY t.treatment_times_id ASC
        """,
            substitutionValues: {
              'userId': userId,
              'date': DateFormat('yyyy-MM-dd').format(treatmentDate),
            },
          );
        } else if (page == "Homepage"){
          result = await conn.query(
            """
        SELECT t.treatment_id, t.category, t.treatment_name, t.notes, t.treatment_times_id, 
               tms.dosage_per_intake, tms.unit_of_dosage, tms.quantity_per_session, tms.medication_type
        FROM treatment t
        LEFT JOIN treatment_medication_supplement tms 
        ON t.treatment_id = tms.treatment_id
        WHERE t.user_id = @userId 
        AND t.created_at <= @date
        AND (t.last_treatment_at IS NULL OR @date <= t.last_treatment_at)
        AND t.treatment_times_id = @timelineId
        ORDER BY t.treatment_times_id ASC
        LIMIT 2
        """,
            substitutionValues: {
              'userId': userId,
              'date': DateFormat('yyyy-MM-dd').format(treatmentDate),
              'timelineId': treatmentTimeID
            },
          );
        }
        // Step 2: Organize the treatments by their timeline ID (e.g., Morning, Afternoon, etc.)
        Map<int, TreatmentTimeline> timelineMap = {};

        // Step 3: For each treatment, get its logs and map to the appropriate timeline
        for (final row in result) {
          int treatmentId = row[0];
          int treatmentTimesId = row[4]; // This will correspond to your timeline ID (Morning, Afternoon, etc.)

          final logsResult = await conn.query(
            """
          SELECT status
          FROM treatment_log
          WHERE treatment_id = @treatmentId AND recorded_at = @date
          """,
            substitutionValues: {
              'treatmentId': treatmentId,
              'date': DateFormat('yyyy-MM-dd').format(treatmentDate)
            },
          );

          // DEBUG: Print raw log rows before mapping
          for (final logRow in logsResult) {
            print('Fetched logRow[0] (status): ${logRow[0]}');
          }

          List<Map<String, dynamic>> logs = logsResult.map((logRow) {
            return {
              'status': logRow[0] ?? "Pending",
            };
          }).toList();

          // Step 4: Create TreatmentTask object
          TreatmentTask task = TreatmentTask(
            id: row[0], // treatment_id
            treatmentCategory: row[1], // category (e.g., Diet, Medication)
            icon: getCategoryIcon(row[1]),
            name: row[2], // treatment_name
            treatmentTimesId: treatmentTimesId,
            dosage: row[5], // dosage_per_intake
            unit: row[6], // unit_of_dosage
            sessionCount: row[7], // quantity_per_session
            medicationType: row[8], // medication_type
            notes: row[3], // notes
            isCompleted: logs.any((log) => log['status'] == 'Completed'),
            isSkipped: logs.any((log) => log['status'] == 'Skipped'),
            lastActionTime: DateTime.now(), // You can adjust this if you have specific timestamps
          );

          // Step 5: Add the task to the correct timeline
          if (!timelineMap.containsKey(treatmentTimesId)) {
            timelineMap[treatmentTimesId] = TreatmentTimeline(
              id: treatmentTimesId,
              name: getTimelineName(treatmentTimesId), // Map timeline ID to name
              timeRange: getTimeRange(treatmentTimesId), // Map timeline ID to time range
              icon: getTimelineIcon(treatmentTimesId), // Map timeline ID to icon
              treatments: [],
            );
          }

          timelineMap[treatmentTimesId]?.treatments.add(task);
        }
        // DEBUG: Print all fetched data grouped by timelines
        for (final timeline in timelineMap.values) {
          print('---');
          print('Timeline ID: ${timeline.id}');
          print('Name: ${timeline.name}');
          print('Time Range: ${timeline.timeRange}');
          print('Icon: ${timeline.icon}');
          print('Treatments:');

          for (final treatment in timeline.treatments) {
            print('  - Treatment ID: ${treatment.id}');
            print('    Category: ${treatment.treatmentCategory}');
            print('    Name: ${treatment.name}');
            print('    Notes: ${treatment.notes}');
            print('    Dosage: ${treatment.dosage}');
            print('    Unit: ${treatment.unit}');
            print('    Session Count: ${treatment.sessionCount}');
            print('    Medication Type: ${treatment.medicationType}');
            print('    Is Completed: ${treatment.isCompleted}');
            print('    Is Skipped: ${treatment.isSkipped}');
            print('    Icon: ${treatment.icon}');
            print('    Last Action Time: ${treatment.lastActionTime}');
          }
        }

        // Step 6: Return the list of TreatmentTimelines
        return timelineMap.values.toList();

      } catch (e) {
        print('Error in getTreatment: $e');
        return [];
      }
    }
    return [];
  }

/*[
  {
    "treatment_id": 1,
    "category": "Diet", // There are 4 category (Medication, Supplement, Diet, Physical Activity)
    "name": "Low Sodium Diet",
    "notes": "Avoid salty foods", // No notes or have notes
    "treatment_times_id": 1, // 1 to 4
    "dosage_per_intake": null, // Applicable to Medication or Supplement only
    "unit_of_dosage": null, // ('mg', 'ml', 'g', 'IU') - Applicable to Medication or Supplement only
    "quantity_per_session": null, // Applicable to Medication or Supplement only
    "medication_type": null, // ('Tablet', 'Capsule', 'Liquid', 'Injection') - Applicable to Medication or Supplement only
    "logs": [
      {
        "status": "Completed", (Completed, Skipped, Pending)
      }
    ]
  },
  ...
]*/

  Future<bool> updateStatusTreatment(int treatmentId) async {
    if (db.isConnected) {
      try {
        await db.connection!.query(
          """
          UPDATE TREATMENT
          SET last_treatment_at = NOW()
          WHERE treatment_id = @treatmentId
          """,
          substitutionValues: {
            'treatmentId': treatmentId,
          },
        );

        return true;
      } catch (e) {
        print("Error update treatment status: $e");
        return false;
      }
    } else {
      print("Database not connected.");
      return false;
    }
  }

  Future<bool> logTreatment(int userId, int treatmentId, DateTime date, String status) async {
    if (db.isConnected) {
      try {
        final conn = db.connection!;

        // Check if a treatment log exists on the specified date
        final result = await conn.query(
          """
        SELECT treatment_log_id
        FROM treatment_log
        WHERE treatment_id = @treatmentId AND recorded_at = @date
        """,
          substitutionValues: {
            'treatmentId': treatmentId,
            'date': DateFormat('yyyy-MM-dd').format(date),
          },
        );

        if (result.isNotEmpty) {
          // Log exists, update it
          int existingLogId = result.first[0];

          await conn.query(
            """
          UPDATE treatment_log
          SET status = @status, recorded_at = @date
          WHERE treatment_log_id = @logId
          """,
            substitutionValues: {
              'status': status,
              'date': date, // Passing DateTime directly
              'logId': existingLogId,
            },
          );
        } else {
          // No log exists, insert new
          await conn.query(
            """
          INSERT INTO treatment_log (treatment_id, status, recorded_at)
          VALUES (@treatmentId, @status, @date)
          """,
            substitutionValues: {
              'treatmentId': treatmentId,
              'status': status,
              'date': date, // Passing DateTime directly
            },
          );
        }
        return true;
      } catch (e) {
        print("Error logging treatment: $e");
        return false;
      }
    } else {
      print("Database not connected.");
      return false;
    }
  }

  Future<List<int>> getTreatmentTimelineID(int userID) async {
    if (db.isConnected) {
      try {
        final results = await db.connection!.query(
          """
        SELECT DISTINCT treatment_times_id
        FROM TREATMENT
        WHERE user_id = @userid
          AND created_at <= NOW()
          AND (last_treatment_at IS NULL OR NOW() <= last_treatment_at)
        """,
          substitutionValues: {
            'userid': userID,
          },
        );

        return results.map((row) => row[0] as int).toList();
      } catch (error) {
        print(error);
        return [];
      }
    } else {
      return [];
    }
  }


  int getTimeSlotId(String timeOfDay) {
    if (timeOfDay.contains('Morning')) {
      return 1;
    } else if (timeOfDay.contains('Afternoon')) {
      return 2;
    } else if (timeOfDay.contains('Evening')) {
      return 3;
    } else if (timeOfDay.contains('Night')) {
      return 4;
    } else {
      throw Exception('Invalid time of day: $timeOfDay');
    }
  }
}

String getTimelineName(int treatmentTimesId) {
  switch (treatmentTimesId) {
    case 1:
      return 'Morning';
    case 2:
      return 'Afternoon';
    case 3:
      return 'Evening';
    case 4:
      return 'Night';
    default:
      return 'Unknown';
  }
}

String getTimeRange(int treatmentTimesId) {
  switch (treatmentTimesId) {
    case 1:
      return '6:00 AM – 11:59 AM';
    case 2:
      return '12:00 PM – 5:59 PM';
    case 3:
      return '6:00 PM – 8:59 PM';
    case 4:
      return '9:00 PM – 5:59 AM';
    default:
      return 'Unknown';
  }
}

int getTimelineIdFromHour(int hour) {
  if (hour >= 6 && hour < 12) {
    return 1; // Morning
  } else if (hour >= 12 && hour < 18) {
    return 2; // Afternoon
  } else if (hour >= 18 && hour < 21) {
    return 3; // Evening
  } else {
    return 4; // Night
  }
}

IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Medication':
      return Icons.medication;
    case 'Supplement':
      return Icons.local_pharmacy;
    case 'Diet':
      return Icons.restaurant;
    case 'Physical Activity':
      return Icons.directions_run;
    default:
      return Icons.help_outline;
  }
}

IconData getTimelineIcon(int treatmentTimesId) {
  switch (treatmentTimesId) {
    case 1:
      return Icons.wb_sunny;
    case 2:
      return Icons.light_mode;
    case 3:
      return Icons.nights_stay;
    case 4:
      return Icons.bedtime;
    default:
      return Icons.help_outline;
  }
}