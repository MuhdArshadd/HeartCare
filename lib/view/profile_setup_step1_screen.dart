import 'package:flutter/material.dart';
import 'package:heartcare/view/profile_setup_step2_screen.dart';
import 'package:provider/provider.dart';
import '../model/provider/profile_setup_provider.dart';
import 'app_bar/main_navigation.dart';

class ProfileSetupStep1 extends StatelessWidget {
  const ProfileSetupStep1({super.key});

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
                  CircleAvatar(radius: 28, backgroundColor: Colors.redAccent, child: Text("1", style: TextStyle(color: Colors.white, fontSize: 30))),
                  SizedBox(width: 12),
                  Text("-"),
                  SizedBox(width: 12),
                  CircleAvatar(radius: 28, backgroundColor: Colors.grey, child: Text("2", style: TextStyle(color: Colors.white, fontSize: 30))),
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

            Text("General Info", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 23)),
            const SizedBox(height: 16),

            // 1. Age
            const Text("1. What is your age?"),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed != null) provider.updateAge(parsed);
              },
              decoration: const InputDecoration(hintText: "Enter age"),
            ),
            const SizedBox(height: 16),

            // 2. Gender
            const Text("2. What is your gender?"),
            DropdownButtonFormField<String>(
              value: provider.gender,
              items: const [
                DropdownMenuItem(value: "Male", child: Text("Male")),
                DropdownMenuItem(value: "Female", child: Text("Female")),
              ],
              onChanged: provider.updateGender,
              decoration: const InputDecoration(hintText: "Select gender"),
            ),
            const SizedBox(height: 16),

            // 3. Body Weight
            const Text("3. What is your body weight (kg)?"),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null) provider.updateWeight(parsed);
              },
              decoration: const InputDecoration(hintText: "Enter weight"),
            ),
            const SizedBox(height: 16),

            // 4. Height
            const Text("4. What is your height (m)?"),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null) provider.updateHeight(parsed);
              },
              decoration: const InputDecoration(hintText: "Enter height"),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSetupStep2()));
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
