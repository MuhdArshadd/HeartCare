import 'dart:typed_data';
import 'package:intl/intl.dart';

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

  Future<void> insertUserRiskFactors(int userId, Map<String, bool> riskPresenceMap) async {
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
        SELECT user_id, username, fullname, email_address, password, age, sex, body_weight, height, family_history_cvd, ethnicity_group, marital_status, employment_status, education_level, profile_image, generated_id FROM public.users
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
            'profile_image': row[14] as Uint8List?,
            'generated_id': row[15] as int
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

  Future<String> resetPass(String page, String email, String newPassword) async {
    String hashedPassword = "";
    if (db.isConnected) {
      try {
        if (page == "reset_password_screen") {
          final result = await db.connection!.query(
            """
            SELECT * FROM USERS WHERE email_address = @email_address
            """,
            substitutionValues: {
              'email_address': email, // Use the passed email
            },
          );
          if (result.isNotEmpty) {
            return "Valid User";
          } else {
            return "Invalid User";
          }
        }
        else if (page == "password_verification_page"){
          hashedPassword = hashPassword(newPassword);
          // Execute query with email and newPassword as substitution values
          final result = await db.connection!.query(
            """
          UPDATE users SET password = @hashedPassword WHERE email_address = @email_address
          """,
            substitutionValues: {
              'email_address': email, // Use the passed email
              'hashedPassword': hashedPassword, // Use the passed new password , but hashed
            },
          );
          if (result.affectedRowCount > 0) {
            return "Password update successful.";
          } else {
            return "Failed to update password.";
          }
        }
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

  Future<Map<String, String>> getHeartHealthStatusAndSmoking(int userID) async {
    Map<String, String> userInfo = {};

    if (db.isConnected) {
      try {
        final results = await db.connection!.query(
          '''
          SELECT cvd.bool_result, cvd.recorded_at, urf.bool_risk_presence
          FROM CVD_RESULT AS cvd
          JOIN USER_RISK_FACTOR AS urf ON cvd.user_id = urf.user_id
          WHERE cvd.user_id = @userID
            AND urf.risk_id IN (SELECT risk_id FROM CVD_RISK_FACTOR WHERE cvd_risk_name = 'Smoking')
          ORDER BY cvd.recorded_at DESC
          LIMIT 1;
          ''',
          substitutionValues: {'userID': userID},
        );

        if (results.isNotEmpty) {
          final row = results.first;

          // Convert bool_result to readable status
          String healthStatus = 'Normal';
          if (row[0] == true) {
            healthStatus = 'High';
          } else{
            healthStatus = 'Low';
          }

          // Format the date
          DateTime recordedAt = row[1];
          String formattedDate = DateFormat('dd MMM yyyy').format(recordedAt);

          // Convert smoking status
          String smokingStatus = row[2] == true ? 'Yes' : 'No';

          userInfo = {
            'heartHealthStatus': healthStatus,
            'lastCheckup': formattedDate,
            'smokingStatus': smokingStatus,
          };
        }
      } catch (e) {
        print("Error fetching Heart Health Status: $e");
      }
    }

    // Return default values if no data found
    return userInfo..putIfAbsent('heartHealthStatus', () => 'Not Available')
      ..putIfAbsent('lastCheckup', () => 'Never')
      ..putIfAbsent('smokingStatus', () => 'No');
  }

  Future<bool> updateUserInfo(user, bool isSmoking) async {
    if (db.isConnected) {
      try {
        // Start transaction for atomic updates
        await db.connection!.transaction((ctx) async {
          // Update the user profile information
          if (user.profileImage != null && user.profileImage!.isNotEmpty) {
            final base64Image = base64Encode(user.profileImage!);

            await ctx.query(
              '''
            UPDATE USERS
            SET 
              fullname = @fullname,
              email_address = @email,
              age = @age,
              sex = @sex,
              family_history_cvd = @familyHistory,
              marital_status = @maritalStatus,
              employment_status = @employmentStatus,
              education_level = @educationLevel,
              profile_image = decode(@profile_image, 'base64')
            WHERE user_id = @userID
            ''',
              substitutionValues: {
                'fullname': user.fullname,
                'email': user.emailAddress,
                'age': user.age,
                'sex': user.sex,
                'familyHistory': user.familyHistoryCvd,
                'maritalStatus': user.maritalStatus,
                'employmentStatus': user.employmentStatus,
                'educationLevel': user.educationLevel,
                'profile_image': base64Image,
                'userID': user.userID,
              },
            );
          } else {
            await ctx.query(
              '''
            UPDATE USERS
            SET 
              fullname = @fullname,
              email_address = @email,
              age = @age,
              sex = @sex,
              family_history_cvd = @familyHistory,
              marital_status = @maritalStatus,
              employment_status = @employmentStatus,
              education_level = @educationLevel
            WHERE user_id = @userID
            ''',
              substitutionValues: {
                'fullname': user.fullname,
                'email': user.emailAddress,
                'age': user.age,
                'sex': user.sex,
                'familyHistory': user.familyHistoryCvd,
                'maritalStatus': user.maritalStatus,
                'employmentStatus': user.employmentStatus,
                'educationLevel': user.educationLevel,
                'userID': user.userID,
              },
            );
          }

          // Update smoking status in health data
          await ctx.query(
            '''
              UPDATE USER_RISK_FACTOR
              SET bool_risk_presence = @smokingStatus, last_update = NOW()
              WHERE user_id = @userID AND risk_id = (
                  SELECT risk_id FROM CVD_RISK_FACTOR 
                  WHERE cvd_risk_name = 'Smoking'
              )
              ''',
            substitutionValues: {
              'smokingStatus': isSmoking,
              'userID': user.userID,
            },
          );
        });

        print('User profile updated successfully');
        return true;
      } catch (e) {
        print('Error updating user profile: $e');
        return false;
      }
    } else {
      throw Exception('Database not connected');
    }
  }
  Future<bool> updateLocation (int userID, double latitude, double longitude) async {
    if (db.isConnected) {
      try {
        await db.connection!.query(
          '''
          UPDATE USERS
          SET temp_latitude = @latitude, temp_longitude = @longitude
          WHERE user_id = @userID
          ''',
          substitutionValues: {
            'userID': userID,
            'latitude': latitude,
            'longitude': longitude,
          },
        );
        return true;
      } catch (e) {
        print("Error update location: $e");
        return false;
      }
    } else {
      print("No database connection available.");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getFamilyMemberList(int currentUserId) async {
    List<Map<String, dynamic>> memberList = [];

    if (db.isConnected) {
      try {
        // --- 1. FETCH CURRENT USER ("ME") ---
        final meResult = await db.connection!.query(
          '''
        SELECT 
          u.user_id, 
          u.fullname, 
          u.temp_latitude, 
          u.temp_longitude, 
          cvd.bool_result,
          u.fcm_token
        FROM USERS u
        LEFT JOIN CVD_RESULT cvd ON u.user_id = cvd.user_id
        WHERE u.user_id = @currentUserId
        ''',
          substitutionValues: {'currentUserId': currentUserId},
        );

        // Process "Me" data
        if (meResult.isNotEmpty) {
          final row = meResult.first;

          int userId = row[0] as int;
          String name = row[1] ?? "Unknown Member";
          double latitude = (row[2] ?? 0.0) as double;
          double longitude = (row[3] ?? 0.0) as double;
          bool? hasRisk = row[4];
          final String riskLevel = hasRisk == null ? "Unidentified" : hasRisk ? "High Risk" : "Low Risk";
          String? token = row[5] as String?;

          memberList.add({
            "userId": userId,
            "name": name,
            "lat": latitude,
            "lng": longitude,
            "status": riskLevel, // Assigned the calculated string here
            "isMe": true,
            "fcm_token": token
          });
        }

        // --- 2. FETCH FAMILY MEMBERS ---
        final results = await db.connection!.query(
          '''
        SELECT 
          u.user_id, 
          u.fullname, 
          u.temp_latitude, 
          u.temp_longitude, 
          cvd.bool_result,
          u.fcm_token
        FROM FAMILY_MEMBER fm
        JOIN USERS u ON fm.user_id_1 = u.user_id OR fm.user_id_2 = u.user_id
        LEFT JOIN CVD_RESULT cvd ON u.user_id = cvd.user_id
        WHERE fm.user_id_1 = @requesterId OR fm.user_id_2 = @requesterId
        ''',
          substitutionValues: {'requesterId': currentUserId},
        );

        for (final row in results) {
          int userId = row[0] as int;
          // --- UNIQUE CHECK ---
          // If the query returns the current user again, skip it
          // because we already added "Me" in step 1.
          if (userId == currentUserId) continue;

          String name = row[1] ?? "Unknown Member";
          double latitude = (row[2] ?? 0.0) as double;
          double longitude = (row[3] ?? 0.0) as double;
          bool? hasRisk = row[4];
          final String riskLevel = hasRisk == null ? "Unidentified" : hasRisk ? "High Risk" : "Low Risk";
          String? token = row[5] as String?;

          memberList.add({
            "userId": userId,
            "name": name,
            "lat": latitude,
            "lng": longitude,
            "status": riskLevel, // Assigned the calculated string here
            "isMe": false,
            "fcm_token": token
          });
        }

        return memberList;

      } catch (e) {
        print("Error fetching family members: $e");
        return [];
      }
    } else {
      print("No database connection available.");
      return [];
    }
  }

  Future<bool> addOrRemoveFamilyMember(bool isRemove, int userFamilyID, int requesterId, int removeId) async {
    if (db.isConnected) {
      // Add family member we use userFamilyID (more like invitation id instead of using directly the userid)
      if (!isRemove){
        try {
          final results = await db.connection!.query(
            '''
          SELECT user_id
          FROM USERS
          WHERE generated_id = @familyID
          ''',
            substitutionValues: {'familyID': userFamilyID},
          );

          if (results.isNotEmpty) {
            final row = results.first;
            final invitedUserId = row[0] as int;

            await db.connection!.query(
              '''
            INSERT INTO FAMILY_MEMBER (
              user_id_1, user_id_2
            ) 
            VALUES (
              @user_id_1, @user_id_2
            )
            ''',
              substitutionValues: {
                'user_id_1': requesterId,
                'user_id_2': invitedUserId,
              },
            );
            return true;
          } else {
            print("No family member found with the given ID.");
            return false;
          }
        } catch (e) {
          print("Error add family member: $e");
          return false;
        }
        // remove family member using both user_id
      } else {
        try {
          await db.connection!.query(
            '''
          DELETE FROM FAMILY_MEMBER
          WHERE user_id_1 = @user_id_1 AND user_id_2 = @user_id_2
          ''',
            substitutionValues: {
              'user_id_1': requesterId,
              'user_id_2': removeId,
            },
          );
          return true;
        } catch (e) {
          print("Error remove family member: $e");
          return false;
        }
      }
    } else {
      print("No database connection available.");
      return false;
    }
  }

  // Call this after Login Success!
  Future<void> saveUserToken(int userId, String token) async {
    if (db.isConnected) {
      try {
        await db.connection!.query(
          '''
        UPDATE users 
        SET fcm_token = @token 
        WHERE user_id = @userId
        ''',
          substitutionValues: {
            'token': token,
            'userId': userId,
          },
        );
        print("FCM Token saved to Database.");
      } catch (e) {
        print("Error saving FCM token: $e");
      }
    }
  }

  Future<String?> getUserToken(int userId) async {
    if (db.isConnected) {
      try {
        final results = await db.connection!.query(
          '''
        SELECT fcm_token
        FROM users
        WHERE user_id = @userId
        ''',
          substitutionValues: {'userId': userId},
        );

        if (results.isNotEmpty) {
          final row = results.first;
          if (row[0] == null) return null;

          return row[0] as String; // Return the actual token!
        } else {
          print("No user found with ID: $userId");
          return null;
        }
      } catch (e) {
        print("Error fetching token: $e");
        return null;
      }
    } else {
      print("No database connection available.");
      return null;
    }
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
