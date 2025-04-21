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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            provider.resetProfile();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationScreen(selectedIndex: 0,)),
            );
          },
        ),
        title: const Text("Quick Profile Setup"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This survey helps us provide accurate health assessments and personalized recommendations tailored to your cardiovascular risk profile.\n\nYour information is kept confidential.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            const Divider(thickness: 1),
            const SizedBox(height: 12),

            // Progress Indicator
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircleAvatar(radius: 28, backgroundColor: Colors.grey, child: Text("1", style: TextStyle(color: Colors.white, fontSize: 30))),
                  SizedBox(width: 12),
                  Text("-"),
                  SizedBox(width: 12),
                  CircleAvatar(radius: 28, backgroundColor: Colors.grey, child: Text("2", style: TextStyle(color: Colors.white, fontSize: 30))),
                  SizedBox(width: 12),
                  Text("-"),
                  SizedBox(width: 12),
                  CircleAvatar(radius: 28, backgroundColor: Colors.redAccent, child: Text("3", style: TextStyle(color: Colors.white, fontSize: 30))),
                  SizedBox(width: 6),
                  Text("-"),
                  SizedBox(width: 12),
                  CircleAvatar(radius: 28, backgroundColor: Colors.grey, child: Icon(Icons.check, size: 30, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text("Personal Health Info", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 23)),
            const SizedBox(height: 16),

            // 1. Family with CVD
            const Text("1. Do you have any family history with Cardiovascular Disease (CVD)?"),
            DropdownButtonFormField<bool>(
              value: provider.familyCVD,
              items: const [
                DropdownMenuItem(value: true, child: Text("Yes")),
                DropdownMenuItem(value: false, child: Text("No")),
              ],
              onChanged: (value) {
                if (value != null) {
                  provider.updateFamilyHistoryCVD(value);
                }
              },
              decoration: const InputDecoration(hintText: "Yes/No"),
            ),
            const SizedBox(height: 16),

            // 2. Diabetes
            const Text("2. Have you ever been told by a Doctor that you have high blood sugar/diabetes?"),
            DropdownButtonFormField<bool>(
              value: provider.diabetes,
              items: const [
                DropdownMenuItem(value: true, child: Text("Yes")),
                DropdownMenuItem(value: false, child: Text("No")),
              ],
              onChanged: (value) {
                if (value != null) {
                  provider.updateDiabetes(value);
                }
              },
              decoration: const InputDecoration(hintText: "Yes/No"),
            ),
            const SizedBox(height: 16),

            // 3. Hypertensive
            const Text("3. Have you ever been told by a Doctor that you have high blood pressure/hypertensive?"),
            DropdownButtonFormField<bool>(
              value: provider.hypertensive,
              items: const [
                DropdownMenuItem(value: true, child: Text("Yes")),
                DropdownMenuItem(value: false, child: Text("No")),
              ],
              onChanged: (value) {
                if (value != null) {
                  provider.updateHypertensive(value);
                }
              },
              decoration: const InputDecoration(hintText: "Yes/No"),
            ),
            const SizedBox(height: 16),

            // 4. Hypercholesterolemia
            const Text("4. Have you ever been told by a Doctor that you have high blood cholesterol/hypercholesterolemia?"),
            DropdownButtonFormField<bool>(
              value: provider.hypercholesterolemia,
              items: const [
                DropdownMenuItem(value: true, child: Text("Yes")),
                DropdownMenuItem(value: false, child: Text("No")),
              ],
              onChanged: (value) {
                if (value != null) {
                  provider.updateHypercholesterolemia(value);
                }
              },
              decoration: const InputDecoration(hintText: "Yes/No"),
            ),
            const SizedBox(height: 16),

            // 5. Smoking
            const Text("5. Have you smoked or used any form of tobacco in the past 12 months, including if you quit within the last year?"),
            DropdownButtonFormField<bool>(
              value: provider.smoker,
              items: const [
                DropdownMenuItem(value: true, child: Text("Yes")),
                DropdownMenuItem(value: false, child: Text("No")),
              ],
              onChanged: (value) {
                if (value != null) {
                  provider.updateSmoking(value);
                }
              },
              decoration: const InputDecoration(hintText: "Yes/No"),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                final provider = Provider.of<ProfileSetupProvider>(context, listen: false);
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                final userController = UserController();

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
                );

                // Prepare risk map
                final Map<String, bool> riskPresenceMap = {
                  "Diabetes Mellitus": provider.diabetes!,
                  "Hypertension": provider.hypertensive!,
                  "Hypercholesterolemia": provider.hypercholesterolemia!,
                  "Smoking": provider.smoker!,
                  "Obesity": user.bodyWeight! / (user.height! * user.height!) > 25.0,
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
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
