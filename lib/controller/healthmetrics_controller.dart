class HealthMetrics {

  //Sample flow:
  //define useQuestion = false, ansQuestion = false, value1, value2 = 0
  //1. User choose which reading to update, get the int category
  //2. Only BMI is through reading , while others can be answered through question
  //3. When the user input and submit -> get the reading category -> update to database reading and cvd user risk on the presence of cvd risk
  //4. Return the category and update the homepage ui with the reading category and last_update

  //Change this function to return string
  Future<void> updateHealthReading(int category, bool useQuestion, bool ansQuestion, double value1, double value2) async {
    if (category == 1){
      //call function to measure blood pressure , return the category and update to database reading and also update CVD user risk the presence of CVD risks factor
      if (useQuestion == true){

      } else {

      }
    } else if (category == 2){
      // call function to measure blood sugar, return the category and update to database reading and also update CVD user risk the presence of CVD risks factor
      if (useQuestion == true){

      } else {

      }
    } else if (category == 3){
      // call function to measure cholesterol level, return the category and update to database reading and also update CVD user risk the presence of CVD risks factor
      if (useQuestion == true){

      } else {

      }
    } else if (category == 4){
      // call function to measure BMI, return the category and update to database reading and also update CVD user risk the presence of CVD risks factor
    }
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
      return "Below Optimal Range (Possible Hypocholesterolemia)";
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