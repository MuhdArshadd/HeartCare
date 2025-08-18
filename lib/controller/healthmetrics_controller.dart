import '../database_service.dart';

class HealthMetricsController {
  final db = DatabaseConnection();

  //Sample flow:
  //define useQuestion = false, ansQuestion = false, value1, value2 = 0
  //1. User choose which reading to update, get the int category
  //2. Only BMI is through reading , while others can be answered through question
  // For question, if the answer is yes that means the CVD risk is presence, while if the answer is no means the CVD risk is not presence
  //3. When the user input and submit -> get the reading category with bool of cvd risk presence -> update to database reading and cvd user risk on the presence of cvd risk
  //4. Return the category and update the homepage ui with the reading category and last_update

  //Update flow 19/8/2025
  //Remove questionnaire, only through reading to be more precise.

  // Future<String> updateHealthReading(int userId, int riskId, bool useQuestion, bool ansQuestion, double value1, double value2) async {
  //   String readingType = "";
  //   String readingCategory = "";
  //   bool riskPresence = false;
  //
  //   switch (riskId) {
  //     case 1:
  //       readingType = "Blood Sugar";
  //       if (useQuestion) {
  //         if (ansQuestion) {
  //           readingCategory = "Confirmed Diabetes";
  //         } else {
  //           readingCategory = "Normal";
  //         }
  //         riskPresence = ansQuestion;
  //       } else {
  //         readingCategory = measureBS(value1);
  //         riskPresence = (readingCategory == "Prediabetes" || readingCategory == "Diabetes");
  //       }
  //       break;
  //
  //     case 2:
  //       readingType = "Blood Pressure";
  //       if (useQuestion) {
  //         if (ansQuestion){
  //           readingCategory = "Confirmed Hypertension";
  //         }
  //         else {
  //           readingCategory = "Normal BP";
  //         }
  //         riskPresence = ansQuestion;
  //       } else {
  //         readingCategory = measureBP(value1, value2); // value1 = systolic, value2 = diastolic
  //         riskPresence = (readingCategory == "Stage 2 Hypertension");
  //       }
  //       break;
  //
  //     case 3:
  //       readingType = "Cholesterol Level";
  //       if (useQuestion) {
  //         if (ansQuestion){
  //           readingCategory = "Confirmed Hypercholesterolemia";
  //         }
  //         else {
  //           readingCategory = "Optimal";
  //         }
  //         riskPresence = ansQuestion;
  //       } else {
  //         readingCategory = measureCL(value1); // cholesterol value
  //         riskPresence = (readingCategory == "High");
  //       }
  //       break;
  //
  //     case 5:
  //       readingType = "BMI";
  //       readingCategory = measureBMI(value1, value2); // value1 = weight, value2 = height
  //       riskPresence = (readingCategory.contains("Obesity") || readingCategory == "Pre-obesity");
  //       break;
  //
  //     default:
  //       return "Invalid risk ID";
  //   }
  //
  //   return await updateUserCVD(userId, riskId, readingType, readingCategory, riskPresence);
  // }

  Future<String> updateHealthReading(int userId, int riskId, double value1, double value2) async {
    String readingType = "";
    String readingCategory = "";
    bool riskPresence = false;

    switch (riskId) {
      case 1:
        readingType = "Blood Sugar";
        readingCategory = measureBS(value1);
        riskPresence = (readingCategory == "Prediabetes" || readingCategory == "Diabetes");
        break;

      case 2:
        readingType = "Blood Pressure";
        readingCategory = measureBP(value1, value2); // value1 = systolic, value2 = diastolic
        riskPresence = (readingCategory == "Stage 2 Hypertension");
        break;

      case 3:
        readingType = "Cholesterol Level";
        readingCategory = measureCL(value1); // cholesterol value
        riskPresence = (readingCategory == "High");
        break;

      case 5:
        readingType = "BMI";
        readingCategory = measureBMI(value1, value2); // value1 = weight, value2 = height
        riskPresence = (readingCategory.contains("Obesity") || readingCategory == "Pre-obesity");
        break;

      default:
        return "Invalid risk ID";
    }

    return await updateUserCVD(userId, riskId, readingType, readingCategory, riskPresence);
  }

