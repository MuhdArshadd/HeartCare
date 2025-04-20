import 'package:flutter/material.dart';
import 'package:heartcare/user_provider.dart';
import 'package:provider/provider.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Welcome, ${user?.fullname ?? 'Guest'}'),
      ),
      body: const Center(
        child: Text('Home Page Content Here'),
      ),
    );
  }
}

