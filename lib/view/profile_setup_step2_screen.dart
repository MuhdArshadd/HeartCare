import 'package:flutter/material.dart';
import 'package:heartcare/view/profile_setup_step3_screen.dart';
import 'package:provider/provider.dart';
import '../model/provider/profile_setup_provider.dart';
import 'app_bar/main_navigation.dart';

class ProfileSetupStep2 extends StatelessWidget {
  const ProfileSetupStep2({super.key});

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
                  CircleAvatar(radius: 28, backgroundColor: Colors.redAccent, child: Text("2", style: TextStyle(color: Colors.white, fontSize: 30))),
                  SizedBox(width: 12),
                  Text("-"),
                  SizedBox(width: 12),
                  CircleAvatar(radius: 28, backgroundColor: Colors.grey, child: Text("3", style: TextStyle(color: Colors.white, fontSize: 30))),
                  SizedBox(width: 6),
                  Text("-"),
                  SizedBox(width: 12),
                  CircleAvatar(radius: 28, backgroundColor: Colors.grey, child: Icon(Icons.check, size: 30, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text("Personal Life Info", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 23)),
            const SizedBox(height: 16),

            // 1. Ethnicity
            const Text("1. What is your ethnicity?"),
            DropdownButtonFormField<String>(
              value: provider.ethnicity,
              items: const [
                DropdownMenuItem(value: "Malay", child: Text("Malay")),
                DropdownMenuItem(value: "Non-Malay", child: Text("Non-Malay")),
              ],
              onChanged: provider.updateEthnicityGroup,
              decoration: const InputDecoration(hintText: "Select ethnicity group"),
            ),
            const SizedBox(height: 16),

            // 2. marriage status
            const Text("2. What is your current marriage status?"),
            DropdownButtonFormField<String>(
              value: provider.marriage,
              items: const [
                DropdownMenuItem(value: "Single", child: Text("Single")),
                DropdownMenuItem(value: "Divorced", child: Text("Divorced")),
                DropdownMenuItem(value: "Windowed", child: Text("Windowed")),
                DropdownMenuItem(value: "Married", child: Text("Married")),
              ],
              onChanged: provider.updateMaritalStatus,
              decoration: const InputDecoration(hintText: "Select marital status"),
            ),
            const SizedBox(height: 16),

            // 3. Employment Status
            const Text("3. What is your current employment status?"),
            DropdownButtonFormField<String>(
              value: provider.employment,
              items: const [
                DropdownMenuItem(value: "Employed", child: Text("Employed")),
                DropdownMenuItem(value: "Unemployed", child: Text("Unemployed")),
              ],
              onChanged: provider.updateEmploymentStatus,
              decoration: const InputDecoration(hintText: "Select employment status"),
            ),
            const SizedBox(height: 16),

            // 4. Education level
            const Text("4. What is your highest education level?"),
            DropdownButtonFormField<String>(
              value: provider.education,
              items: const [
                DropdownMenuItem(value: "No Formal Education", child: Text("No Formal Education")),
                DropdownMenuItem(value: "Primary", child: Text("Primary")),
                DropdownMenuItem(value: "Secondary", child: Text("Secondary")),
                DropdownMenuItem(value: "Tertiary", child: Text("Tertiary")),
              ],
              onChanged: provider.updateHighestEducation,
              decoration: const InputDecoration(hintText: "Select education level"),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSetupStep3()));
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
