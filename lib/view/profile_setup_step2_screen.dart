import 'package:flutter/material.dart';
import 'package:heartcare/view/profile_setup_step1_screen.dart';
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

            Text("Personal Life Information",
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                )),
            const SizedBox(height: 8),
            Text("Tell us about your background and lifestyle",
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                )),
            const SizedBox(height: 24),

            // Ethnicity Input
            _buildMetricCard(
              context,
              title: "Ethnicity",
              icon: Icons.people_alt_outlined,
              child: DropdownButtonFormField<String>(
                value: provider.ethnicity,
                style: _inputTextStyle(context),
                decoration: _inputDecoration("Select ethnicity group"),
                items: const [
                  DropdownMenuItem(value: "Malay", child: Text("Malay")),
                  DropdownMenuItem(value: "Non-Malay", child: Text("Non-Malay")),
                ],
                onChanged: provider.updateEthnicityGroup,
              ),
            ),
            const SizedBox(height: 16),

            // Marriage Status Input
            _buildMetricCard(
              context,
              title: "Marital Status",
              icon: Icons.favorite_border_rounded,
              child: DropdownButtonFormField<String>(
                value: provider.marriage,
                style: _inputTextStyle(context),
                decoration: _inputDecoration("Select marital status"),
                items: const [
                  DropdownMenuItem(value: "Single", child: Text("Single")),
                  DropdownMenuItem(value: "Divorced", child: Text("Divorced")),
                  DropdownMenuItem(value: "Windowed", child: Text("Windowed")),
                  DropdownMenuItem(value: "Married", child: Text("Married")),
                ],
                onChanged: provider.updateMaritalStatus,
              ),
            ),
            const SizedBox(height: 16),

            // Employment Status Input
            _buildMetricCard(
              context,
              title: "Employment Status",
              icon: Icons.work_outline_rounded,
              child: DropdownButtonFormField<String>(
                value: provider.employment,
                style: _inputTextStyle(context),
                decoration: _inputDecoration("Select employment status"),
                items: const [
                  DropdownMenuItem(value: "Employed", child: Text("Employed")),
                  DropdownMenuItem(value: "Unemployed", child: Text("Unemployed")),
                ],
                onChanged: provider.updateEmploymentStatus,
              ),
            ),
            const SizedBox(height: 16),

            // Education Level Input
            _buildMetricCard(
              context,
              title: "Education Level",
              icon: Icons.school_outlined,
              child: DropdownButtonFormField<String>(
                value: provider.education,
                style: _inputTextStyle(context),
                decoration: _inputDecoration("Select your highest education level"),
                items: const [
                  DropdownMenuItem(value: "No Formal Education", child: Text("No Formal Education")),
                  DropdownMenuItem(value: "Primary", child: Text("Primary")),
                  DropdownMenuItem(value: "Secondary", child: Text("Secondary")),
                  DropdownMenuItem(value: "Tertiary", child: Text("Tertiary")),
                ],
                onChanged: provider.updateHighestEducation,
              ),
            ),
            const SizedBox(height: 32),

            // Next Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (provider.ethnicity != null &&
                      provider.marriage != null &&
                      provider.employment != null &&
                      provider.education != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileSetupStep3()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please fill in all the fields before continuing.'),
                        backgroundColor: Colors.redAccent,
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
                child: Text("Continue to Lifestyle Info",
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
              value: 0.5, // Updated to 50% progress
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
            _buildProgressStep(2, "Personal", true),
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