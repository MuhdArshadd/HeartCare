import 'dart:typed_data';

class UserModel {
  final int userID; //Not Null but for register je will ignore
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
    required this.userID,
    required this.username,
    required this.fullname,
    required this.emailAddress,
    required this.password,
    this.age,
    this.sex,
    this.bodyWeight,
    this.height,
    this.familyHistoryCvd,
    this.ethnicityGroup,
    this.maritalStatus,
    this.employmentStatus,
    this.educationLevel,
    this.profileImage,
  });

  // Convert the UserModel to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'user_id': userID,
      'username': username,
      'fullname': fullname,
      'email_address': emailAddress,
      'password': password,
      'age': age,
      'sex': sex,
      'body_weight': bodyWeight,
      'height': height,
      'family_history_cvd': familyHistoryCvd,
      'ethnicity_group': ethnicityGroup,
      'marital_status': maritalStatus,
      'employment_status': employmentStatus,
      'education_level': educationLevel,
      'profile_image': profileImage,
    };
  }

  // Convert a Map to a UserModel object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userID: map['user_id'],
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
      profileImage: map['profile_image'] != null ? Uint8List.fromList(List<int>.from(map['profile_image'])) : Uint8List(0),
    );
  }
}
