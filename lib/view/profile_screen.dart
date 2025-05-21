import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:heartcare/controller/user_controller.dart';
import 'package:heartcare/model/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserController userController = UserController();

  int _selectedSection = 0;
  bool _isLoading = false;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers for editable fields
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late String _selectedSex;
  late bool _familyHistoryCvd;
  late String _selectedEthnicity;
  late String _selectedMaritalStatus;
  late String _selectedEmploymentStatus;
  late String _selectedEducationLevel;
  late String _heartHealthStatus = 'Not Available';
  late String _lastCheckup = 'Never';
  late String _smokingStatus = 'No';

  Map<String,String> userInfo = {};

  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      _initializeControllers(user);
      _loadHealthData(user.userID); // Separate function for async loading
    }
  }

  Future<void> _loadHealthData(int userId) async {
    try {
      final healthData = await userController.getHeartHealthStatusAndSmoking(userId);
      if (healthData.isNotEmpty) {
        setState(() {
          _heartHealthStatus = healthData['heartHealthStatus'] ?? 'Not Available';
          _lastCheckup = healthData['lastCheckup'] ?? 'Never';
          _smokingStatus = healthData['smokingStatus'] ?? 'No';
        });
      }
    } catch (e) {
      print('Error loading health data: $e');
      // Consider showing an error to the user if needed
    }
  }

  void _initializeControllers(user) {
    _fullNameController = TextEditingController(text: user.fullname ?? '');
    _emailController = TextEditingController(text: user.emailAddress ?? '');
    _ageController = TextEditingController(text: user.age?.toString() ?? '');
    _selectedSex = user.sex ?? 'Male';
    _familyHistoryCvd = user.familyHistoryCvd ?? false;
    _selectedEthnicity = user.ethnicityGroup ?? 'N/A';
    _selectedMaritalStatus = user.maritalStatus ?? 'N/A';
    _selectedEmploymentStatus = user.employmentStatus ?? 'N/A';
    _selectedEducationLevel = user.educationLevel ?? 'N/A';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        final File file = File(filePath);
        final Uint8List imageBytess = await file.readAsBytes();
        setState(() {
          imageBytes = imageBytess;
        });
      }
    }
  }

  Future<void> _saveChangesToBackend(user, String isSmoking) async {
    setState(() => _isLoading = true);
    bool smoking = isSmoking == 'Yes';

    try {
      // Prepare updated user data
      final updatedUser = user.copyWith(
        fullname: _fullNameController.text,
        emailAddress: _emailController.text,
        age: int.tryParse(_ageController.text),
        sex: _selectedSex,
        familyHistoryCvd: _familyHistoryCvd,
        maritalStatus: _selectedMaritalStatus,
        employmentStatus: _selectedEmploymentStatus,
        educationLevel: _selectedEducationLevel,
        profileImage: imageBytes ?? user.profileImage,
      );

      // Call UserController to update
      final updateSuccess = await userController.updateUserInfo(updatedUser, smoking);

      if (updateSuccess) {
        // Update provider and local state only if update was successful
        Provider.of<UserProvider>(context, listen: false).setUser(updatedUser);

        // Reset editing state and clear picked image
        setState(() {
          _isEditing = false;
          imageBytes = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show warning if update failed but didn't throw exception
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: Colors.orange,
          ),
        );
        // Keep editing mode on if update failed
        setState(() => _isEditing = true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      // Revert to editing mode on error
      setState(() => _isEditing = true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final theme = Theme.of(context);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Image.asset(
            'assets/images/HeartCare_logo.png',
            height: 40,
          ),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            TextButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  try {
                    setState(() {
                      _isEditing = false;
                    });
                    await _saveChangesToBackend(user, _smokingStatus);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Profile updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    // Show error message if save fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update profile: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    // Re-enable editing if save failed
                    setState(() {
                      _isEditing = true;
                    });
                  }
                }
              },
              child: Text('SAVE', style: TextStyle(color: Colors.blue)),
            ),
          if (_isEditing)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _initializeControllers(user); // Reset to original values
                });
              },
              child: Text('CANCEL', style: TextStyle(color: Colors.redAccent)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Header with Medical Card Style
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.redAccent,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _getProfileImage(user),
                              child: _showProfileIcon(user),
                            ),
                          ),
                          if (_isEditing)
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.camera_alt, size: 20, color: Colors.white),
                                onPressed: _pickImage, // Fixed: removed the semicolon
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        user.fullname ?? '',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'HeartCare Member',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Medical-themed section tabs
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildMedicalTabButton(0, 'Health Profile'),
                          _buildMedicalTabButton(1, 'Personal Details'),
                        ],
                      ),
                      Divider(height: 1, color: Colors.grey[300]),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Content Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16),
                  child: _selectedSection == 0
                      ? _buildHealthProfileSection(user)
                      : _buildPersonalDetailsSection(user),
                ),

                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalTabButton(int index, String title) {
    final isSelected = _selectedSection == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedSection = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.redAccent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.redAccent : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthProfileSection(user) {
    return Column(
      children: [
        _buildMedicalInfoTile(
          icon: Icons.favorite,
          iconColor: Colors.redAccent,
          label: 'Heart Health Status',
          value: _heartHealthStatus,
          isEditable: false,
        ),
        Divider(),
        _buildMedicalInfoTile(
          icon: Icons.medical_services,
          iconColor: Colors.blue,
          label: 'Last Checkup',
          value: _lastCheckup,
          isEditable: false,
        ),
        Divider(),
        _buildMedicalInfoTile(
          icon: Icons.history,
          iconColor: Colors.blue,
          label: 'Family History of CVD',
          value: _familyHistoryCvd ? 'Yes' : 'No',
          isEditable: _isEditing,
          onEdit: (newValue) {
            setState(() {
              _familyHistoryCvd = newValue == 'Yes';
            });
          },
          editableOptions: ['Yes', 'No'],
        ),
        Divider(),
        _buildMedicalInfoTile(
          icon: Icons.smoking_rooms,
          iconColor: Colors.blue,
          label: 'Currently Smoking?',
          value: _smokingStatus,
          isEditable: _isEditing,
          onEdit: (newValue) {
            setState(() {
              _smokingStatus = newValue;
            });
          },
          editableOptions: ['Yes', 'No'],
        ),
        Divider(),
        _buildMedicalInfoTile(
          icon: Icons.calendar_today,
          iconColor: Colors.blue,
          label: 'Age',
          value: _ageController.text,
          isEditable: _isEditing,
          isTextEditable: true,
          controller: _ageController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your age';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
        Divider(),
        _buildMedicalInfoTile(
          icon: Icons.people,
          iconColor: Colors.blue,
          label: 'Sex',
          value: _selectedSex,
          isEditable: _isEditing,
          onEdit: (newValue) {
            setState(() {
              _selectedSex = newValue;
            });
          },
          editableOptions: ['Male', 'Female'],
        ),
      ],
    );
  }

  Widget _buildPersonalDetailsSection(user) {
    return Column(
      children: [
        _buildMedicalInfoTile(
          icon: Icons.person,
          iconColor: Colors.blue,
          label: 'Full Name',
          value: _fullNameController.text,
          isEditable: _isEditing,
          isTextEditable: true,
          controller: _fullNameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        Divider(),
        _buildMedicalInfoTile(
          icon: Icons.email,
          iconColor: Colors.blue,
          label: 'Email Address',
          value: _emailController.text,
          isEditable: _isEditing,
          isTextEditable: true,
          controller: _emailController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        Divider(),
        _buildMedicalInfoTile(
          icon: Icons.group,
          iconColor: Colors.blue,
          label: 'Ethnicity Group',
          value: _selectedEthnicity,
          isEditable: false,
        ),
        Divider(),
        _buildMedicalInfoTile(
          icon: Icons.family_restroom,
          iconColor: Colors.blue,
          label: 'Marital Status',
          value: _selectedMaritalStatus,
          isEditable: _isEditing,
          onEdit: (newValue) {
            setState(() {
              _selectedMaritalStatus = newValue;
            });
          },
          editableOptions: ['N/A', 'Single', 'Divorced', 'Widowed', 'Married'],
        ),
        Divider(),
        _buildMedicalInfoTile(
          icon: Icons.work,
          iconColor: Colors.blue,
          label: 'Employment Status',
          value: _selectedEmploymentStatus,
          isEditable: _isEditing,
          onEdit: (newValue) {
            setState(() {
              _selectedEmploymentStatus = newValue;
            });
          },
          editableOptions: ['N/A', 'Employed', 'Unemployed'],
        ),
        Divider(),
        _buildMedicalInfoTile(
          icon: Icons.school,
          iconColor: Colors.blue,
          label: 'Education Level',
          value: _selectedEducationLevel,
          isEditable: _isEditing,
          onEdit: (newValue) {
            setState(() {
              _selectedEducationLevel = newValue;
            });
          },
          editableOptions: [
            'N/A',
            'No Formal Education',
            'Primary',
            'Secondary',
            'Tertiary'
          ],
        ),
      ],
    );
  }

  Widget _buildMedicalInfoTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool isEditable = false,
    bool isTextEditable = false,
    TextEditingController? controller,
    String? Function(String?)? validator,
    Function(String)? onEdit,
    List<String>? editableOptions,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: isEditable && isTextEditable
          ? TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          contentPadding: EdgeInsets.zero,
        ),
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        validator: validator,
      )
          : isEditable && editableOptions != null
          ? DropdownButtonFormField<String>(
        value: value,
        items: editableOptions.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null && onEdit != null) {
            onEdit(newValue);
          }
        },
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          contentPadding: EdgeInsets.zero,
        ),
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      )
          : Text(
        value,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ImageProvider? _getProfileImage(user) {
    if (imageBytes != null) {
      return MemoryImage(imageBytes!);
    } else if (user.profileImage != null && user.profileImage!.isNotEmpty) {
      return MemoryImage(user.profileImage!);
    }
    return null;
  }

  Widget? _showProfileIcon(user) {
    if (imageBytes == null &&
        (user.profileImage == null || user.profileImage!.isEmpty)) {
      return Icon(Icons.person, size: 50, color: Colors.blue);
    }
    return null;
  }

}