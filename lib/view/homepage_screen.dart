import 'package:flutter/material.dart';
import 'package:heartcare/model/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'app_bar/appbar.dart';

class HomepageScreen extends StatelessWidget {
  const HomepageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: Center(
        child: Text('Welcome, ${user?.fullname ?? "User"}!'),
      ),
    );
  }
}
