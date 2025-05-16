import 'dart:typed_data';
import '../database_service.dart';
import 'dart:convert';
import '../model/user_model.dart';
import 'package:crypto/crypto.dart';

class UserController {
  final db = DatabaseConnection();

  Future<bool> userSignUp(UserModel user) async {
    if (db.isConnected) {
      try {
        // Convert image bytes to base64 string if the profile image exists
        if (user.profileImage != null && user.profileImage!.isNotEmpty) {
          final base64Image = base64Encode(user.profileImage!);

          await db.connection!.query(
            '''
            INSERT INTO users (
              username, fullname, email_address, password, profile_image
            ) 
            VALUES (
              @username, @fullname, @email_address, @password, decode(@profile_image, 'base64')
            )
            ''',
            substitutionValues: {
              'username': user.username,
              'fullname': user.fullname,
              'email_address': user.emailAddress,
              'password': user.password,
              'profile_image': base64Image
            },
          );
        }
        else {
          // Perform the insert operation without a profile image
          await db.connection!.query(
            '''
            INSERT INTO users (
              username, fullname, email_address, password
            ) 
            VALUES (
              @username, @fullname, @email_address, @password
            )
            ''',
            substitutionValues: {
              'username': user.username,
              'fullname': user.fullname,
              'email_address': user.emailAddress,
              'password': user.password
            },
          );
        }
        return true;
      } catch (e) {
        print("Error signing up: $e");
        return false;
      }
    } else {
      print("No database connection available.");
      return false;
    }
  }

  Future<String> userCompleteProfile(UserModel user) async {
    bool userObese = false;
    final userBMI = user.bodyWeight! / (user.height! * user.height!);

    if (userBMI > 30.0) {
      userObese = true;
    }

    if (db.isConnected) {
      try {
        // 1. Update users table
        await db.connection!.query(
          '''
        UPDATE users 
        SET age = @age,
            sex = @sex,
            body_weight = @body_weight,
            height = @height,
            family_history_cvd = @family_history_cvd,
            ethnicity_group = @ethnicity_group,
            marital_status = @marital_status,
            employment_status = @employment_status,
            education_level = @education_level
        WHERE username = @username
        ''',
          substitutionValues: {
            'username': user.username,
            'age': user.age,
            'sex': user.sex,
            'body_weight': user.bodyWeight,
            'height': user.height,
            'family_history_cvd': user.familyHistoryCvd,
            'ethnicity_group': user.ethnicityGroup,
            'marital_status': user.maritalStatus,
            'employment_status': user.employmentStatus,
            'education_level': user.educationLevel,
          },
        );

        return "User profile and risk factors saved successfully.";
      } catch (e) {
        return "Error completing profile: $e";
      }
    } else {
      return "No database connection available.";
    }
  }

  Future<void> insertUserRiskFactors(int userId,
      Map<String, bool> riskPresenceMap) async {
    const Map<String, int> riskIdMap = {
      "Diabetes Mellitus": 1,
      "Hypertension": 2,
      "Hypercholesterolemia": 3,
      "Smoking": 4,
      "Obesity": 5,
      "Family history of CVD": 6
    };

    final now = DateTime.now();

    for (final entry in riskIdMap.entries) {
      final riskName = entry.key;
      final riskId = entry.value;
      final presence = riskPresenceMap[riskName] ?? false;

      await db.connection!.query(
        '''
      INSERT INTO user_risk_factor (user_id, risk_id, bool_risk_presence, last_update)
      VALUES (@user_id, @risk_id, @risk_presence, @last_update)
      ON CONFLICT (user_id, risk_id) DO UPDATE
      SET bool_risk_presence = EXCLUDED.bool_risk_presence,
          last_update = EXCLUDED.last_update
      ''',
        substitutionValues: {
          'user_id': userId,
          'risk_id': riskId,
          'risk_presence': presence,
          'last_update': now,
        },
      );
    }
  }