  Future<String> updateUserCVD(int userId, int riskId, String readingType, String readingCategory, bool riskPresence) async {
    final now = DateTime.now();

    if (db.isConnected) {
      try {
        // Check if record exists in health_metrics for given user and reading_type
        final checkResult = await db.connection!.query(
          """
        SELECT * FROM health_metrics 
        WHERE user_id = @userId AND reading_type = @readingType
        """,
          substitutionValues: {
            'userId': userId,
            'readingType': readingType,
          },
        );

        if (checkResult.isEmpty) {
          // Insert new record
          await db.connection!.query(
            """
          INSERT INTO health_metrics (user_id, reading_type, health_reading_category, last_update)
          VALUES (@userId, @readingType, @readingCategory, @now)
          """,
            substitutionValues: {
              'userId': userId,
              'readingType': readingType,
              'readingCategory': readingCategory,
              'now': now
            },
          );
        } else {
          // Update existing record
          await db.connection!.query(
            """
          UPDATE health_metrics
          SET health_reading_category = @readingCategory, last_update = @last_update
          WHERE user_id = @userId AND reading_type = @readingType
          """,
            substitutionValues: {
              'userId': userId,
              'readingType': readingType,
              'readingCategory': readingCategory,
              'last_update': now
            },
          );
        }

        // Update user_risk_factor for CVD
        await db.connection!.query(
          """
        UPDATE user_risk_factor
        SET bool_risk_presence = @riskPresence, last_update = @now
        WHERE user_id = @userId AND risk_id = @riskId
        """,
          substitutionValues: {
            'userId': userId,
            'riskId': riskId,
            'riskPresence': riskPresence,
            'now': now
          },
        );
        return "Update successful";
      } catch (e) {
        return "Error: $e";
      }
    }
    return "Database not connected";
  }


  String measureBP(double systolic, double diastolic) {
    if (systolic < 120 && diastolic < 80) {
      // Normal BP
      return "Normal BP";
    } else if (systolic >= 120 && systolic <= 129 && diastolic < 80) {
      // Elevated BP
      return "Elevated BP";
    } else if ((systolic >= 130 && systolic <= 139) || (diastolic >= 80 && diastolic <= 89)) {
      // Stage 1 Hypertension
      return "Stage 1 Hypertension";
    } else if (systolic >= 140 || diastolic >= 90) {
      // Stage 2 Hypertension (Confirmed diagnosis as Hypertension // based on research)
      return "Stage 2 Hypertension";
    } else {
      return "Unclassified BP";
    }
  }

  String measureBS(double fastingBloodSugar) {
    if (fastingBloodSugar < 100) {
      // Normal
      return "Normal";
    } else if (fastingBloodSugar >= 100 && fastingBloodSugar <= 125) {
      // Prediabetes (Confirmed Diagnose as Diabetes Mellitus)
      return "Prediabetes";
    } else if (fastingBloodSugar >= 126) {
      // Diabetes (Confirmed Diagnose as Diabetes Mellitus)
      return "Diabetes";
    } else {
      return "Unclassified";
    }
  }

  String measureCL(double cholesterolSerum) {
    if (cholesterolSerum >= 125 && cholesterolSerum <= 200) {
      // Optimal
      return "Optimal";
    } else if (cholesterolSerum > 200 && cholesterolSerum <= 239) {
      // Borderline High
      return "Borderline High";
    } else if (cholesterolSerum >= 240) {
      // High (Confirmed Diagnose as Hypercholesterolemia)
      return "High";
    } else {
      return "Hypocholesterolemia";
    }
  }


  String measureBMI(double bodyWeight, double height) {
    // BMI = weight (kg) / height (m)^2
    double bmi = bodyWeight / (height * height);

    if (bmi < 18.5) {
      return "Underweight";
    } else if (bmi >= 18.5 && bmi <= 24.9) {
      return "Normal weight";
    } else if (bmi >= 25.0 && bmi <= 29.9) {
      return "Pre-obesity";
    } else if (bmi >= 30.0 && bmi <= 34.9) {
      return "Obesity Class I"; // Confirmed Obesity (high risk for CVD)
    } else if (bmi >= 35.0 && bmi <= 39.9) {
      return "Obesity Class II";
    } else if (bmi >= 40.0) {
      return "Obesity Class III";
    } else {
      return "Invalid input";
    }
  }

}