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
          WHERE user_id = @userId AND bool_symptom_active = true
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


}