  Future<UserModel?> userLogin(String username, String password, String hashPassword) async {
    if (db.isConnected) {
      try {
        final results = await db.connection!.query(
          '''
        SELECT user_id, username, fullname, email_address, password, age, sex, body_weight, height, family_history_cvd, ethnicity_group, marital_status, employment_status, education_level, profile_image FROM public.users
        WHERE username = @username AND password = @password
        ''',
          substitutionValues: {
            'username': username,
            'password': hashPassword,
          },
        );

        if (results.isNotEmpty) {
          // Get the first row (the user data)
          var row = results[0];

          // Convert the row to a Map<String, dynamic>
          Map<String, dynamic> userMap = {
            'user_id': row[0] as int,
            'username': row[1] as String,
            'fullname': row[2] as String,
            'email_address': row[3] as String,
            'password': password,
            'age': row[5] as int?,
            'sex': row[6] as String?,
            'body_weight': row[7] as double?,
            'height': row[8] as double?,
            'family_history_cvd': row[9] as bool?,
            'ethnicity_group': row[10] as String?,
            'marital_status': row[11] as String?,
            'employment_status': row[12] as String?,
            'education_level': row[13] as String?,
            'profile_image': row[14] as Uint8List?
          };

          // Use the factory constructor to create a UserModel instance from the map
          UserModel user = UserModel.fromMap(userMap);

          return user; // Return the populated UserModel object
        } else {
          return null; // Return null if no match found
        }
      } catch (e) {
        print("Error logging in: $e");
        return null; // Return null in case of an error
      }
    } else {
      return null;
    }
  }

  Future<String> resetPass(String email, String newPassword) async {
    if (db.isConnected) {
      try {
        // Execute query with email and newPassword as substitution values
        await db.connection!.query(
          """
          UPDATE users SET password = @password WHERE email_address = @email_address
          """,
          substitutionValues: {
            'email_address': email, // Use the passed email
            'password': newPassword, // Use the passed new password
          },
        );
        return "Password update successful";
      } catch (e) {
        return "Error updating password: $e";
      }
    }
    return "Database is not available";
  }

  Future<Map<String, String>> getDiagnoseResult(int userID) async {
    final Map<String, String> result = {};

    if (db.isConnected) {
      try {
        final results = await db.connection!.query(
          '''
        SELECT bool_result, recorded_at
        FROM cvd_result
        WHERE user_id = @userID
        ORDER BY recorded_at DESC
        LIMIT 1
        ''',
          substitutionValues: {
            'userID': userID,
          },
        );

        if (results.isNotEmpty) {
          final row = results.first;
          final bool isHighRisk = row[0];
          final DateTime date = row[1];

          result['riskLevel'] = isHighRisk ? 'High' : 'Low';
          result['lastDiagnosis'] = '${date.day}/${date.month}/${date.year}';
        }
      } catch (e) {
        print('Error retrieving diagnose result: $e');
      }
    }

    return result;
  }

  Future<void> updateCVDResult (int userId, bool result) async {
    if (db.isConnected) {
      try {
        final results = await db.connection!.query(
          '''
          SELECT *
          FROM CVD_RESULT
          WHERE user_id = @userID
          ''',
          substitutionValues: {
            'userID': userId,
          },
        );

        if (results.isEmpty){
          await db.connection!.query(
            '''
            INSERT INTO CVD_RESULT (user_id, bool_result, recorded_at)
            VALUES (@userID, @result, NOW())
            ''',
            substitutionValues: {
              'userID': userId,
              'result': result,
            },
          );
        }else if (results.isNotEmpty){
          await db.connection!.query(
            '''
            UPDATE CVD_RESULT
            SET bool_result = @result, recorded_at = NOW()
            WHERE user_id = @userID
            ''',
            substitutionValues: {
              'userID': userId,
              'result': result,
            },
          );
        }
      } catch (e) {
        print('Error retrieving health readings: $e');
      }
    }
  }

  Future<Map<String, Map<String, String>>> getCVDpresence(int userID) async {
    final Map<String, Map<String, String>> cvdRisks = {};

    if (db.isConnected) {
      try {
        final results = await db.connection!.query(
          '''
        SELECT crf.cvd_risk_name, crf.cvd_short_description, urf.bool_risk_presence, urf.last_update
        FROM user_risk_factor urf
        JOIN cvd_risk_factor crf ON crf.risk_id = urf.risk_id
        WHERE urf.user_id = @userID
        ''',
          substitutionValues: {
            'userID': userID,
          },
        );

        for (final row in results) {
          final String riskName = row[0];
          final String riskDescription = row[1];
          final bool isPresent = row[2];
          final DateTime date = row[3];

          cvdRisks[riskName] = {
            'description': riskDescription,
            'status': isPresent ? 'Present' : 'Not Present',
            'date': '${date.day}/${date.month}/${date.year}',
          };
        }
      } catch (e) {
        print('Error retrieving CVD presence: $e');
      }
    }
    print (cvdRisks);
    return cvdRisks;
  }

