import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/provider/profile_setup_provider.dart';
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
              MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
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
              onPressed: () {
                final provider = Provider.of<ProfileSetupProvider>(context, listen: false);

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
