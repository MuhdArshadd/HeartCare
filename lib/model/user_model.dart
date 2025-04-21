import 'dart:typed_data';

class UserModel {
  final String username; //Not Null
  final String fullname; //Not Null
  final String emailAddress; //Not Null
  final String password; //Not Null
  final int? age; //Nullable
  final String? sex; //Nullable
  final double? bodyWeight; //Nullable
  final double? height; //Nullable
  final bool? familyHistoryCvd; //Nullable
  final String? ethnicityGroup; //Nullable
  final String? maritalStatus; //Nullable
  final String? employmentStatus; //Nullable
  final String? educationLevel; //Nullable
  final Uint8List? profileImage; //Nullable

  // Constructor to initialize the attributes
  UserModel({
    required this.username,
    required this.fullname,
    required this.emailAddress,
    required this.password,
    required this.age,
    required this.sex,
    required this.bodyWeight,
    required this.height,
    required this.familyHistoryCvd,
    required this.ethnicityGroup,
    required this.maritalStatus,
    required this.employmentStatus,
    required this.educationLevel,
    required this.profileImage,
  });

  // Convert the UserModel to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'fullname': fullname,
      'email_address': emailAddress,
      'password': password,
      'age': age!,
      'sex': sex!,
      'body_weight': bodyWeight!,
      'height': height!,
      'family_history_cvd': familyHistoryCvd!,
      'ethnicity_group': ethnicityGroup!,
      'marital_status': maritalStatus!,
      'employment_status': employmentStatus!,
      'education_level': educationLevel!,
      'profile_image': profileImage!,
    };
  }

  // Convert a Map to a UserModel object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'],
      fullname: map['fullname'],
      emailAddress: map['email_address'],
      password: map['password'],
      age: map['age'] ?? 0,
      sex: map['sex'] ?? "N/A",
      bodyWeight: map['body_weight'] ?? 0.0,
      height: map['height'] ?? 0.0,
      familyHistoryCvd: map['family_history_cvd'] ?? false,
      ethnicityGroup: map['ethnicity_group'] ?? "N/A",
      maritalStatus: map['marital_status'] ?? "N/A",
      employmentStatus: map['employment_status'] ?? "N/A",
      educationLevel: map['education_level'] ?? "N/A",
      profileImage: map['profile_image'] ?? null
    );
  }
}