  Future<Map<String, String>> getUserActiveSymptoms(int userId) async {
    final Map<String, String> userSymptoms = {};

    if (db.isConnected) {
      try {
        final results = await db.connection!.query(
          """
          SELECT s.symptom_name, us.last_update
          FROM symptom s 
          JOIN user_symptom us ON s.symptom_id = us.symptom_id
          WHERE us.user_id = @userId AND us.bool_symptom_active = true
          """,
          substitutionValues: {
            'userId': userId,
          },
        );

        for (final row in results) {
          final symptomName = row[0] as String;
          final lastUpdate = row[1] as DateTime;

          userSymptoms[symptomName] = '${lastUpdate.day}/${lastUpdate.month}/${lastUpdate.year}';
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

  Future<Map<String, String>> fetchRiskLevelAndLastDiagnose(int userId) async {
    if (!db.isConnected) {
      return {
        "riskLevel": "Unidentified",
        "lastDiagnose": "None",
      };
    }

    try {
      final results = await db.connection!.query(
        '''
      SELECT bool_result, recorded_at 
      FROM CVD_RESULT
      WHERE user_id = @userID
      ORDER BY recorded_at DESC
      LIMIT 1
      ''',
        substitutionValues: {
          'userID': userId,
        },
      );

      if (results.isEmpty) {
        return {
          "riskLevel": "Unidentified",
          "lastDiagnose": "None",
        };
      }

      final row = results.first;
      final bool? hasRisk = row[0] as bool?;
      final DateTime? lastUpdate = row[1] as DateTime?;

      final riskLevel = hasRisk == null ? "Unidentified" : hasRisk ? "High Risk" : "Low Risk";
      final lastDiagnose = lastUpdate != null ? "${lastUpdate.day}/${lastUpdate.month}/${lastUpdate.year}" : "None";

      return {
        "riskLevel": riskLevel,
        "lastDiagnose": lastDiagnose,
      };
    } catch (e) {
      print('Error retrieving CVD presence: $e');
      return {
        "riskLevel": "Unidentified",
        "lastDiagnose": "None",
      };
    }
  }

  Future<List<Map<String, dynamic>>> fetchHealthReadings(int userId) async {
    final List<Map<String, dynamic>> healthReadings = [];

    if (db.isConnected) {
      try {
        final results = await db.connection!.query(
          '''
      SELECT reading_type, health_reading_category, last_update
      FROM HEALTH_METRICS
      WHERE user_id = @userID
      ''',
          substitutionValues: {
            'userID': userId,
          },
        );

        for (final row in results) {
          final String readingType = row[0]?.toString() ?? 'Unknown';
          final String category = row[1]?.toString() ?? 'N/A';
          final DateTime? lastUpdate = row[2] as DateTime?;

          healthReadings.add({
            'readingType': readingType,
            'category': category,
            'lastUpdate': lastUpdate != null ? "${lastUpdate.day}/${lastUpdate.month}/${lastUpdate.year}" : 'Unknown',
          });
        }
      } catch (e) {
        print('Error retrieving health readings: $e');
      }
    }
    return healthReadings;
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  bool hasMissingUserData(UserModel user) {
    final fieldsToCheck = [
      user.username,
      user.fullname,
      user.emailAddress,
      user.password,
      user.age,
      user.sex,
      user.bodyWeight,
      user.height,
      user.familyHistoryCvd,
      user.ethnicityGroup,
      user.maritalStatus,
      user.employmentStatus,
      user.educationLevel,
    ];

    for (final field in fieldsToCheck) {
      if (field == null || field.toString().trim().toUpperCase() == "N/A") {
        return true;
      }
    }
    return false;
  }
}
