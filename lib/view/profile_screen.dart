import 'package:flutter/material.dart';
import 'package:heartcare/model/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedSection = 0;
  bool _isLoading = false; // To control loading state

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    // If user data is null, show a loading state or direct to login
    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(),
      ); // Or navigate to login screen if preferred
    }

    return Scaffold(
      backgroundColor: Colors.white,
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Profile Page',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Profile Image with Edit Option
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: user.profileImage != null
                        ? MemoryImage(user.profileImage!)
                        : null,
                    child: user.profileImage == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      // TODO: Add image change logic
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Text(
                '@${user.username}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),

              // Section Selector
              Row(
                children: [
                  _buildSectionButton(0, 'Account Info'),
                  _buildSectionButton(1, 'Personal Info'),
                ],
              ),
              const Divider(thickness: 1),
              const SizedBox(height: 10),

              _selectedSection == 0
                  ? _buildAccountInfo(user)
                  : _buildPersonalInfo(user),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  // Show loading dialog immediately
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  setState(() {
                    _isLoading = true; // Show loading state
                  });

                  // Show a loading indicator before navigating
                  await Future.delayed(const Duration(seconds: 2));

                  // Clear user data (provider)
                  Provider.of<UserProvider>(context, listen: false).clearUser();

                  // Close the loading dialog
                  Navigator.of(context).pop();

                  // Navigate to Login Page and replace the current route
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text('Log Out'),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionButton(int index, String title) {
    return Expanded(
      child: TextButton(
        onPressed: () {
          setState(() {
            _selectedSection = index;
            print('Switched to section: $_selectedSection');
          });
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          backgroundColor:
          _selectedSection == index ? Colors.grey[200] : Colors.transparent,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight:
            _selectedSection == index ? FontWeight.bold : FontWeight.normal,
            color: _selectedSection == index ? Colors.blue : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfo(user) {
    return Column(
      children: [
        _buildTextField('Full Name', user.fullname, false, true),
        _buildTextField('Email Address', user.emailAddress, true),
        _buildTextField('Password', '•••••••••••', true),
        _buildTextField('Age', user.age.toString(), true),
        _buildTextField('Sex', user.sex, true),
      ],
    );
  }

  Widget _buildPersonalInfo(user) {
    return Column(
      children: [
        _buildCheckboxField('Family History of CVD?', user.familyHistoryCvd),
        _buildDropdownField(
          label: 'Ethnicity Group',
          value: user.ethnicityGroup,
          items: ['N/A','Malay', 'Non-Malay'],
        ),
        _buildDropdownField(
          label: 'Marital Status',
          value: user.maritalStatus,
          items: ['N/A','Single', 'Divorced', 'Widowed', 'Married'],
        ),
        _buildDropdownField(
          label: 'Employment Status',
          value: user.employmentStatus,
          items: ['N/A','Employed', 'Unemployed'],
        ),
        _buildDropdownField(
          label: 'Education Level',
          value: user.educationLevel,
          items: ['N/A','No Formal Education', 'Primary', 'Secondary', 'Tertiary'],
        ),
      ],
    );
  }

  Widget _buildCheckboxField(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Checkbox(
            value: value,
            onChanged: (newValue) {
              // TODO: Add logic to update the user model
              setState(() {
                // Simulate update
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : null,
        onChanged: (newValue) {
          // TODO: Add logic to update the user model
          setState(() {
            // Simulate update
          });
        },
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }


  Widget _buildTextField(String label, String initialValue,
      [bool isEditable = true, bool isDisabled = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        key: ValueKey(label),  // Each field a unique identity
        initialValue: initialValue,
        readOnly: !isEditable || isDisabled,
        decoration: InputDecoration(
          labelText: label,
          filled: isDisabled,
          fillColor: isDisabled ? Colors.grey[200] : null,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

}
