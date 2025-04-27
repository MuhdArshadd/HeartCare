import 'package:intl/intl.dart';

import '../database_service.dart';

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
              INSERT INTO TREATMENT (user_id, category, treatment_name, notes, treatment_times_id, bool_status, created_at)
              VALUES (@userId, @category, @name, @notes, @timeSlotId, true, NOW())
              RETURNING treatment_id
              """,
              substitutionValues: {
                'userId': userId,
                'category': treatmentData['category'],
                'name': treatmentData['name'],
                'notes': treatmentData['description'] ?? '',
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
              VALUES (@treatmentId, 'Idle', NOW())
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

  Future<List<Map<String, dynamic>>> getTreatment(int userId, DateTime treatmentDate) async {
    if (db.isConnected) {
      try {
        final conn = db.connection!;

        // Step 1: Get all active treatments for the user
        final result = await conn.query(
          """
        SELECT t.treatment_id, t.category, t.treatment_name, t.notes, t.treatment_times_id, 
               tms.dosage_per_intake, tms.unit_of_dosage, tms.quantity_per_session, tms.medication_type
        FROM treatment t
        LEFT JOIN treatment_medication_supplement tms 
        ON t.treatment_id = tms.treatment_id
        WHERE t.user_id = @userId 
        AND t.created_at <= @date
        AND (t.last_treatment_at IS NULL OR @date <= t.last_treatment_at)
        ORDER BY t.treatment_times_id ASC
        """,
          substitutionValues: {
            'userId': userId,
          },
        );

        List<Map<String, dynamic>> treatments = [];

        // Step 2: For each treatment, get its logs
        for (final row in result) {
          int treatmentId = row[0];

          final logsResult = await conn.query(
            """
          SELECT status, recorded_at
          FROM treatment_log
          WHERE treatment_id = @treatmentId AND recorded_at = @date
          """,
            substitutionValues: {
              'treatmentId': treatmentId,
              'date': DateFormat('yyyy-MM-dd').format(treatmentDate)
            },
          );

          List<Map<String, dynamic>> logs = logsResult.map((logRow) {
            return {
              'status': logRow[0] ?? "Idle",
              'recorded_at': logRow[1],
            };
          }).toList();

          // Step 3: Build the final treatment object
          Map<String, dynamic> treatment = {
            'treatment_id': row[0],
            'category': row[1],
            'name': row[2],
            'notes': row[3],
            'treatment_times_id': row[4],
            'dosage_per_intake': row[5],
            'unit_of_dosage': row[6],
            'quantity_per_session': row[7],
            'medication_type': row[8],
            'logs': logs,
          };

          treatments.add(treatment);
        }

        return treatments;

      } catch (e) {
        print('Error in getTreatment: $e');
        return [];
      }
    }
    return [];

/*[
  {
    "treatment_id": 1,
    "category": "Diet",
    "name": "Low Sodium Diet",
    "notes": "Avoid salty foods",
    "treatment_times_id": 1,
    "dosage_per_intake": null,
    "unit_of_dosage": null,
    "quantity_per_session": null,
    "medication_type": null,
    "logs": [
      {
        "status": "Completed", (Completed, Skipped, Idle)
        "recorded_at": "2025-04-27T08:00:00Z"
      }
    ]
  },
  ...
]*/
  }

  Future<bool> updateStatusTreatment(int treatmentId) async {
    if (db.isConnected) {
      try {
        // Check if a treatment log exists on the specified date
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

  Future<bool> logTreatment(int userId, int treatmentLogId, int treatmentId, DateTime date, String status) async {
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
