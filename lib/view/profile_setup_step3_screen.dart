import 'package:flutter/material.dart';
import 'package:heartcare/controller/user_controller.dart';
import 'package:heartcare/view/profile_setup_complete_screen.dart';
import 'package:provider/provider.dart';
import '../model/provider/profile_setup_provider.dart';
import '../model/provider/user_provider.dart';
import '../model/user_model.dart';
import 'app_bar/main_navigation.dart';

class ProfileSetupStep3 extends StatelessWidget {
  const ProfileSetupStep3({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileSetupProvider>(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black54),
          onPressed: () {
            provider.resetProfile();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationScreen(selectedIndex: 0)),
            );
          },
        ),
        title: Text("Quick Profile Setup",
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "This survey helps us provide accurate health assessments and personalized recommendations tailored to your cardiovascular risk profile.\n\nYour information is kept confidential.",
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Progress Indicator
            _buildProgressIndicator(),
            const SizedBox(height: 32),

            Text("Health Information",
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                )),
            const SizedBox(height: 8),
            Text("Tell us about your health history and habits",
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                )),
            const SizedBox(height: 24),

            // Family History CVD
            _buildMetricCard(
              context,
              title: "Family History of CVD",
              icon: Icons.family_restroom_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Do you have any family history with Cardiovascular Disease (CVD)?", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<bool>(
                    value: provider.familyCVD,
                    style: _inputTextStyle(context),
                    decoration: _inputDecoration("Select Yes/No"),
                    items: const [
                      DropdownMenuItem(value: true, child: Text("Yes")),
                      DropdownMenuItem(value: false, child: Text("No")),
                    ],
                    onChanged: (value) {
                      if (value != null) provider.updateFamilyHistoryCVD(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Diabetes
            _buildMetricCard(
              context,
              title: "Diabetes/High Blood Sugar",
              icon: Icons.monitor_heart_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Have you ever been told by a Doctor that you have high blood sugar/diabetes?", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<bool>(
                    value: provider.diabetes,
                    style: _inputTextStyle(context),
                    decoration: _inputDecoration("Select Yes/No"),
                    items: const [
                      DropdownMenuItem(value: true, child: Text("Yes")),
                      DropdownMenuItem(value: false, child: Text("No")),
                    ],
                    onChanged: (value) {
                      if (value != null) provider.updateDiabetes(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Hypertensive
            _buildMetricCard(
              context,
              title: "High Blood Pressure",
              icon: Icons.favorite_border_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Have you ever been told by a Doctor that you have high blood pressure/hypertensive?", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<bool>(
                    value: provider.hypertensive,
                    style: _inputTextStyle(context),
                    decoration: _inputDecoration("Select Yes/No"),
                    items: const [
                      DropdownMenuItem(value: true, child: Text("Yes")),
                      DropdownMenuItem(value: false, child: Text("No")),
                    ],
                    onChanged: (value) {
                      if (value != null) provider.updateHypertensive(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Hypercholesterolemia
            _buildMetricCard(
              context,
              title: "High Cholesterol",
              icon: Icons.bloodtype_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Have you ever been told by a Doctor that you have high blood cholesterol/hypercholesterolemia?", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<bool>(
                    value: provider.hypercholesterolemia,
                    style: _inputTextStyle(context),
                    decoration: _inputDecoration("Select Yes/No"),
                    items: const [
                      DropdownMenuItem(value: true, child: Text("Yes")),
                      DropdownMenuItem(value: false, child: Text("No")),
                    ],
                    onChanged: (value) {
                      if (value != null) provider.updateHypercholesterolemia(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Smoking
            _buildMetricCard(
              context,
              title: "Tobacco Use (Past Year)",
              icon: Icons.smoking_rooms_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Have you smoked or used any form of tobacco in the past 12 months, including if you quit within the last year?", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<bool>(
                    value: provider.smoker,
                    style: _inputTextStyle(context),
                    decoration: _inputDecoration("Select Yes/No"),
                    items: const [
                      DropdownMenuItem(value: true, child: Text("Yes")),
                      DropdownMenuItem(value: false, child: Text("No")),
                    ],
                    onChanged: (value) {
                      if (value != null) provider.updateSmoking(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Complete Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final provider = Provider.of<ProfileSetupProvider>(context, listen: false);
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  final userController = UserController();

                  // Check if any field is null
                  if (provider.familyCVD == null ||
                      provider.diabetes == null ||
                      provider.hypertensive == null ||
                      provider.hypercholesterolemia == null ||
                      provider.smoker == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please answer all health questions before continuing.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  debugPrint("===== Profile Setup Debug =====");
                  debugPrint("Age: ${provider.age}");
                  debugPrint("Gender: ${provider.gender}");
                  debugPrint("Weight: ${provider.weight}");
                  debugPrint("Height: ${provider.height}");

                  debugPrint("Ethnicity: ${provider.ethnicity}");
                  debugPrint("Marital Status: ${provider.marriage}");
                  debugPrint("Employment Status: ${provider.employment}");
                  debugPrint("Education Level: ${provider.education}");

                  debugPrint("Family History CVD: ${provider.familyCVD}");
                  debugPrint("Diabetes: ${provider.diabetes}");
                  debugPrint("Hypertensive: ${provider.hypertensive}");
                  debugPrint("Hypercholesterolemia: ${provider.hypercholesterolemia}");
                  debugPrint("Smoker: ${provider.smoker}");
                  debugPrint("================================");

                  // Construct full UserModel with updated fields
                  final user = UserModel(
                    userID: userProvider.user!.userID,
                    username: userProvider.user!.username,
                    fullname: userProvider.user!.fullname,
                    emailAddress: userProvider.user!.emailAddress,
                    password: userProvider.user!.password,
                    age: provider.age,
                    sex: provider.gender,
                    bodyWeight: provider.weight,
                    height: provider.height,
                    familyHistoryCvd: provider.familyCVD,
                    ethnicityGroup: provider.ethnicity,
                    maritalStatus: provider.marriage,
                    employmentStatus: provider.employment,
                    educationLevel: provider.education,
                    profileImage: userProvider.user!.profileImage,
                    generatedID: userProvider.user!.generatedID
                  );

                  // Prepare risk map
                  final Map<String, bool> riskPresenceMap = {
                    "Diabetes Mellitus": provider.diabetes!,
                    "Hypertension": provider.hypertensive!,
                    "Hypercholesterolemia": provider.hypercholesterolemia!,
                    "Smoking": provider.smoker!,
                    "Obesity": user.bodyWeight! / (user.height! * user.height!) > 30.0,
                    "Family history of CVD": provider.familyCVD!
                  };

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    // 1. Complete profile update
                    await userController.userCompleteProfile(user);

                    //delay
                    await Future.delayed(const Duration(seconds: 2));

                    // 2. Update risk factors
                    await userController.insertUserRiskFactors(user.userID, riskPresenceMap);

                    // 3. Update provider state
                    userProvider.setUser(user); // Reflect latest profile info

                    // 4. Delay and navigate to success screen
                    Navigator.pop(context); // remove loading dialog

                    // 5. Reset setup state
                    provider.resetProfile();

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileCompleteScreen()),
                    );
                  } catch (e) {
                    Navigator.pop(context); // remove loading dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to complete profile: $e")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text("Complete Profile",
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text("Back",
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: 0.75, // Updated to 75% progress
              backgroundColor: Colors.grey[200],
              color: Colors.redAccent,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildProgressStep(1, "General", false),
            _buildProgressConnector(),
            _buildProgressStep(2, "Personal", false),
            _buildProgressConnector(),
            _buildProgressStep(3, "Health", true),
            _buildProgressConnector(),
            _buildProgressStep(4, "Complete", false),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressStep(int number, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? Colors.redAccent : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(number.toString(),
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                )),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
              color: isActive ? Colors.redAccent : Colors.grey,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            )),
      ],
    );
  }

  Widget _buildProgressConnector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: 20,
        height: 2,
        color: Colors.grey[300],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      color: Colors.grey[100],
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.redAccent),
                const SizedBox(width: 8),
                Text(title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  TextStyle _inputTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: Colors.black87,
    ) ?? const TextStyle();
  }
}