class ProfileSetupModel {
  int? age;
  String? gender;
  double? weight;
  double? height;
  String? ethnicityGroup;
  String? maritalStatus;
  String? employmentStatus;
  String? highestEducation;
  bool? familyHistoryCVD;
  bool? diabetes;
  bool? hypertensive;
  bool? hypercholesterolemia;
  bool? smoking;

  ProfileSetupModel({
    this.age,
    this.gender,
    this.weight,
    this.height,
    this.ethnicityGroup,
    this.maritalStatus,
    this.employmentStatus,
    this.highestEducation,
    this.familyHistoryCVD,
    this.diabetes,
    this.hypertensive,
    this.hypercholesterolemia,
    this.smoking
  });

  void reset() {
    age = null;
    gender = null;
    weight = null;
    height = null;
    ethnicityGroup = null;
    maritalStatus = null;
    employmentStatus = null;
    highestEducation = null;
    familyHistoryCVD = null;
    diabetes = null;
    hypertensive = null;
    hypercholesterolemia = null;
    smoking = null;
  }
}
