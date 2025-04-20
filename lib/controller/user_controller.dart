import 'dart:typed_data';

import '../database_service.dart';
import 'dart:convert';
import '../model/user_model.dart'; // For base64 encoding

class UserController {
  final db = DatabaseConnection();

  Future<bool> userSignUp(UserModel user) async {
    if (db.isConnected) {
      try {
        // Convert image bytes to base64 string if the profile image exists
        if (user.profileImage != null) {
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
        print ("Error signing up: $e");
        return false;
      }
    } else {
      print ("No database connection available.");
      return false;
    }
  }

  Future<String> userCompleteProfile(UserModel user) async {
    if (db.isConnected) {
      try {
        // Convert image bytes to base64 string if the profile image exists
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
            'education_level': user.educationLevel
          },
        );
        return "User Profile Complete successful";
      } catch (e) {
        return "Error complete profile: $e";
      }
    } else {
      return "No database connection available.";
    }
  }

  Future<UserModel?> userLogin(String username, String password) async {
    if (db.isConnected) {
      try {
        final results = await db.connection!.query(
          '''
        SELECT user_id, username, fullname, email_address, password, age, sex, body_weight, height, family_history_cvd, ethnicity_group, marital_status, employment_status, education_level, profile_image FROM public.users
        WHERE username = @username AND password = @password
        ''',
          substitutionValues: {
            'username': username,
            'password': password,
          },
        );

        if (results.isNotEmpty) {
          // Get the first row (the user data)
          var row = results[0];

          // Convert the row to a Map<String, dynamic>
          Map<String, dynamic> userMap = {
            'username': row[1] as String,
            'fullname': row[2] as String,
            'email_address': row[3] as String,
            'password': row[4] as String,
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
        // SQL query to update password
        String query = "UPDATE users SET password = @password WHERE email_address = @email_address";

        // Execute query with email and newPassword as substitution values
        await db.connection!.query(
          """
          UPDATE users SET password = @password WHERE email_address = @email_address
          """,
          substitutionValues: {
            'email_address': email,       // Use the passed email
            'password': newPassword,  // Use the passed new password
          },
        );
        return "Password update successful";
      } catch (e) {
        return "Error updating password: $e";
      }
    } return "Database is not available";
  }

}
