import 'package:flutter/material.dart';
import 'package:heartcare/view/homepage_screen.dart';
import 'package:heartcare/view/profile_screen.dart';
import 'package:heartcare/view/symptom_screen.dart';
import 'package:heartcare/view/treatment_screen.dart';
import '../addsymptom_screen.dart';
import '../addtreatment_screen.dart';
import '../popup_screen/add_new_popup.dart';
import 'bottomnavbar.dart';

class MainNavigationScreen extends StatefulWidget {
  final int selectedIndex;
  const MainNavigationScreen({super.key, required this.selectedIndex});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;

  final List<Widget> _pages = [
    HomepageScreen(),
    TreatmentPage(),
    SymptomPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFabTapped() {
    _showAddNewPopup(context);  // Call _showAddNewPopup with the correct context
  }

  void _showAddNewPopup(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => const AddNewPopup(),
    );

    // Handle the result (either 'treatment' or 'symptom')
    if (result == 'treatment') {
      // Navigate to add treatment page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddTreatmentPage()),
      );
    } else if (result == 'symptom') {
      // Navigate to add symptom page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddSymptomScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff0b036c),
        shape: const StadiumBorder(),
        onPressed: _onFabTapped, // Trigger the popup on FAB press
        child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
