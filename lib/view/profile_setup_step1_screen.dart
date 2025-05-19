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
                  color: Colors.white, fontWeight: FontWeight.bold
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Progress Indicator
            _buildProgressIndicator(),
            const SizedBox(height: 32),

            Text("General Information",
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                )),
            const SizedBox(height: 8),
            Text("Please provide your basic health metrics",
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                )),
            const SizedBox(height: 24),

            // Age Input
            _buildMetricCard(
              context,
              title: "Age",
              icon: Icons.cake_rounded,
              child: TextField(
                keyboardType: TextInputType.number,
                style: _inputTextStyle(context),
                decoration: _inputDecoration("Enter your age"),
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null) provider.updateAge(parsed);
                },
              ),
            ),
            const SizedBox(height: 16),

            // Gender Input
            _buildMetricCard(
              context,
              title: "Gender",
              icon: Icons.person_outline_rounded,
              child: DropdownButtonFormField<String>(
                value: provider.gender,
                style: _inputTextStyle(context),
                decoration: _inputDecoration("Select gender"),
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                ],
                onChanged: provider.updateGender,
              ),
            ),
            const SizedBox(height: 16),

            // Weight Input
            _buildMetricCard(
              context,
              title: "Weight",
              icon: Icons.monitor_weight_outlined,
              unit: "kg",
              child: TextField(
                keyboardType: TextInputType.number,
                style: _inputTextStyle(context),
                decoration: _inputDecoration("Enter your weight, KG (e.g. 60.9)"),
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) provider.updateWeight(parsed);
                },
              ),
            ),
            const SizedBox(height: 16),

            // Height Input
            _buildMetricCard(
              context,
              title: "Height",
              icon: Icons.height_rounded,
              unit: "m",
              child: TextField(
                keyboardType: TextInputType.number,
                style: _inputTextStyle(context),
                decoration: _inputDecoration("Enter your height, m (e.g. 1.70)"),
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) provider.updateHeight(parsed);
                },
              ),
            ),
            const SizedBox(height: 32),

            // Next Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final ageValid = provider.age != null;
                  final genderValid = provider.gender != null && provider.gender!.isNotEmpty;
                  final weightValid = provider.weight != null;
                  final heightValid = provider.height != null;

                  if (ageValid && genderValid && weightValid && heightValid) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileSetupStep2()),
                    );
                  } else {
                    // Show error feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Please fill in all fields before continuing."),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
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
                child: Text("Continue to Health Info",
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
              value: 0.25,
              backgroundColor: Colors.grey[200],
              color: Colors.redAccent,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildProgressStep(1, "General", true),
            _buildProgressConnector(),
            _buildProgressStep(2, "Health", false),
            _buildProgressConnector(),
            _buildProgressStep(3, "Lifestyle", false),
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
    String? unit,
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
                if (unit != null) ...[
                  const Spacer(),
                  Text(unit,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      )),
                ],
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
        fontSize: 14,  // Reduced from default 16
        color: Colors.grey,  // Optional: make hint text slightly lighter
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