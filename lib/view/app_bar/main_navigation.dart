import 'package:flutter/material.dart';
import 'package:heartcare/view/add_screen.dart';
import 'package:heartcare/view/homepage_screen.dart';
import 'package:heartcare/view/profile_screen.dart';
import 'package:heartcare/view/symptom_screen.dart';
import 'package:heartcare/view/treatment_screen.dart';
import 'bottomnavbar.dart';

class MainNavigationScreen extends StatefulWidget {
  final int selectedIndex;
  const MainNavigationScreen({super.key, this.selectedIndex = 0});

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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPage()),
    );
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
        onPressed: _onFabTapped,
        child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
