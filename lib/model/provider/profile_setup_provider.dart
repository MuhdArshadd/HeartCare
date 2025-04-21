import 'package:flutter/foundation.dart';
import '../profile_setup_model.dart';

class ProfileSetupProvider with ChangeNotifier {
  ProfileSetupModel _profile = ProfileSetupModel();
  

  ProfileSetupModel get profile => _profile;

  int? get age => _profile.age;
  String? get gender => _profile.gender;
  double? get weight => _profile.weight;
  double? get height => _profile.height;
  String? get ethnicity => _profile.ethnicityGroup;
  String? get marriage => _profile.maritalStatus;
  String? get employment => _profile.employmentStatus;
  String? get education => _profile.highestEducation;
  bool? get familyCVD => _profile.familyHistoryCVD;
  bool? get diabetes => _profile.diabetes;
  bool? get hypertensive => _profile.hypertensive;
  bool? get hypercholesterolemia => _profile.hypercholesterolemia;
  bool? get smoker => _profile.smoking;

  void updateAge(int age) {
    _profile.age = age;
    notifyListeners();
  }

  void updateGender(String? gender) {
    _profile.gender = gender ?? 'N/A';
    notifyListeners();
  }

  void updateWeight(double weight) {
    _profile.weight = weight;
    notifyListeners();
  }

  void updateHeight(double height) {
    _profile.height = height;
    notifyListeners();
  }

  void updateEthnicityGroup(String? ethnicityGroup) {
    _profile.ethnicityGroup = ethnicityGroup ?? 'N/A';
    notifyListeners();
  }

  void updateMaritalStatus(String? maritalStatus) {
    _profile.maritalStatus = maritalStatus ?? 'N/A';
    notifyListeners();
  }

  void updateEmploymentStatus(String? employmentStatus) {
    _profile.employmentStatus = employmentStatus ?? 'N/A';
    notifyListeners();
  }

  void updateHighestEducation(String? highestEducation) {
    _profile.highestEducation = highestEducation ?? 'N/A';
    notifyListeners();
  }

  void updateFamilyHistoryCVD(bool? hasFamilyHistory) {
    _profile.familyHistoryCVD = hasFamilyHistory ?? false;
    notifyListeners();
  }

  void updateDiabetes(bool? hasDiabetes) {
    _profile.diabetes = hasDiabetes ?? false;
    notifyListeners();
  }

  void updateHypertensive(bool? isHypertensive) {
    _profile.hypertensive = isHypertensive ?? false;
    notifyListeners();
  }

  void updateHypercholesterolemia(bool hasHypercholesterolemia) {
    _profile.hypercholesterolemia = hasHypercholesterolemia;
    notifyListeners();
  }

  void updateSmoking(bool? isSmoker) {
    _profile.smoking = isSmoker ?? false;
    notifyListeners();
  }

  void resetProfile() {
    _profile.reset();
    notifyListeners();
  }
}
